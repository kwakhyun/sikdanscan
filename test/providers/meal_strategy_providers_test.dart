import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sikdanscan/data/models/meal_record.dart';
import 'package:sikdanscan/data/models/user_profile.dart';
import 'package:sikdanscan/features/dashboard/providers/meal_strategy_providers.dart';
import 'package:sikdanscan/l10n/generated/app_localizations.dart';

void main() {
  final ko = lookupAppLocalizations(const Locale('ko'));
  final en = lookupAppLocalizations(const Locale('en'));

  MealRecord meal({
    required int calories,
    required double carbs,
    required double protein,
    required double fat,
  }) {
    return MealRecord(
      id: 'm_$calories',
      date: DateTime(2026, 1, 1, 12),
      mealType: MealType.lunch,
      name: 'meal',
      calories: calories,
      carbs: carbs,
      protein: protein,
      fat: fat,
    );
  }

  group('MealStrategyBuilder', () {
    test('returns onboarding strategy when meals are empty', () {
      final strategy = MealStrategyBuilder.build(
        profile: UserProfile.defaultProfile(),
        meals: const [],
      );

      expect(strategy.alertLevel, StrategyAlertLevel.empty);
      expect(strategy.title(ko), contains('첫 식사'));
      expect(strategy.goal, WellnessGoal.balanced);
      expect(strategy.factors, isEmpty);
    });

    test('renders the same strategy in English', () {
      final strategy = MealStrategyBuilder.build(
        profile: UserProfile.defaultProfile(),
        meals: const [],
      );

      expect(strategy.title(en), contains('Scan'));
      expect(strategy.primaryAction(en), contains('photo'));
      expect(strategy.summary(en), contains('Balanced care'));
    });

    test('creates skin-health correction strategy for high carb meals', () {
      final profile = UserProfile.defaultProfile().copyWith(
        wellnessGoal: WellnessGoal.skinHealth,
      );
      final strategy = MealStrategyBuilder.build(
        profile: profile,
        meals: [meal(calories: 850, carbs: 130, protein: 18, fat: 22)],
      );

      expect(strategy.goal, WellnessGoal.skinHealth);
      expect(strategy.alertLevel, StrategyAlertLevel.watch);
      expect(strategy.primaryAction(ko), contains('녹황색 채소'));
      expect(strategy.primaryAction(en), contains('leafy greens'));
    });

    test('prioritizes protein gap for muscle goal', () {
      final profile = UserProfile.defaultProfile().copyWith(
        wellnessGoal: WellnessGoal.muscle,
        currentWeight: 70,
      );
      final strategy = MealStrategyBuilder.build(
        profile: profile,
        meals: [meal(calories: 320, carbs: 48, protein: 8, fat: 10)],
      );

      expect(strategy.goal, WellnessGoal.muscle);
      expect(strategy.title(ko), contains('단백질'));
      expect(strategy.summary(en), contains('8g'));
      expect(strategy.alertLevel, StrategyAlertLevel.watch);
    });

    test('every goal produces goal-specific English text', () {
      final english = <String>{};
      for (final goal in WellnessGoal.values) {
        final strategy = MealStrategyBuilder.build(
          profile: UserProfile.defaultProfile().copyWith(
            wellnessGoal: goal,
            currentWeight: 65,
            dailyCalorieGoal: 1800,
          ),
          meals: [meal(calories: 900, carbs: 140, protein: 20, fat: 25)],
        );
        english.add(strategy.title(en));
        for (final action in strategy.actions) {
          expect(action(en), isNot(matches(RegExp('[가-힣]'))));
        }
      }
      // Previously five goals fell back to one shared English message.
      expect(english.length, WellnessGoal.values.length);
    });

    test('score equals the sum of its factors', () {
      final strategy = MealStrategyBuilder.build(
        profile: UserProfile.defaultProfile().copyWith(
          wellnessGoal: WellnessGoal.weightLoss,
          currentWeight: 70,
          dailyCalorieGoal: 1600,
        ),
        meals: [meal(calories: 2000, carbs: 200, protein: 40, fat: 90)],
      );

      final total = strategy.factors.fold(0, (sum, f) => sum + f.earned);
      expect(strategy.score, total);
      expect(strategy.alertLevel, StrategyAlertLevel.urgent);
      expect(strategy.factors.any((f) => !f.isMet), isTrue);
    });
  });
}
