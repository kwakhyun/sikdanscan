import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:sikdanscan/data/services/food_api_service.dart';
import 'package:sikdanscan/data/services/api_service.dart';
import 'package:sikdanscan/data/models/meal_record.dart';

void main() {
  group('FoodApiService', () {
    late FoodApiService service;

    setUp(() {
      service = FoodApiService();
    });

    test('searchFood returns all foods when query is empty', () async {
      final results = await service.searchFood('');

      expect(results, isNotEmpty);
      expect(results.length, greaterThanOrEqualTo(10));
    });

    test('searchFood filters by name', () async {
      final results = await service.searchFood('닭가슴살');

      expect(results, isNotEmpty);
      expect(results.every((f) => f.name.contains('닭가슴살')), isTrue);
    });

    test('searchFood returns results for Korean food categories', () async {
      final riceFoods = await service.searchFood('밥');
      expect(riceFoods, isNotEmpty);

      final meatFoods = await service.searchFood('고기');
      expect(meatFoods, isNotEmpty);

      final drinkFoods = await service.searchFood('아메리카노');
      expect(drinkFoods, isNotEmpty);
    });

    test('searchFood returns local results for common foods', () async {
      final results = await service.searchFood('김치');
      expect(results, isNotEmpty);
      expect(results.any((f) => !f.isAiGenerated), isTrue);
    });

    test('searchFood handles special characters', () async {
      final results = await service.searchFood('(드레싱');
      expect(results, isNotEmpty);
    });

    test('expanded food database has 70+ items', () async {
      final all = await service.searchFood('');
      expect(all.length, greaterThanOrEqualTo(70));
    });

    test('food database covers all major categories', () async {
      final all = await service.searchFood('');
      final allNames = all.map((f) => f.name).join(' ');

      expect(allNames.contains('밥'), isTrue);
      expect(allNames.contains('면'), isTrue);
      expect(allNames.contains('닭'), isTrue);
      expect(allNames.contains('찌개'), isTrue);
      expect(allNames.contains('과'), isTrue);
      expect(allNames.contains('아메리카노'), isTrue);
    });

    test('searchFood returns empty for non-existent food without AI', () async {
      final results = await service.searchFood('존재하지않는음식xyz');
      expect(results, isA<List<FoodItem>>());
    });

    test('FoodItem has correct properties', () {
      final item = FoodItem(
        name: '테스트 음식',
        calories: 200,
        carbs: 20,
        protein: 15,
        fat: 8,
      );

      expect(item.name, '테스트 음식');
      expect(item.calories, 200);
      expect(item.carbs, 20);
      expect(item.protein, 15);
      expect(item.fat, 8);
      expect(item.isAiGenerated, isFalse);
      expect(item.source, FoodSource.localDb);
    });

    test('FoodItem isAiGenerated flag works', () {
      final aiItem = FoodItem(
        name: 'AI 분석 음식',
        calories: 300,
        carbs: 25,
        protein: 20,
        fat: 10,
        isAiGenerated: true,
        source: FoodSource.aiAnalysis,
      );

      expect(aiItem.isAiGenerated, isTrue);
      expect(aiItem.source, FoodSource.aiAnalysis);

      final localItem = FoodItem(
        name: '로컬 DB 음식',
        calories: 200,
        carbs: 15,
        protein: 10,
        fat: 5,
        isAiGenerated: false,
      );

      expect(localItem.isAiGenerated, isFalse);
      expect(localItem.source, FoodSource.localDb);
    });

    test('FoodItem toJson and fromJson roundtrip preserves all fields', () {
      final item = FoodItem(
        name: '테스트',
        calories: 150,
        carbs: 10,
        protein: 20,
        fat: 5,
        brand: '브랜드A',
        servingSize: '100g',
        imageUrl: '/tmp/food.jpg',
        recognitionConfidence: 0.91,
        isAiGenerated: true,
        source: FoodSource.imageRecognition,
      );

      final json = item.toJson();
      final restored = FoodItem.fromJson(json);

      expect(restored.name, item.name);
      expect(restored.calories, item.calories);
      expect(restored.brand, item.brand);
      expect(restored.servingSize, item.servingSize);
      expect(restored.imageUrl, item.imageUrl);
      expect(restored.recognitionConfidence, item.recognitionConfidence);
      expect(restored.isAiGenerated, isTrue);
      expect(restored.source, FoodSource.imageRecognition);
    });

    test('FoodItem.fromJson defaults isAiGenerated to false when missing', () {
      final json = {
        'name': '이전 데이터',
        'calories': 100,
        'carbs': 10.0,
        'protein': 5.0,
        'fat': 3.0,
      };

      final item = FoodItem.fromJson(json);
      expect(item.isAiGenerated, isFalse);
      expect(item.source, FoodSource.localDb);
    });

    test('FoodItem.fromJson accepts numeric strings from older payloads', () {
      final json = {
        'name': '문자열 숫자 음식',
        'calories': '275 kcal',
        'carbs': '31.5g',
        'protein': '18g',
        'fat': '7.2g',
        'source': 'publicApi',
      };

      final item = FoodItem.fromJson(json);

      expect(item.calories, 275);
      expect(item.carbs, 31.5);
      expect(item.protein, 18);
      expect(item.fat, 7.2);
      expect(item.source, FoodSource.publicApi);
    });

    test('FoodItem.toMealRecord converts correctly', () {
      final item = FoodItem(
        name: '현미밥',
        calories: 260,
        carbs: 56,
        protein: 6,
        fat: 2,
        servingSize: '1공기',
        imageUrl: '/tmp/meal.jpg',
        recognitionConfidence: 0.88,
        isAiGenerated: true,
        source: FoodSource.imageRecognition,
      );

      final meal = item.toMealRecord(
        id: 'meal_1',
        date: DateTime(2026, 2, 12),
        mealType: MealType.lunch,
      );

      expect(meal.id, 'meal_1');
      expect(meal.name, '현미밥');
      expect(meal.calories, 260);
      expect(meal.mealType, MealType.lunch);
      expect(meal.servingSize, '1공기');
      expect(meal.imageUrl, '/tmp/meal.jpg');
      expect(meal.isAiRecognized, isTrue);
      expect(meal.recognitionConfidence, 0.88);
    });

    test('clearCache clears all caches', () {
      service.clearCache();
      expect(() => service.clearCache(), returnsNormally);
    });
  });

  group('FoodSource', () {
    test('FoodSource enum has all expected values', () {
      expect(FoodSource.values, hasLength(5));
      expect(FoodSource.values, contains(FoodSource.localDb));
      expect(FoodSource.values, contains(FoodSource.publicApi));
      expect(FoodSource.values, contains(FoodSource.aiAnalysis));
      expect(FoodSource.values, contains(FoodSource.barcode));
      expect(FoodSource.values, contains(FoodSource.imageRecognition));
    });

    test('FoodItem sourceLabel returns correct labels', () {
      final local = FoodItem(
        name: 't',
        calories: 0,
        carbs: 0,
        protein: 0,
        fat: 0,
        source: FoodSource.localDb,
      );
      expect(local.sourceLabel, '내장 DB');

      final publicApi = FoodItem(
        name: 't',
        calories: 0,
        carbs: 0,
        protein: 0,
        fat: 0,
        source: FoodSource.publicApi,
      );
      expect(publicApi.sourceLabel, '식약처');

      final ai = FoodItem(
        name: 't',
        calories: 0,
        carbs: 0,
        protein: 0,
        fat: 0,
        source: FoodSource.aiAnalysis,
      );
      expect(ai.sourceLabel, 'AI 분석');

      final barcode = FoodItem(
        name: 't',
        calories: 0,
        carbs: 0,
        protein: 0,
        fat: 0,
        source: FoodSource.barcode,
      );
      expect(barcode.sourceLabel, '바코드');

      final imageRecognition = FoodItem(
        name: 't',
        calories: 0,
        carbs: 0,
        protein: 0,
        fat: 0,
        source: FoodSource.imageRecognition,
      );
      expect(imageRecognition.sourceLabel, '사진 인식');
    });

    test('FoodItem sourceIconAsset returns expected svg assets', () {
      final local = FoodItem(
        name: 't',
        calories: 0,
        carbs: 0,
        protein: 0,
        fat: 0,
        source: FoodSource.localDb,
      );
      expect(local.sourceIconAsset, 'assets/icons/app/source_local_db.svg');

      final publicApi = FoodItem(
        name: 't',
        calories: 0,
        carbs: 0,
        protein: 0,
        fat: 0,
        source: FoodSource.publicApi,
      );
      expect(
        publicApi.sourceIconAsset,
        'assets/icons/app/source_public_api.svg',
      );

      final ai = FoodItem(
        name: 't',
        calories: 0,
        carbs: 0,
        protein: 0,
        fat: 0,
        source: FoodSource.aiAnalysis,
      );
      expect(ai.sourceIconAsset, 'assets/icons/app/source_ai.svg');

      final barcode = FoodItem(
        name: 't',
        calories: 0,
        carbs: 0,
        protein: 0,
        fat: 0,
        source: FoodSource.barcode,
      );
      expect(barcode.sourceIconAsset, 'assets/icons/app/source_barcode.svg');

      final imageRecognition = FoodItem(
        name: 't',
        calories: 0,
        carbs: 0,
        protein: 0,
        fat: 0,
        source: FoodSource.imageRecognition,
      );
      expect(
        imageRecognition.sourceIconAsset,
        'assets/icons/app/source_image_recognition.svg',
      );
    });

    test('FoodItem.fromJson handles source field correctly', () {
      final json = {
        'name': 'test',
        'calories': 100,
        'carbs': 10.0,
        'protein': 5.0,
        'fat': 3.0,
        'source': 'publicApi',
      };
      final item = FoodItem.fromJson(json);
      expect(item.source, FoodSource.publicApi);
    });

    test('FoodItem.fromJson defaults source to localDb when missing', () {
      final json = {
        'name': 'test',
        'calories': 100,
        'carbs': 10.0,
        'protein': 5.0,
        'fat': 3.0,
      };
      final item = FoodItem.fromJson(json);
      expect(item.source, FoodSource.localDb);
    });

    test('FoodItem.toJson includes source field', () {
      final item = FoodItem(
        name: 'test',
        calories: 100,
        carbs: 10,
        protein: 5,
        fat: 3,
        source: FoodSource.publicApi,
      );
      final json = item.toJson();
      expect(json['source'], 'publicApi');
    });
  });

  group('FoodApiService - getApiStatus', () {
    test('getApiStatus returns correct keys', () {
      final service = FoodApiService();
      final status = service.getApiStatus();

      expect(status.containsKey('localDb'), isTrue);
      expect(status.containsKey('proxy'), isTrue);
      expect(status.containsKey('publicApi'), isTrue);
      expect(status.containsKey('aiAnalysis'), isTrue);
      expect(status.containsKey('barcode'), isTrue);
    });

    test('localDb is always available', () {
      final service = FoodApiService();
      final status = service.getApiStatus();
      expect(status['localDb'], isTrue);
    });

    test('barcode is always available', () {
      final service = FoodApiService();
      final status = service.getApiStatus();
      expect(status['barcode'], isTrue);
    });
  });

  group('FoodApiService - local DB search edge cases', () {
    test('search is case insensitive', () async {
      final service = FoodApiService();
      final upper = await service.searchFood('아메리카노');
      expect(upper, isNotEmpty);
    });

    test('search trims whitespace', () async {
      final service = FoodApiService();
      final result = await service.searchFood('  밥  ');
      expect(result, isNotEmpty);
    });

    test('empty string returns full database', () async {
      final service = FoodApiService();
      final result = await service.searchFood('');
      expect(result.length, greaterThanOrEqualTo(70));
    });

    test('whitespace-only query returns full database', () async {
      final service = FoodApiService();
      final result = await service.searchFood('   ');
      expect(result.length, greaterThanOrEqualTo(70));
    });
  });

  group('FoodApiService - external response parsing', () {
    test('public search reads normalized food items from proxy', () async {
      final fakeApi = FakeApiService(
        getData: {
          'items': [
            {
              'name': '테스트 공공 음식',
              'calories': '321 kcal',
              'carbs': '42.5 g',
              'protein': '21 g',
              'fat': '8.5 g',
              'servingSize': '1인분',
              'source': 'publicApi',
              'isAiGenerated': false,
            },
          ],
        },
      );
      final service = FoodApiService(
        apiService: fakeApi,
        proxyBaseUrl: 'https://proxy.example.com/',
        proxyClientToken: 'client-token',
      );

      final results = await service.searchFood('테스트공공음식xyz');

      expect(fakeApi.getCount, 1);
      expect(fakeApi.lastGetBaseUrl, 'https://proxy.example.com');
      expect(fakeApi.lastGetPath, '/v1/foods/public');
      expect(fakeApi.lastGetHeaders?['Authorization'], 'Bearer client-token');
      expect(results, hasLength(1));
      expect(results.single.name, '테스트 공공 음식');
      expect(results.single.calories, 321);
      expect(results.single.carbs, 42.5);
      expect(results.single.source, FoodSource.publicApi);
    });

    test('AI analysis reads normalized food items from proxy', () async {
      final fakeApi = FakeApiService(
        postData: {
          'items': [
            {
              'name': '테스트 AI 볼',
              'calories': '455 kcal',
              'carbs': '52.4g',
              'protein': '28.0g',
              'fat': '14.2g',
              'servingSize': '1그릇',
              'source': 'aiAnalysis',
              'isAiGenerated': true,
            },
          ],
        },
      );
      final service = FoodApiService(
        apiService: fakeApi,
        proxyBaseUrl: 'https://proxy.example.com',
        proxyClientToken: 'client-token',
      );

      final results = await service.searchFood('로컬에없는AI음식xyz', locale: 'en');

      expect(fakeApi.postCount, 1);
      expect(fakeApi.lastPostBaseUrl, 'https://proxy.example.com');
      expect(fakeApi.lastPostPath, '/v1/foods/analyze');
      expect(fakeApi.lastPostHeaders?['Authorization'], 'Bearer client-token');
      expect(fakeApi.lastPostData, containsPair('locale', 'en'));
      expect(results, hasLength(1));
      expect(results.single.name, '테스트 AI 볼');
      expect(results.single.calories, 455);
      expect(results.single.protein, 28);
      expect(results.single.source, FoodSource.aiAnalysis);
      expect(results.single.isAiGenerated, isTrue);
    });

    test(
      'proxy public results can satisfy search without AI fallback',
      () async {
        final fakeApi = FakeApiService(
          getData: {
            'items': [
              {
                'name': '공공 음식 1',
                'calories': 101,
                'carbs': 1,
                'protein': 1,
                'fat': 1,
              },
              {
                'name': '공공 음식 2',
                'calories': 102,
                'carbs': 1,
                'protein': 1,
                'fat': 1,
              },
              {
                'name': '공공 음식 3',
                'calories': 103,
                'carbs': 1,
                'protein': 1,
                'fat': 1,
              },
            ],
          },
        );
        final service = FoodApiService(
          apiService: fakeApi,
          proxyBaseUrl: 'https://proxy.example.com',
        );

        final results = await service.searchFood('공공전용검색xyz');

        expect(results, hasLength(3));
        expect(fakeApi.getCount, 1);
        expect(fakeApi.postCount, 0);
      },
    );

    test('proxy status is enabled when proxy base URL is configured', () {
      final service = FoodApiService(proxyBaseUrl: 'https://proxy.example.com');

      final status = service.getApiStatus();

      expect(service.isProxyConfigured, isTrue);
      expect(status['proxy'], isTrue);
      expect(status['publicApi'], isTrue);
      expect(status['aiAnalysis'], isTrue);
    });

    test(
      'barcode parser handles string nutrients from Open Food Facts',
      () async {
        final fakeApi = FakeApiService(
          getData: {
            'status': '1',
            'product': {
              'product_name': 'Protein Bar',
              'brands': 'Fit Brand',
              'serving_size': '55g',
              'nutriments': {
                'energy-kcal_100g': '389 kcal',
                'carbohydrates_100g': '33.1',
                'proteins_100g': '21.8',
                'fat_100g': '12.5',
              },
            },
          },
        );
        final service = FoodApiService(apiService: fakeApi);

        final result = await service.searchByBarcode('8800000000000');

        expect(result, isNotNull);
        expect(result!.name, 'Protein Bar');
        expect(result.calories, 389);
        expect(result.carbs, 33.1);
        expect(result.protein, 21.8);
        expect(result.fat, 12.5);
        expect(result.brand, 'Fit Brand');
        expect(result.source, FoodSource.barcode);
      },
    );
  });
}

class FakeApiService implements ApiService {
  FakeApiService({this.getData, this.postData});

  final Object? getData;
  final Object? postData;
  int getCount = 0;
  int postCount = 0;
  String? lastGetBaseUrl;
  String? lastGetPath;
  String? lastPostBaseUrl;
  String? lastPostPath;
  Map<String, dynamic>? lastGetHeaders;
  Map<String, dynamic>? lastPostHeaders;
  Map<String, dynamic>? lastPostData;

  @override
  Dio get dio => Dio();

  @override
  void close() {}

  @override
  Future<Response<T>> get<T>(
    String baseUrl,
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
  }) async {
    getCount += 1;
    lastGetBaseUrl = baseUrl;
    lastGetPath = path;
    lastGetHeaders = headers;
    return Response<T>(
      data: getData as T?,
      requestOptions: RequestOptions(path: '$baseUrl$path'),
    );
  }

  @override
  Future<Response<T>> post<T>(
    String baseUrl,
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    postCount += 1;
    lastPostBaseUrl = baseUrl;
    lastPostPath = path;
    lastPostHeaders = headers;
    lastPostData = data as Map<String, dynamic>?;
    return Response<T>(
      data: postData as T?,
      requestOptions: RequestOptions(path: '$baseUrl$path'),
    );
  }
}
