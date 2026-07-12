import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import 'api_service.dart';
import 'proxy_client_config.dart';

enum ProxyConnectionState { notConfigured, connected, unavailable }

/// Fine-grained reason for the current proxy status, so the UI can map the
/// status to a localized message instead of relying on [ProxyConnectionStatus.message].
enum ProxyStatusDetail {
  notConfigured,
  connected,
  unexpectedResponse,
  invalidToken,
  healthEndpointMissing,
  serverError,
  unreachable,
}

class ProxyConnectionStatus {
  const ProxyConnectionStatus._({
    required this.state,
    required this.detail,
    required this.message,
    this.statusCode,
  });

  factory ProxyConnectionStatus.notConfigured() {
    return const ProxyConnectionStatus._(
      state: ProxyConnectionState.notConfigured,
      detail: ProxyStatusDetail.notConfigured,
      message: '프록시 URL이 설정되지 않았습니다.',
    );
  }

  factory ProxyConnectionStatus.connected() {
    return const ProxyConnectionStatus._(
      state: ProxyConnectionState.connected,
      detail: ProxyStatusDetail.connected,
      message: '프록시가 정상 응답했습니다.',
    );
  }

  factory ProxyConnectionStatus.unavailable({
    required String message,
    ProxyStatusDetail detail = ProxyStatusDetail.unreachable,
    int? statusCode,
  }) {
    return ProxyConnectionStatus._(
      state: ProxyConnectionState.unavailable,
      detail: detail,
      message: message,
      statusCode: statusCode,
    );
  }

  final ProxyConnectionState state;
  final ProxyStatusDetail detail;
  final String message;
  final int? statusCode;

  bool get isConnected => state == ProxyConnectionState.connected;
  bool get isConfigured => state != ProxyConnectionState.notConfigured;
}

class ProxyStatusService {
  ProxyStatusService({ApiService? apiService, ProxyClientConfig? config})
    : _apiService = apiService ?? ApiService(),
      _config = config ?? ProxyClientConfig.fromEnvironment();

  final ApiService _apiService;
  final ProxyClientConfig _config;

  Future<ProxyConnectionStatus> checkStatus() async {
    if (!_config.isConfigured) {
      return ProxyConnectionStatus.notConfigured();
    }

    try {
      final response = await _apiService.get<Object>(
        _config.baseUrl,
        ApiConstants.proxyHealthEndpoint,
        headers: _config.authHeaders,
      );

      final data = _asStringMap(response.data);
      if (data?['status'] == 'ok') {
        return ProxyConnectionStatus.connected();
      }

      return ProxyConnectionStatus.unavailable(
        message: '프록시가 예상과 다른 응답을 반환했습니다.',
        detail: ProxyStatusDetail.unexpectedResponse,
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      final detail = _dioDetail(error);
      return ProxyConnectionStatus.unavailable(
        message: _friendlyDioMessage(error, detail),
        detail: detail,
        statusCode: error.response?.statusCode,
      );
    } catch (_) {
      return ProxyConnectionStatus.unavailable(message: '프록시에 연결할 수 없습니다.');
    }
  }

  ProxyStatusDetail _dioDetail(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return ProxyStatusDetail.invalidToken;
    }
    if (statusCode == 404) {
      return ProxyStatusDetail.healthEndpointMissing;
    }
    if (statusCode != null && statusCode >= 500) {
      return ProxyStatusDetail.serverError;
    }
    return ProxyStatusDetail.unreachable;
  }

  String _friendlyDioMessage(DioException error, ProxyStatusDetail detail) {
    switch (detail) {
      case ProxyStatusDetail.invalidToken:
        return '프록시 인증 토큰을 확인해주세요.';
      case ProxyStatusDetail.healthEndpointMissing:
        return '프록시 헬스체크 엔드포인트를 찾을 수 없습니다.';
      case ProxyStatusDetail.serverError:
        return '프록시 서버가 정상 응답하지 않습니다.';
      default:
        final apiError = error.error;
        if (apiError is ApiError) return apiError.message;
        return '프록시에 연결할 수 없습니다.';
    }
  }
}

Map<String, dynamic>? _asStringMap(Object? data) {
  if (data is! Map) return null;
  return data.map((key, value) => MapEntry(key.toString(), value));
}
