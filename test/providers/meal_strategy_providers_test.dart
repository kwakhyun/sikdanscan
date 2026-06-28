import 'package:flutter_test/flutter_test.dart';
import 'package:sikdanscan/data/models/meal_record.dart';
import 'package:sikdanscan/data/models/user_profile.dart';
import 'package:sikdanscan/features/dashboard/providers/meal_strategy_providers.dart';

void main() {
  group('MealStrategyBuilder', () {
    test('returns onboarding strategy when meals are empty', () {
      final strategy = MealStrategyBuilder.build(
        profile: UserProfile.defaultProfile(),
        meals: const [],
      );

      expect(strategy.alertLevel, StrategyAlertLevel.empty);
      expect(strategy.title, contains('첫 식사'));
      expect(strategy.goal, WellnessGoal.balanced);
    });

    test('returns English onboarding strategy for English locale', () {
      final strategy = MealStrategyBuilder.build(
        profile: UserProfile.defaultProfile(),
        meals: const [],
        locale: 'en',
      );

      expect(strategy.alertLevel, StrategyAlertLevel.empty);
      expect(strategy.title, contains('Scan'));
      expect(strategy.primaryAction, contains('photo'));
    });

    test('creates skin-health correction strategy for high carb meals', () {
      final profile = UserProfile.defaultProfile().copyWith(
        wellnessGoal: WellnessGoal.skinHealth,
      );
      final strategy = MealStrategyBuilder.build(
        profile: profile,
        meals: [
          MealRecord(
            id: '1',
            date: DateTime(2026, 1, 1, 12),
            mealType: MealType.lunch,
            name: '파스타와 음료',
            calories: 850,
            carbs: 130,
            protein: 18,
            fat: 22,
          ),
        ],
      );

      expect(strategy.goal, WellnessGoal.skinHealth);
      expect(strategy.alertLevel, StrategyAlertLevel.watch);
      expect(strategy.primaryAction, contains('녹황색 채소'));
    });

    test('prioritizes protein gap for muscle goal', () {
      final profile = UserProfile.defaultProfile().copyWith(
        wellnessGoal: WellnessGoal.muscle,
        currentWeight: 70,
      );
      final strategy = MealStrategyBuilder.build(
        profile: profile,
        meals: [
          MealRecord(
            id: '1',
            date: DateTime(2026, 1, 1, 8),
            mealType: MealType.breakfast,
            name: '토스트',
            calories: 320,
            carbs: 48,
            protein: 8,
            fat: 10,
          ),
        ],
      );

      expect(strategy.goal, WellnessGoal.muscle);
      expect(strategy.title, contains('단백질'));
      expect(strategy.alertLevel, StrategyAlertLevel.watch);
    });
  });
}
