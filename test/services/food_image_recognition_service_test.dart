import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:sikdanscan/data/services/api_service.dart';
import 'package:sikdanscan/data/services/food_image_recognition_service.dart';
import 'package:sikdanscan/data/services/proxy_client_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FoodImageRecognitionService', () {
    test('posts base64 image payload to the SikdanScan proxy', () async {
      final fakeApi = _FakeApiService(
        postData: {
          'summary': '김밥과 샐러드',
          'confidence': 0.91,
          'needsReview': false,
          'items': [
            {
              'name': '김밥',
              'calories': 420,
              'carbs': 68.0,
              'protein': 14.0,
              'fat': 11.0,
              'servingSize': '1줄',
              'confidence': 0.9,
            },
          ],
        },
      );
      final service = FoodImageRecognitionService(
        apiService: fakeApi,
        proxyConfig: ProxyClientConfig(
          baseUrl: 'https://proxy.example.com/',
          clientToken: 'client-token',
        ),
      );

      final result = await service.recognizeImageBytes(
        Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/png',
        locale: 'en',
      );

      expect(fakeApi.lastPostBaseUrl, 'https://proxy.example.com');
      expect(fakeApi.lastPostPath, '/v1/foods/recognize');
      expect(fakeApi.lastPostHeaders?['Authorization'], 'Bearer client-token');
      expect(fakeApi.lastPostData?['mimeType'], 'image/png');
      expect(fakeApi.lastPostData?['locale'], 'en');
      expect(fakeApi.lastPostData?['imageBase64'], base64Encode([1, 2, 3]));
      expect(result.summary, '김밥과 샐러드');
      expect(result.confidence, 0.91);
      expect(result.needsReview, isFalse);
      expect(result.items.single.name, '김밥');
    });

    test('requires a configured proxy', () async {
      final service = FoodImageRecognitionService(
        apiService: _FakeApiService(postData: {}),
        proxyConfig: ProxyClientConfig(),
      );

      expect(
        service.recognizeImageBytes(Uint8List.fromList([1])),
        throwsA(isA<FoodImageRecognitionException>()),
      );
    });

    test('rejects empty and oversized images before network calls', () async {
      final fakeApi = _FakeApiService(postData: {});
      final service = FoodImageRecognitionService(
        apiService: fakeApi,
        proxyConfig: ProxyClientConfig(baseUrl: 'https://proxy.example.com'),
        maxImageBytes: 2,
      );

      expect(
        service.recognizeImageBytes(Uint8List(0)),
        throwsA(isA<FoodImageRecognitionException>()),
      );
      expect(
        service.recognizeImageBytes(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<FoodImageRecognitionException>()),
      );
      expect(fakeApi.postCount, 0);
    });

    test('maps proxy connection failures to an actionable message', () async {
      final service = FoodImageRecognitionService(
        apiService: _FakeApiService(
          postError: DioException(
            requestOptions: RequestOptions(path: '/v1/foods/recognize'),
            type: DioExceptionType.connectionError,
            error: ApiError(message: '인터넷 연결을 확인해주세요.', code: 'NO_CONNECTION'),
          ),
        ),
        proxyConfig: ProxyClientConfig(baseUrl: 'http://localhost:8080'),
      );

      expect(
        service.recognizeImageBytes(Uint8List.fromList([1, 2, 3])),
        throwsA(
          isA<FoodImageRecognitionException>().having(
            (error) => error.message,
            'message',
            contains('프록시'),
          ),
        ),
      );
    });

    test('rejects unsupported HEIC payloads before network calls', () async {
      final fakeApi = _FakeApiService(postData: {});
      final service = FoodImageRecognitionService(
        apiService: fakeApi,
        proxyConfig: ProxyClientConfig(baseUrl: 'http://localhost:8080'),
      );

      expect(
        service.recognizeImageBytes(
          Uint8List.fromList([1, 2, 3]),
          mimeType: 'image/heic',
        ),
        throwsA(
          isA<FoodImageRecognitionException>().having(
            (error) => error.message,
            'message',
            contains('HEIC'),
          ),
        ),
      );
      expect(fakeApi.postCount, 0);
    });

    test('maps upstream image request failures to retry guidance', () async {
      final requestOptions = RequestOptions(path: '/v1/foods/recognize');
      final service = FoodImageRecognitionService(
        apiService: _FakeApiService(
          postError: DioException(
            requestOptions: requestOptions,
            response: Response<Map<String, dynamic>>(
              requestOptions: requestOptions,
              statusCode: 422,
              data: {'error': 'Unsupported image format.'},
            ),
            type: DioExceptionType.badResponse,
            error: ApiError(message: '서버 오류가 발생했습니다.', code: 'SERVER_ERROR'),
          ),
        ),
        proxyConfig: ProxyClientConfig(baseUrl: 'http://localhost:8080'),
      );

      expect(
        service.recognizeImageBytes(
          Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x00]),
        ),
        throwsA(
          isA<FoodImageRecognitionException>().having(
            (error) => error.message,
            'message',
            contains('JPG 또는 PNG'),
          ),
        ),
      );
    });
  });
}

class _FakeApiService implements ApiService {
  _FakeApiService({this.postData, this.postError});

  final Object? postData;
  final Object? postError;
  int postCount = 0;
  String? lastPostBaseUrl;
  String? lastPostPath;
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
    throw UnimplementedError();
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

    final error = postError;
    if (error != null) throw error;

    return Response<T>(
      data: postData as T?,
      requestOptions: RequestOptions(path: '$baseUrl$path'),
    );
  }
}
