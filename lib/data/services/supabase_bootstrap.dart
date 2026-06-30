import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

class SupabaseBootstrap {
  const SupabaseBootstrap._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<bool> initializeFromEnvironment() async {
    return initialize(SupabaseConfig.fromEnvironment());
  }

  static Future<bool> initialize(SupabaseConfig config) async {
    if (!config.isConfigured) return false;
    if (_initialized) return true;

    await Supabase.initialize(
      url: config.url,
      publishableKey: config.publishableKey,
      debug: kDebugMode,
    );
    _initialized = true;
    return true;
  }
}
