import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/constants/api_constants.dart';

class ProxyClientConfig {
  const ProxyClientConfig._({required this.baseUrl, required this.clientToken});

  factory ProxyClientConfig({String? baseUrl, String? clientToken}) {
    return ProxyClientConfig._(
      baseUrl: _normalizeBaseUrl(baseUrl ?? ''),
      clientToken: clientToken?.trim() ?? '',
    );
  }

  factory ProxyClientConfig.fromEnvironment({
    String? baseUrlOverride,
    String? clientTokenOverride,
    bool allowDebugFallback = false,
  }) {
    final configuredBaseUrl = _releaseSafeBaseUrl(
      _readValue(ApiConstants.proxyBaseUrlEnv, baseUrlOverride),
    );

    return ProxyClientConfig(
      baseUrl: configuredBaseUrl.isNotEmpty
          ? configuredBaseUrl
          : _debugFallbackBaseUrl(allowDebugFallback),
      clientToken: _readValue(
        ApiConstants.proxyClientTokenEnv,
        clientTokenOverride,
      ),
    );
  }

  final String baseUrl;
  final String clientToken;

  bool get isConfigured => baseUrl.isNotEmpty;

  Map<String, dynamic>? get authHeaders {
    if (clientToken.isEmpty) return null;
    return {'Authorization': 'Bearer $clientToken'};
  }

  static String _readValue(String envKey, String? override) {
    if (override != null) return override.trim();

    final compileTimeValue = _compileTimeValue(envKey);
    if (compileTimeValue.isNotEmpty) return compileTimeValue;

    try {
      return dotenv.env[envKey]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  static String _normalizeBaseUrl(String value) {
    return value.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static String _releaseSafeBaseUrl(String value) {
    final normalized = _normalizeBaseUrl(value);
    if (normalized.isEmpty || !kReleaseMode) return normalized;

    final uri = Uri.tryParse(normalized);
    if (uri != null && uri.scheme == 'https') return normalized;

    return '';
  }

  static String _compileTimeValue(String envKey) {
    return switch (envKey) {
      ApiConstants.proxyBaseUrlEnv => _proxyBaseUrlFromDefine,
      ApiConstants.proxyClientTokenEnv => _proxyClientTokenFromDefine,
      _ => '',
    };
  }

  static const _proxyBaseUrlFromDefine = String.fromEnvironment(
    'SIKDANSCAN_PROXY_BASE_URL',
  );
  static const _proxyClientTokenFromDefine = String.fromEnvironment(
    'SIKDANSCAN_PROXY_CLIENT_TOKEN',
  );

  static String _debugFallbackBaseUrl(bool allowDebugFallback) {
    if (!allowDebugFallback || !kDebugMode) return '';
    if (kIsWeb) return 'http://localhost:8080';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:8080',
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.linux ||
      TargetPlatform.windows => 'http://localhost:8080',
      TargetPlatform.fuchsia => '',
    };
  }
}
