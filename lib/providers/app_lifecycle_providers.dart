import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/meal_image_store.dart';
import '../features/auth/providers/auth_providers.dart';
import '../features/profile/providers/profile_providers.dart';
import 'service_providers.dart';
import 'user_session.dart';

/// Clears every local record, photo and preference. When signed in, the account is
/// signed out first so the next sign-in does not merge the wiped device back.
final dataResetProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final backend = ref.read(supabaseBackendServiceProvider);
    if (backend.isConfigured && backend.currentUser != null) {
      try {
        await ref.read(supabaseAuthControllerProvider.notifier).signOut();
      } catch (_) {
        // Local reset still proceeds when sign-out fails (e.g. offline).
      }
    }

    final storage = ref.read(localStorageServiceProvider);
    await storage.clearAll();
    // Photos live outside Hive; the reset promises a clean device.
    await MealImageStore.clearAll();
    invalidateUserScopedState(ref);
    ref.invalidate(themePreferenceProvider);
    ref.invalidate(aiDataConsentProvider);
    ref.invalidate(languageProvider);
  };
});
