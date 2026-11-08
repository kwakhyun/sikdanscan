import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/chat/providers/chat_providers.dart';
import '../features/dashboard/providers/daily_health_providers.dart';
import '../features/meal/providers/meal_capture_providers.dart';
import '../features/meal/providers/meal_providers.dart';
import '../features/profile/providers/profile_providers.dart';

/// Re-creates every provider that holds the signed-in person's data, after
/// that data was cleared from storage (data reset, another account signing
/// in). One list, so the two flows cannot drift apart.
void invalidateUserScopedState(Ref ref) {
  ref
    ..invalidate(mealCaptureProvider)
    ..invalidate(mealRecordsProvider)
    ..invalidate(weightRecordsProvider)
    ..invalidate(dailyHealthProvider)
    ..invalidate(chatMessagesProvider)
    ..invalidate(chatLoadingProvider)
    ..invalidate(coachConnectionProvider)
    ..invalidate(userProfileProvider)
    ..invalidate(aiDataConsentProvider);
}
