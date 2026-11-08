import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/food_recognition_result.dart';
import 'api_service.dart';
import 'meal_image_store.dart';
import 'proxy_client_config.dart';

class FoodImageRecognitionService {
  FoodImageRecognitionService({
    ApiService? apiService,
    ProxyClientConfig? proxyConfig,
    int maxImageBytes = 4 * 1024 * 1024,
  }) : _apiService = apiService ?? ApiService(),
       _proxyConfig = proxyConfig ?? ProxyClientConfig.fromEnvironment(),
       _maxImageBytes = maxImageBytes;

  final ApiService _apiService;
  final ProxyClientConfig _proxyConfig;
  final int _maxImageBytes;

  bool get isConfigured => _proxyConfig.isConfigured;

  Future<FoodRecognitionResult> recognizeImageFile(
    String imagePath, {
    String locale = 'ko',
    CancelToken? cancelToken,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final mimeType = _mimeTypeFromBytes(bytes) ?? _mimeTypeFromPath(imagePath);
    return recognizeImageBytes(
      bytes,
      mimeType: mimeType,
      locale: locale,
      cancelToken: cancelToken,
    );
  }

  Future<FoodRecognitionResult> recognizeImageBytes(
    Uint8List bytes, {
    String mimeType = 'image/jpeg',
    String locale = 'ko',
    CancelToken? cancelToken,
  }) async {
    if (!_proxyConfig.isConfigured) {
      throw const FoodImageRecognitionException(
        'SIKDANSCAN_PROXY_BASE_URL is required for food image recognition.',
      );
    }

    final english = _isEnglish(locale);
    if (bytes.isEmpty) {
      throw FoodImageRecognitionException(
        english ? 'The image is empty.' : '이미지가 비어 있습니다.',
      );
    }

    if (bytes.length > _maxImageBytes) {
      throw FoodImageRecognitionException(
        english
            ? 'The image is too large. Please try another photo.'
            : '이미지 용량이 너무 큽니다. 다른 사진으로 다시 시도해주세요.',
      );
    }

    final normalizedMimeType = _normalizeMimeType(mimeType);
    if (normalizedMimeType == null) {
      throw FoodImageRecognitionException(
        english
            ? 'HEIC/HEIF images are not supported yet. Please choose a JPG or PNG photo.'
            : '현재 HEIC/HEIF 이미지는 분석할 수 없습니다. JPG 또는 PNG 사진으로 다시 선택해주세요.',
      );
    }

    final response = await _postRecognitionPayload(
      bytes,
      normalizedMimeType,
      locale,
      cancelToken,
    );

    final data = response.data;
    if (data is! Map) {
      throw const FoodImageRecognitionException(
        'Recognition response must be a JSON object.',
      );
    }

    return FoodRecognitionResult.fromJson(
      data.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  String _mimeTypeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) {
      return 'image/heic';
    }
    return 'image/jpeg';
  }

  String? _mimeTypeFromBytes(Uint8List bytes) =>
      MealImageStore.sniffContentType(bytes);

  String? _normalizeMimeType(String mimeType) {
    final normalized = mimeType.toLowerCase().trim();
    if (normalized == 'image/png' ||
        normalized == 'image/webp' ||
        normalized == 'image/jpeg') {
      return normalized;
    }
    return null;
  }

  Future<Response<Object?>> _postRecognitionPayload(
    Uint8List bytes,
    String mimeType,
    String locale,
    CancelToken? cancelToken,
  ) async {
    try {
      return await _apiService.post<Object?>(
        _proxyConfig.baseUrl,
        ApiConstants.proxyFoodRecognizeEndpoint,
        headers: _proxyConfig.authHeaders,
        cancelToken: cancelToken,
        // Vision calls are slow and billed per request: retry at most once so
        // a failing upstream cannot keep the user waiting for minutes.
        maxRetries: 1,
        data: {
          'imageBase64': base64Encode(bytes),
          'mimeType': _normalizeMimeType(mimeType),
          'locale': _normalizeLocale(locale),
        },
      );
    } on DioException catch (error) {
      if (error.type == DioExceptionType.cancel) {
        throw const FoodImageRecognitionCancelled();
      }
      throw FoodImageRecognitionException(
        _friendlyRecognitionError(error, english: _isEnglish(locale)),
      );
    }
  }

  String _normalizeLocale(String locale) => _isEnglish(locale) ? 'en' : 'ko';

  bool _isEnglish(String locale) => locale.toLowerCase().startsWith('en');

  String _friendlyRecognitionError(
    DioException error, {
    required bool english,
  }) {
    final statusCode = error.response?.statusCode;
    final proxyMessage = _proxyErrorMessage(error.response?.data);
    final apiError = error.error;
    if (apiError is ApiError) {
      return switch (apiError.code) {
        'NO_CONNECTION' =>
          english
              ? "Can't reach the photo analysis service. Check your internet connection or enter the food manually."
              : '사진 분석 서비스에 연결할 수 없어요. 인터넷 연결을 확인하거나 음식을 직접 입력해 주세요.',
        'TIMEOUT' =>
          english
              ? 'Photo recognition timed out. Please try again shortly.'
              : '사진 인식 요청 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.',
        'UNAUTHORIZED' => _unavailableMessage(english),
        'RATE_LIMIT' =>
          english
              ? 'Too many requests. Please try again in a moment.'
              : '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.',
        _ =>
          _serverStatusErrorMessage(
                statusCode,
                proxyMessage,
                english: english,
              ) ??
              _genericMessage(english),
      };
    }

    // Raw server text (often English and technical) is never shown to users.
    return _serverStatusErrorMessage(
          statusCode,
          proxyMessage,
          english: english,
        ) ??
        _genericMessage(english);
  }

  String _genericMessage(bool english) => english
      ? "Couldn't analyze the photo. Try again or enter the food manually."
      : '사진을 분석하지 못했어요. 다시 시도하거나 음식을 직접 입력해 주세요.';

  /// Server-side configuration problems (auth token, API key, model) are
  /// for operators; users only learn that the feature is unavailable now.
  String _unavailableMessage(bool english) => english
      ? 'Photo analysis is unavailable right now. Please enter the food manually.'
      : '지금은 사진 분석을 사용할 수 없어요. 음식을 직접 입력해 주세요.';

  String? _serverStatusErrorMessage(
    int? statusCode,
    String? proxyMessage, {
    required bool english,
  }) {
    if (statusCode == 401 || statusCode == 403 || statusCode == 503) {
      return _unavailableMessage(english);
    }
    if (statusCode == 400 || statusCode == 422) {
      return _imageRequestErrorMessage(proxyMessage, english: english);
    }
    if (statusCode == 413) {
      return english
          ? 'The image is too large. Please try another photo.'
          : '이미지 용량이 너무 큽니다. 다른 사진으로 다시 시도해주세요.';
    }
    if (statusCode == 502) {
      return english
          ? 'The photo analysis service is not responding. Please try again shortly.'
          : '사진 분석 서비스가 응답하지 않아요. 잠시 후 다시 시도해 주세요.';
    }
    if (statusCode == 504) {
      return english
          ? 'Photo recognition timed out. Please try again shortly.'
          : '사진 인식 요청 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.';
    }
    return null;
  }

  String _imageRequestErrorMessage(
    String? proxyMessage, {
    required bool english,
  }) {
    final lower = proxyMessage?.toLowerCase() ?? '';
    if (lower.contains('unsupported image') ||
        lower.contains('invalid image') ||
        lower.contains('image format') ||
        lower.contains('heic') ||
        lower.contains('heif')) {
      return english
          ? 'Unsupported image format. Please choose a JPG or PNG photo.'
          : '지원하지 않는 이미지 형식입니다. JPG 또는 PNG 사진으로 다시 선택해주세요.';
    }
    if (lower.contains('model') || lower.contains('vision')) {
      return _unavailableMessage(english);
    }
    return english
        ? 'Could not analyze the photo. Try a clear JPG/PNG photo of the food.'
        : '사진을 분석할 수 없습니다. 음식이 잘 보이는 JPG/PNG 사진으로 다시 시도해주세요.';
  }

  String? _proxyErrorMessage(Object? data) {
    if (data is Map) {
      final error = data['error'];
      if (error is String && error.trim().isNotEmpty) return error.trim();
    }
    return null;
  }
}

class FoodImageRecognitionCancelled implements Exception {
  const FoodImageRecognitionCancelled();
}

class FoodImageRecognitionException implements Exception {
  const FoodImageRecognitionException(this.message);

  final String message;

  @override
  String toString() => message;
}
