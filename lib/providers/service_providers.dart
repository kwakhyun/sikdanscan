import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/ai_chat_service.dart';
import '../data/services/api_service.dart';
import '../data/services/food_api_service.dart';
import '../data/services/food_image_recognition_service.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/proxy_client_config.dart';
import '../data/services/proxy_status_service.dart';
import '../data/services/supabase_backend_service.dart';
import '../data/services/supabase_bootstrap.dart';
import '../data/services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final service = ApiService();
  ref.onDispose(service.close);
  return service;
});

final proxyClientConfigProvider = Provider<ProxyClientConfig>((ref) {
  return ProxyClientConfig.fromEnvironment(allowDebugFallback: true);
});

final aiChatServiceProvider = Provider<AiChatService>((ref) {
  return AiChatService(
    apiService: ref.watch(apiServiceProvider),
    proxyConfig: ref.watch(proxyClientConfigProvider),
  );
});

final foodApiServiceProvider = Provider<FoodApiService>((ref) {
  return FoodApiService(
    apiService: ref.watch(apiServiceProvider),
    proxyConfig: ref.watch(proxyClientConfigProvider),
  );
});

final foodImageRecognitionServiceProvider =
    Provider<FoodImageRecognitionService>((ref) {
      return FoodImageRecognitionService(
        apiService: ref.watch(apiServiceProvider),
        proxyConfig: ref.watch(proxyClientConfigProvider),
      );
    });

final proxyStatusServiceProvider = Provider<ProxyStatusService>((ref) {
  return ProxyStatusService(
    apiService: ref.watch(apiServiceProvider),
    config: ref.watch(proxyClientConfigProvider),
  );
});

final supabaseConfigProvider = Provider<SupabaseConfig>((ref) {
  return SupabaseConfig.fromEnvironment();
});

final supabaseBackendServiceProvider = Provider<SupabaseBackendService>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  final client = config.isConfigured && SupabaseBootstrap.isInitialized
      ? Supabase.instance.client
      : null;

  return SupabaseBackendService(config: config, client: client);
});

final supabaseConfiguredProvider = Provider<bool>((ref) {
  return ref.watch(supabaseBackendServiceProvider).isConfigured;
});

final proxyConnectionStatusProvider =
    FutureProvider.autoDispose<ProxyConnectionStatus>((ref) {
      return ref.watch(proxyStatusServiceProvider).checkStatus();
    });
