import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../models/meal_record.dart';
import '../repositories/dummy_data.dart';
import 'api_service.dart';
import 'proxy_client_config.dart';

class FoodApiService {
  final ApiService _apiService;
  final ProxyClientConfig _proxyConfig;
  final Map<String, List<FoodItem>> _aiCache = {};
  final Map<String, List<FoodItem>> _publicApiCache = {};

  FoodApiService({
    ApiService? apiService,
    String? proxyBaseUrl,
    String? proxyClientToken,
    ProxyClientConfig? proxyConfig,
  }) : _apiService = apiService ?? ApiService(),
       _proxyConfig =
           proxyConfig ??
           ProxyClientConfig.fromEnvironment(
             baseUrlOverride: proxyBaseUrl,
             clientTokenOverride: proxyClientToken,
           );

  bool get isProxyConfigured => _proxyConfig.isConfigured;

  Future<List<FoodItem>> searchFood(
    String query, {
    String locale = 'ko',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return _searchLocal('');
    }

    final localResults = _searchLocal(trimmed);

    List<FoodItem> publicResults = [];
    if (isProxyConfigured) {
      publicResults = await _searchPublicApi(trimmed);
    }

    final combinedResults = _mergeResults(localResults, publicResults);

    if (combinedResults.length >= 3) {
      return combinedResults;
    }

    final cacheKey = '${_normalizeLocale(locale)}:${trimmed.toLowerCase()}';
    if (_aiCache.containsKey(cacheKey)) {
      return _mergeResults(combinedResults, _aiCache[cacheKey]!);
    }

    if (isProxyConfigured) {
      try {
        final aiResults = await _searchWithAi(trimmed, locale: locale);
        if (aiResults.isNotEmpty) {
          _aiCache[cacheKey] = aiResults;
          return _mergeResults(combinedResults, aiResults);
        }
      } catch (e) {
        debugPrint('AI 음식 검색 실패: $e');
      }
    }

    return combinedResults;
  }

  Future<List<FoodItem>> _searchPublicApi(String query) async {
    final cacheKey = query.trim().toLowerCase();
    if (_publicApiCache.containsKey(cacheKey)) {
      return _publicApiCache[cacheKey]!;
    }

    try {
      final response = await _apiService.get(
        _proxyConfig.baseUrl,
        ApiConstants.proxyFoodPublicEndpoint,
        queryParams: {'query': query},
        headers: _proxyConfig.authHeaders,
      );

      final results = _parseProxyFoodItems(
        response.data,
        defaultSource: FoodSource.publicApi,
        defaultIsAiGenerated: false,
      );

      _publicApiCache[cacheKey] = results;
      return results;
    } catch (e) {
      debugPrint('공공데이터 API 검색 실패: $e');
      return [];
    }
  }

  double _parseNutrientValue(Object? value) {
    if (value is num) {
      return value.toDouble().clamp(0.0, double.infinity).toDouble();
    }
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty || raw == '-' || raw == 'N/A') {
      return 0.0;
    }
    final normalized = raw.replaceAll(',', '');
    final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(normalized);
    final parsed = match == null ? null : double.tryParse(match.group(0)!);
    if (parsed == null || parsed < 0) return 0.0;
    return parsed;
  }

  Future<List<FoodItem>> _searchWithAi(
    String query, {
    required String locale,
  }) async {
    final response = await _apiService.post(
      _proxyConfig.baseUrl,
      ApiConstants.proxyFoodAnalyzeEndpoint,
      data: {'query': query, 'locale': _normalizeLocale(locale)},
      headers: _proxyConfig.authHeaders,
    );

    return _parseProxyFoodItems(
      response.data,
      defaultSource: FoodSource.aiAnalysis,
      defaultIsAiGenerated: true,
    );
  }

  List<FoodItem> _parseProxyFoodItems(
    Object? responseData, {
    required FoodSource defaultSource,
    required bool defaultIsAiGenerated,
  }) {
    final responseMap = _decodeJsonObject(responseData);
    final items = _asList(responseMap?['items'] ?? responseData);
    if (items == null || items.isEmpty) return [];

    return items
        .map((item) {
          final map = _asStringMap(item);
          if (map == null) return null;

          return FoodItem.fromJson({
            ...map,
            'source': _readString(map['source']) ?? defaultSource.name,
            'isAiGenerated':
                map['isAiGenerated'] as bool? ?? defaultIsAiGenerated,
          });
        })
        .whereType<FoodItem>()
        .where((item) => item.calories > 0 && item.name.isNotEmpty)
        .toList();
  }

  List<FoodItem> _mergeResults(
    List<FoodItem> primary,
    List<FoodItem> secondary,
  ) {
    final merged = [...primary];
    final existingNames = primary.map((f) => f.name.toLowerCase()).toSet();

    for (final item in secondary) {
      if (!existingNames.contains(item.name.toLowerCase())) {
        merged.add(item);
        existingNames.add(item.name.toLowerCase());
      }
    }
    return merged;
  }

  List<FoodItem> _searchLocal(String query) {
    final results = query.isEmpty
        ? DummyData.foodDatabase
        : DummyData.foodDatabase
              .where(
                (f) => (f['name'] as String).toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();

    return results
        .map(
          (f) => FoodItem(
            name: f['name'] as String,
            calories: f['calories'] as int,
            carbs: (f['carbs'] as num).toDouble(),
            protein: (f['protein'] as num).toDouble(),
            fat: (f['fat'] as num).toDouble(),
            source: FoodSource.localDb,
            isAiGenerated: false,
          ),
        )
        .toList();
  }

  void clearCache() {
    _aiCache.clear();
    _publicApiCache.clear();
  }

  Future<FoodItem?> searchByBarcode(String barcode) async {
    try {
      final response = await _apiService.get(
        ApiConstants.openFoodFactsBaseUrl,
        '/api/v0/product/$barcode.json',
      );

      final data = _asStringMap(response.data);
      if (data == null || _parseNutrientValue(data['status']).round() != 1) {
        return null;
      }

      final product = _asStringMap(data['product']);
      if (product == null) return null;

      final nutriments = _asStringMap(product['nutriments']) ?? {};
      final name =
          _readString(product['product_name_ko']) ??
          _readString(product['product_name']) ??
          '알 수 없는 제품';

      return FoodItem(
        name: name,
        calories: _parseNutrientValue(nutriments['energy-kcal_100g']).round(),
        carbs: _parseNutrientValue(nutriments['carbohydrates_100g']),
        protein: _parseNutrientValue(nutriments['proteins_100g']),
        fat: _parseNutrientValue(nutriments['fat_100g']),
        brand: _readString(product['brands']),
        servingSize: _readString(product['serving_size']) ?? '100g',
        source: FoodSource.barcode,
        isAiGenerated: false,
      );
    } catch (e) {
      debugPrint('바코드 검색 실패: $e');
      return null;
    }
  }

  Map<String, bool> getApiStatus() {
    return {
      'localDb': true,
      'proxy': isProxyConfigured,
      'publicApi': isProxyConfigured,
      'aiAnalysis': isProxyConfigured,
      'barcode': true,
    };
  }

  String _normalizeLocale(String locale) {
    return locale.toLowerCase().startsWith('en') ? 'en' : 'ko';
  }
}

enum FoodSource { localDb, publicApi, aiAnalysis, barcode, imageRecognition }

class FoodItem {
  final String name;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final String? brand;
  final String? servingSize;
  final String? imageUrl;
  final double? recognitionConfidence;

  final bool isAiGenerated;
  final FoodSource source;

  FoodItem({
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.brand,
    this.servingSize,
    this.imageUrl,
    this.recognitionConfidence,
    this.isAiGenerated = false,
    this.source = FoodSource.localDb,
  });

  String get sourceLabel {
    switch (source) {
      case FoodSource.localDb:
        return '내장 DB';
      case FoodSource.publicApi:
        return '식약처';
      case FoodSource.aiAnalysis:
        return 'AI 분석';
      case FoodSource.barcode:
        return '바코드';
      case FoodSource.imageRecognition:
        return '사진 인식';
    }
  }

  String get sourceIconAsset {
    switch (source) {
      case FoodSource.localDb:
        return 'assets/icons/app/source_local_db.svg';
      case FoodSource.publicApi:
        return 'assets/icons/app/source_public_api.svg';
      case FoodSource.aiAnalysis:
        return 'assets/icons/app/source_ai.svg';
      case FoodSource.barcode:
        return 'assets/icons/app/source_barcode.svg';
      case FoodSource.imageRecognition:
        return 'assets/icons/app/source_image_recognition.svg';
    }
  }

  MealRecord toMealRecord({
    required String id,
    required DateTime date,
    required MealType mealType,
  }) {
    return MealRecord(
      id: id,
      date: date,
      mealType: mealType,
      name: name,
      calories: calories,
      carbs: carbs,
      protein: protein,
      fat: fat,
      imageUrl: imageUrl,
      servingSize: servingSize,
      isAiRecognized: source == FoodSource.imageRecognition,
      recognitionConfidence: recognitionConfidence,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'calories': calories,
    'carbs': carbs,
    'protein': protein,
    'fat': fat,
    'brand': brand,
    'servingSize': servingSize,
    'imageUrl': imageUrl,
    'recognitionConfidence': recognitionConfidence,
    'isAiGenerated': isAiGenerated,
    'source': source.name,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    name: _readString(json['name']) ?? '',
    calories: _readNumeric(json['calories']).round(),
    carbs: _readNumeric(json['carbs']),
    protein: _readNumeric(json['protein']),
    fat: _readNumeric(json['fat']),
    brand: _readString(json['brand']),
    servingSize: _readString(json['servingSize']),
    imageUrl: _readString(json['imageUrl']),
    recognitionConfidence: _readNullableNumeric(json['recognitionConfidence']),
    isAiGenerated: json['isAiGenerated'] as bool? ?? false,
    source: FoodSource.values.firstWhere(
      (e) => e.name == _readString(json['source']),
      orElse: () => FoodSource.localDb,
    ),
  );
}

Map<String, dynamic>? _decodeJsonObject(Object? data) {
  if (data is String) {
    try {
      return _asStringMap(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  return _asStringMap(data);
}

Map<String, dynamic>? _asStringMap(Object? data) {
  if (data is! Map) return null;

  return data.map((key, value) => MapEntry(key.toString(), value));
}

List<dynamic>? _asList(Object? data) {
  if (data == null) return null;
  if (data is List) return data;
  return [data];
}

String? _readString(Object? value) {
  final string = value?.toString().trim();
  if (string == null || string.isEmpty) return null;
  return string;
}

double _readNumeric(Object? value) {
  if (value is num) {
    return value.toDouble().clamp(0.0, double.infinity).toDouble();
  }

  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return 0;

  final normalized = raw.replaceAll(',', '');
  final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(normalized);
  final parsed = match == null ? null : double.tryParse(match.group(0)!);
  if (parsed == null || parsed < 0) return 0;
  return parsed;
}

double? _readNullableNumeric(Object? value) {
  if (value == null) return null;
  return _readNumeric(value);
}
