import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/chat/providers/chat_providers.dart';
import '../features/dashboard/providers/daily_health_providers.dart';
import '../features/meal/providers/meal_providers.dart';
import '../features/profile/providers/profile_providers.dart';
import 'service_providers.dart';

final dataResetProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.clearAll();
    ref.invalidate(userProfileProvider);
    ref.invalidate(weightRecordsProvider);
    ref.invalidate(mealRecordsProvider);
    ref.invalidate(dailyHealthProvider);
    ref.invalidate(chatMessagesProvider);
    ref.invalidate(notificationsEnabledProvider);
    ref.invalidate(darkModeProvider);
    ref.invalidate(languageProvider);
  };
});
