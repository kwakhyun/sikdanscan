import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/food_recognition_result.dart';
import 'api_service.dart';
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
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final mimeType = _mimeTypeFromBytes(bytes) ?? _mimeTypeFromPath(imagePath);
    return recognizeImageBytes(bytes, mimeType: mimeType, locale: locale);
  }

  Future<FoodRecognitionResult> recognizeImageBytes(
    Uint8List bytes, {
    String mimeType = 'image/jpeg',
    String locale = 'ko',
  }) async {
    if (!_proxyConfig.isConfigured) {
      throw const FoodImageRecognitionException(
        'SIKDANSCAN_PROXY_BASE_URL is required for food image recognition.',
      );
    }

    if (bytes.isEmpty) {
      throw const FoodImageRecognitionException('Image is empty.');
    }

    if (bytes.length > _maxImageBytes) {
      throw const FoodImageRecognitionException('Image is too large.');
    }

    final normalizedMimeType = _normalizeMimeType(mimeType);
    if (normalizedMimeType == null) {
      throw const FoodImageRecognitionException(
        '현재 HEIC/HEIF 이미지는 분석할 수 없습니다. JPG 또는 PNG 사진으로 다시 선택해주세요.',
      );
    }

    final response = await _postRecognitionPayload(
      bytes,
      normalizedMimeType,
      locale,
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

  String? _mimeTypeFromBytes(Uint8List bytes) {
    if (bytes.length >= 12 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(4, 8)) == 'ftyp') {
      final brand = String.fromCharCodes(bytes.sublist(8, 12)).toLowerCase();
      if (brand == 'heic' ||
          brand == 'heix' ||
          brand == 'hevc' ||
          brand == 'hevx' ||
          brand == 'heif' ||
          brand == 'mif1' ||
          brand == 'msf1') {
        return 'image/heic';
      }
    }
    return null;
  }

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
  ) async {
    try {
      return await _apiService.post<Object?>(
        _proxyConfig.baseUrl,
        ApiConstants.proxyFoodRecognizeEndpoint,
        headers: _proxyConfig.authHeaders,
        data: {
          'imageBase64': base64Encode(bytes),
          'mimeType': _normalizeMimeType(mimeType),
          'locale': _normalizeLocale(locale),
        },
      );
    } on DioException catch (error) {
      throw FoodImageRecognitionException(_friendlyRecognitionError(error));
    }
  }

  String _normalizeLocale(String locale) {
    return locale.toLowerCase().startsWith('en') ? 'en' : 'ko';
  }

  String _friendlyRecognitionError(DioException error) {
    final statusCode = error.response?.statusCode;
    final proxyMessage = _proxyErrorMessage(error.response?.data);
    final apiError = error.error;
    if (apiError is ApiError) {
      return switch (apiError.code) {
        'NO_CONNECTION' => '식단스캔 API 프록시에 연결할 수 없습니다. 로컬 프록시 실행 상태를 확인해주세요.',
        'TIMEOUT' => '사진 인식 요청 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.',
        'UNAUTHORIZED' => '식단스캔 API 프록시 인증 토큰을 확인해주세요.',
        'RATE_LIMIT' => apiError.message,
        _ =>
          _serverStatusErrorMessage(statusCode, proxyMessage) ??
              proxyMessage ??
              apiError.message,
      };
    }

    return _serverStatusErrorMessage(statusCode, proxyMessage) ??
        proxyMessage ??
        '사진 인식 중 오류가 발생했습니다.';
  }

  String? _serverStatusErrorMessage(int? statusCode, String? proxyMessage) {
    if (statusCode == 401 || statusCode == 403) {
      return '식단스캔 API 프록시 인증 토큰을 확인해주세요.';
    }
    if (statusCode == 400 || statusCode == 422) {
      return _imageRequestErrorMessage(proxyMessage);
    }
    if (statusCode == 413) {
      return '이미지 용량이 너무 큽니다. 다른 사진으로 다시 시도해주세요.';
    }
    if (statusCode == 503) {
      return '프록시 서버에 OPENAI_API_KEY가 설정되어 있지 않습니다.';
    }
    if (statusCode == 502) {
      return 'AI 이미지 분석 서버가 정상 응답하지 않습니다. 잠시 후 다시 시도해주세요.';
    }
    if (statusCode == 504) {
      return '사진 인식 요청 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.';
    }
    return null;
  }

  String _imageRequestErrorMessage(String? proxyMessage) {
    final lower = proxyMessage?.toLowerCase() ?? '';
    if (lower.contains('unsupported image') ||
        lower.contains('invalid image') ||
        lower.contains('image format') ||
        lower.contains('heic') ||
        lower.contains('heif')) {
      return '지원하지 않는 이미지 형식입니다. JPG 또는 PNG 사진으로 다시 선택해주세요.';
    }
    if (lower.contains('model') || lower.contains('vision')) {
      return 'AI 이미지 분석 모델 설정을 확인해주세요.';
    }
    return '사진을 분석할 수 없습니다. 음식이 잘 보이는 JPG/PNG 사진으로 다시 시도해주세요.';
  }

  String? _proxyErrorMessage(Object? data) {
    if (data is Map) {
      final error = data['error'];
      if (error is String && error.trim().isNotEmpty) return error.trim();
    }
    return null;
  }
}

class FoodImageRecognitionException implements Exception {
  const FoodImageRecognitionException(this.message);

  final String message;

  @override
  String toString() => message;
}
