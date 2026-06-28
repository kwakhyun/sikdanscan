import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sikdanscan/data/services/api_service.dart';
import 'package:sikdanscan/data/services/proxy_client_config.dart';
import 'package:sikdanscan/data/services/proxy_status_service.dart';

void main() {
  group('ProxyClientConfig', () {
    test('normalizes proxy base URL and builds bearer header', () {
      final config = ProxyClientConfig(
        baseUrl: ' https://proxy.example.com/// ',
        clientToken: ' token-123 ',
      );

      expect(config.baseUrl, 'https://proxy.example.com');
      expect(config.isConfigured, isTrue);
      expect(config.authHeaders, {'Authorization': 'Bearer token-123'});
    });

    test('omits auth headers when client token is not configured', () {
      final config = ProxyClientConfig(baseUrl: 'https://proxy.example.com');

      expect(config.authHeaders, isNull);
    });

    test('does not use debug fallback unless explicitly enabled', () {
      final config = ProxyClientConfig.fromEnvironment(baseUrlOverride: '');

      expect(config.isConfigured, isFalse);
    });

    test('uses a local debug fallback URL when enabled', () {
      final config = ProxyClientConfig.fromEnvironment(
        baseUrlOverride: '',
        allowDebugFallback: true,
      );

      expect(config.isConfigured, isTrue);
      expect(
        config.baseUrl,
        anyOf('http://localhost:8080', 'http://10.0.2.2:8080'),
      );
    });
  });

  group('ProxyStatusService', () {
    test(
      'returns notConfigured without calling network when URL is missing',
      () async {
        final fakeApi = FakeApiService(getData: {'status': 'ok'});
        final service = ProxyStatusService(
          apiService: fakeApi,
          config: ProxyClientConfig(),
        );

        final status = await service.checkStatus();

        expect(status.state, ProxyConnectionState.notConfigured);
        expect(fakeApi.getCount, 0);
      },
    );

    test('returns connected when health endpoint returns ok', () async {
      final fakeApi = FakeApiService(getData: {'status': 'ok'});
      final service = ProxyStatusService(
        apiService: fakeApi,
        config: ProxyClientConfig(baseUrl: 'https://proxy.example.com'),
      );

      final status = await service.checkStatus();

      expect(status.state, ProxyConnectionState.connected);
      expect(status.isConnected, isTrue);
      expect(fakeApi.lastGetPath, '/health');
    });

    test('forwards optional auth header to health endpoint', () async {
      final fakeApi = FakeApiService(getData: {'status': 'ok'});
      final service = ProxyStatusService(
        apiService: fakeApi,
        config: ProxyClientConfig(
          baseUrl: 'https://proxy.example.com',
          clientToken: 'client-token',
        ),
      );

      await service.checkStatus();

      expect(fakeApi.lastGetHeaders?['Authorization'], 'Bearer client-token');
    });

    test('returns unavailable when health payload is malformed', () async {
      final fakeApi = FakeApiService(getData: {'status': 'degraded'});
      final service = ProxyStatusService(
        apiService: fakeApi,
        config: ProxyClientConfig(baseUrl: 'https://proxy.example.com'),
      );

      final status = await service.checkStatus();

      expect(status.state, ProxyConnectionState.unavailable);
    });

    test('returns auth-focused message for 403 responses', () async {
      final requestOptions = RequestOptions(path: '/health');
      final fakeApi = FakeApiService(
        getError: DioException(
          requestOptions: requestOptions,
          response: Response<void>(
            statusCode: 403,
            requestOptions: requestOptions,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      final service = ProxyStatusService(
        apiService: fakeApi,
        config: ProxyClientConfig(baseUrl: 'https://proxy.example.com'),
      );

      final status = await service.checkStatus();

      expect(status.state, ProxyConnectionState.unavailable);
      expect(status.statusCode, 403);
      expect(status.message, contains('토큰'));
    });
  });
}

class FakeApiService implements ApiService {
  FakeApiService({this.getData, this.getError});

  final Object? getData;
  final Object? getError;
  int getCount = 0;
  String? lastGetBaseUrl;
  String? lastGetPath;
  Map<String, dynamic>? lastGetHeaders;

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

    final error = getError;
    if (error != null) throw error;

    return Response<T>(
      data: getData as T?,
      requestOptions: RequestOptions(path: '$baseUrl$path'),
      statusCode: 200,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String baseUrl,
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) {
    throw UnimplementedError('POST is not used by ProxyStatusService tests');
  }
}
