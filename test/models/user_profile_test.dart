import 'package:flutter_test/flutter_test.dart';
import 'package:sikdanscan/data/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('defaultProfile starts as an unconfigured onboarding profile', () {
      final profile = UserProfile.defaultProfile();

      expect(profile.onboardingCompleted, false);
      expect(profile.name, isEmpty);
      expect(profile.displayName, '식단스캔 사용자');
      expect(profile.age, 0);
      expect(profile.height, 0);
      expect(profile.currentWeight, 0);
      expect(profile.targetWeight, 0);
      expect(profile.dailyCalorieGoal, 0);
      expect(profile.dailyWaterGoalMl, 0);
      expect(profile.dailyStepGoal, 0);
      expect(profile.wellnessGoal, WellnessGoal.balanced);
      expect(profile.activityLevel, ActivityLevel.moderate);
      expect(profile.avatarImagePath, isNull);
    });

    test('wellness goal and activity level survive JSON roundtrip', () {
      final profile = UserProfile.defaultProfile().copyWith(
        wellnessGoal: WellnessGoal.glucose,
        activityLevel: ActivityLevel.active,
        onboardingCompleted: true,
        avatarImagePath: '/tmp/profile.jpg',
      );

      final restored = UserProfile.fromJson(profile.toJson());

      expect(restored.wellnessGoal, WellnessGoal.glucose);
      expect(restored.activityLevel, ActivityLevel.active);
      expect(restored.onboardingCompleted, true);
      expect(restored.avatarImagePath, '/tmp/profile.jpg');
    });

    test(
      'recommended calorie goal is calculated from body metrics and goal',
      () {
        const profile = UserProfile(
          name: 'Test',
          age: 30,
          height: 165,
          currentWeight: 68,
          targetWeight: 68,
          gender: 'female',
          wellnessGoal: WellnessGoal.weightLoss,
          activityLevel: ActivityLevel.moderate,
        );

        expect(profile.basalMetabolicRate.round(), 1400);
        expect(profile.maintenanceCalorieEstimate, 2030);
        expect(profile.goalCalorieAdjustment, -300);
        expect(profile.recommendedDailyCalorieGoal, 1730);
        expect(profile.recommendedWaterGoalMl, 2000);
        expect(profile.calorieGoalBasisSummary, contains('BMR'));
      },
    );

    test('BMI calculation is correct', () {
      final profile = UserProfile(
        name: 'Test',
        age: 25,
        height: 170,
        currentWeight: 70,
        targetWeight: 60,
      );

      // BMI = 70 / (1.7 * 1.7) ≈ 24.22
      expect(profile.bmi, closeTo(24.22, 0.1));
    });

    test('BMI category returns correct label', () {
      expect(
        UserProfile(
          name: 'A',
          age: 20,
          height: 170,
          currentWeight: 50,
          targetWeight: 45,
        ).bmiCategory,
        '저체중',
      );
      expect(
        UserProfile(
          name: 'B',
          age: 20,
          height: 170,
          currentWeight: 65,
          targetWeight: 60,
        ).bmiCategory,
        '정상',
      );
      expect(
        UserProfile(
          name: 'C',
          age: 20,
          height: 170,
          currentWeight: 72,
          targetWeight: 60,
        ).bmiCategory,
        '과체중',
      );
      expect(
        UserProfile(
          name: 'D',
          age: 20,
          height: 170,
          currentWeight: 85,
          targetWeight: 70,
        ).bmiCategory,
        '비만',
      );
      expect(
        UserProfile(
          name: 'E',
          age: 20,
          height: 170,
          currentWeight: 110,
          targetWeight: 80,
        ).bmiCategory,
        '고도비만',
      );
    });

    test('weightToLose calculates correctly', () {
      final profile = UserProfile(
        name: 'Test',
        age: 25,
        height: 170,
        currentWeight: 75,
        targetWeight: 65,
      );

      expect(profile.weightToLose, 10);
    });

    test(
      'progressPercentFrom calculates goal progress from initial weight',
      () {
        final profile = UserProfile(
          name: 'Test',
          age: 25,
          height: 170,
          startingWeight: 80,
          currentWeight: 75,
          targetWeight: 70,
        );

        expect(profile.progressPercent, 0.5);
        expect(
          profile.progressPercentFrom(initialWeight: 80, currentWeight: 72),
          0.8,
        );
      },
    );

    test('progressPercentFrom supports weight gain goals', () {
      final profile = UserProfile(
        name: 'Test',
        age: 25,
        height: 170,
        startingWeight: 55,
        currentWeight: 57.5,
        targetWeight: 60,
      );

      expect(profile.progressPercent, 0.5);
    });

    test('daysRemaining normalizes dates to whole days', () {
      final profile = UserProfile(
        name: 'Test',
        age: 25,
        height: 170,
        currentWeight: 70,
        targetWeight: 65,
        targetDate: DateTime(2026, 7, 1, 23, 59),
      );

      expect(profile.daysRemaining(now: DateTime(2026, 6, 26, 1, 30)), 5);
    });

    test('invalid height returns unknown BMI category instead of throwing', () {
      final profile = UserProfile(
        name: 'Test',
        age: 25,
        height: 0,
        currentWeight: 70,
        targetWeight: 65,
      );

      expect(profile.bmi, 0);
      expect(profile.bmiCategory, '알 수 없음');
    });

    test('copyWith creates new instance with updated fields', () {
      final profile = UserProfile.defaultProfile();
      final updated = profile.copyWith(name: '새 이름', currentWeight: 65);

      expect(updated.name, '새 이름');
      expect(updated.currentWeight, 65);
      expect(updated.height, profile.height); // 변경하지 않은 필드 유지
      expect(updated.age, profile.age);
    });

    test('toJson and fromJson roundtrip', () {
      final profile = UserProfile.defaultProfile();
      final json = profile.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.name, profile.name);
      expect(restored.age, profile.age);
      expect(restored.height, profile.height);
      expect(restored.startingWeight, profile.startingWeight);
      expect(restored.currentWeight, profile.currentWeight);
      expect(restored.targetWeight, profile.targetWeight);
      expect(restored.gender, profile.gender);
      expect(restored.dailyCalorieGoal, profile.dailyCalorieGoal);
      expect(restored.activityLevel, profile.activityLevel);
      expect(restored.onboardingCompleted, profile.onboardingCompleted);
      expect(restored.avatarImagePath, profile.avatarImagePath);
    });
  });
}
