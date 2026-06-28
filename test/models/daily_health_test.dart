import 'package:flutter_test/flutter_test.dart';
import 'package:sikdanscan/data/models/daily_health.dart';

void main() {
  group('DailyHealth', () {
    test('creates with default values', () {
      final health = DailyHealth(id: 'test', date: DateTime(2026, 2, 12));

      expect(health.waterMl, 0);
      expect(health.steps, 0);
      expect(health.sleepHours, 0);
      expect(health.exerciseMinutes, 0);
      expect(health.mood, isNull);
    });

    test('waterCups calculates correctly', () {
      final health = DailyHealth(
        id: 'test',
        date: DateTime(2026, 2, 12),
        waterMl: 1500,
      );

      expect(health.waterCups, 6); // 1500 / 250 = 6
    });

    test('waterLiters calculates correctly', () {
      final health = DailyHealth(
        id: 'test',
        date: DateTime(2026, 2, 12),
        waterMl: 2000,
      );

      expect(health.waterLiters, 2.0);
    });

    test('copyWith updates only specified fields', () {
      final health = DailyHealth(
        id: 'test',
        date: DateTime(2026, 2, 12),
        waterMl: 1000,
        steps: 5000,
        sleepHours: 7.0,
      );

      final updated = health.copyWith(waterMl: 1500, mood: '좋음');

      expect(updated.waterMl, 1500);
      expect(updated.mood, '좋음');
      expect(updated.steps, 5000); // unchanged
      expect(updated.sleepHours, 7.0); // unchanged
    });

    test('toJson and fromJson roundtrip', () {
      final health = DailyHealth(
        id: 'roundtrip',
        date: DateTime(2026, 2, 12),
        waterMl: 1800,
        steps: 8500,
        sleepHours: 7.5,
        exerciseMinutes: 45,
        mood: '활기',
      );

      final json = health.toJson();
      final restored = DailyHealth.fromJson(json);

      expect(restored.id, health.id);
      expect(restored.waterMl, health.waterMl);
      expect(restored.steps, health.steps);
      expect(restored.sleepHours, health.sleepHours);
      expect(restored.exerciseMinutes, health.exerciseMinutes);
      expect(restored.mood, health.mood);
    });
  });
}
