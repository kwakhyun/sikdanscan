import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/providers/auth_providers.dart';
import '../features/chat/providers/chat_providers.dart';
import '../features/dashboard/providers/daily_health_providers.dart';
import '../features/meal/providers/meal_capture_providers.dart';
import '../features/meal/providers/meal_providers.dart';
import '../features/profile/providers/profile_providers.dart';
import 'service_providers.dart';

/// Clears every local record and preference. When signed in, the account is
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
    ref.invalidate(userProfileProvider);
    ref.invalidate(weightRecordsProvider);
    ref.invalidate(mealRecordsProvider);
    ref.invalidate(mealCaptureProvider);
    ref.invalidate(dailyHealthProvider);
    ref.invalidate(chatMessagesProvider);
    ref.invalidate(themePreferenceProvider);
    ref.invalidate(languageProvider);
  };
});
