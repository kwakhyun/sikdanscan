import 'chat_message.dart';
import 'daily_health.dart';
import 'meal_record.dart';
import 'user_profile.dart';
import 'weight_record.dart';

typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

class PersistedModelDecoder {
  const PersistedModelDecoder._();

  static UserProfile? userProfile(Map<String, dynamic>? json) {
    return _decode(json, UserProfile.fromJson);
  }

  static WeightRecord? weightRecord(Map<String, dynamic>? json) {
    return _decode(json, WeightRecord.fromJson);
  }

  static MealRecord? mealRecord(Map<String, dynamic>? json) {
    return _decode(json, MealRecord.fromJson);
  }

  static DailyHealth? dailyHealth(Map<String, dynamic>? json) {
    return _decode(json, DailyHealth.fromJson);
  }

  static ChatMessage? chatMessage(Map<String, dynamic>? json) {
    return _decode(json, ChatMessage.fromJson);
  }

  static List<T> list<T>(
    Iterable<Map<String, dynamic>> items,
    T? Function(Map<String, dynamic> json) decode,
  ) {
    return items.map(decode).whereType<T>().toList();
  }

  static T? _decode<T>(Map<String, dynamic>? json, JsonFactory<T> factory) {
    if (json == null) return null;

    try {
      return factory(json);
    } catch (_) {
      return null;
    }
  }
}
