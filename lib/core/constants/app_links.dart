import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Public links configured per deployment.
class AppLinks {
  const AppLinks._();

  static const privacyPolicyEnv = 'SIKDANSCAN_PRIVACY_POLICY_URL';
  static const _privacyPolicyFromDefine = String.fromEnvironment(
    privacyPolicyEnv,
  );

  /// Hosted privacy policy (HTTPS only), or `null` when not configured.
  static Uri? get privacyPolicy {
    var value = _privacyPolicyFromDefine.trim();
    if (value.isEmpty) {
      try {
        value = dotenv.env[privacyPolicyEnv]?.trim() ?? '';
      } catch (_) {
        value = '';
      }
    }
    final uri = Uri.tryParse(value);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
        ? uri
        : null;
  }
}
