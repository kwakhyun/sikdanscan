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
    final configuredBaseUrl = _readValue(
      ApiConstants.proxyBaseUrlEnv,
      baseUrlOverride,
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

    try {
      return dotenv.env[envKey]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  static String _normalizeBaseUrl(String value) {
    return value.trim().replaceAll(RegExp(r'/+$'), '');
  }

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
