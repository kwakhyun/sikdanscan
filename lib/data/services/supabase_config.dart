import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  const SupabaseConfig._({required this.url, required this.publishableKey});

  factory SupabaseConfig({String? url, String? publishableKey}) {
    return SupabaseConfig._(
      url: _releaseSafeUrl(url ?? ''),
      publishableKey: publishableKey?.trim() ?? '',
    );
  }

  factory SupabaseConfig.fromEnvironment({
    String? urlOverride,
    String? publishableKeyOverride,
  }) {
    final publishableKey = _readValue(
      _publishableKeyEnv,
      publishableKeyOverride,
    );

    return SupabaseConfig(
      url: _readValue(_urlEnv, urlOverride),
      publishableKey: publishableKey.isNotEmpty
          ? publishableKey
          : _readValue(_legacyAnonKeyEnv, null),
    );
  }

  static const _urlEnv = 'SUPABASE_URL';
  static const _publishableKeyEnv = 'SUPABASE_PUBLISHABLE_KEY';
  static const _legacyAnonKeyEnv = 'SUPABASE_ANON_KEY';

  static const _urlFromDefine = String.fromEnvironment('SUPABASE_URL');
  static const _publishableKeyFromDefine = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const _legacyAnonKeyFromDefine = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  final String url;
  final String publishableKey;

  bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static String _readValue(String envKey, String? override) {
    if (override != null) return override.trim();

    final compileTimeValue = switch (envKey) {
      _urlEnv => _urlFromDefine,
      _publishableKeyEnv => _publishableKeyFromDefine,
      _legacyAnonKeyEnv => _legacyAnonKeyFromDefine,
      _ => '',
    };
    if (compileTimeValue.isNotEmpty) return compileTimeValue.trim();

    try {
      return dotenv.env[envKey]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  static String _releaseSafeUrl(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'/+$'), '');
    if (normalized.isEmpty || !kReleaseMode) return normalized;

    final uri = Uri.tryParse(normalized);
    if (uri != null && uri.scheme == 'https') return normalized;

    return '';
  }
}
