import 'package:flutter/widgets.dart';

import '../data/models/meal_record.dart';
import '../data/models/user_profile.dart';
import 'generated/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension WellnessGoalLocalizations on WellnessGoal {
  String labelOf(AppLocalizations l10n) {
    return switch (this) {
      WellnessGoal.balanced => l10n.goalBalanced,
      WellnessGoal.weightLoss => l10n.goalWeightLoss,
      WellnessGoal.skinHealth => l10n.goalSkinHealth,
      WellnessGoal.digestion => l10n.goalDigestion,
      WellnessGoal.energy => l10n.goalEnergy,
      WellnessGoal.muscle => l10n.goalMuscle,
      WellnessGoal.glucose => l10n.goalGlucose,
    };
  }

  String descriptionOf(AppLocalizations l10n) {
    return switch (this) {
      WellnessGoal.balanced => l10n.goalBalancedDescription,
      WellnessGoal.weightLoss => l10n.goalWeightLossDescription,
      WellnessGoal.skinHealth => l10n.goalSkinHealthDescription,
      WellnessGoal.digestion => l10n.goalDigestionDescription,
      WellnessGoal.energy => l10n.goalEnergyDescription,
      WellnessGoal.muscle => l10n.goalMuscleDescription,
      WellnessGoal.glucose => l10n.goalGlucoseDescription,
    };
  }
}

extension UserProfileLocalizations on UserProfile {
  String bmiCategoryOf(AppLocalizations l10n) {
    if (bmi <= 0) return l10n.bmiUnknown;
    if (bmi < 18.5) return l10n.bmiUnderweight;
    if (bmi < 23) return l10n.bmiNormal;
    if (bmi < 25) return l10n.bmiOverweight;
    if (bmi < 30) return l10n.bmiObese;
    return l10n.bmiSeverelyObese;
  }

  String calorieGoalBasisSummaryOf(AppLocalizations l10n) {
    if (!hasBodyMetrics || maintenanceCalorieEstimate <= 0) {
      return l10n.onboardingCheckInputs;
    }

    final adjustment = goalCalorieAdjustment;
    final adjustmentText = adjustment == 0
        ? l10n.calorieBasisNoAdjustment
        : l10n.calorieBasisAdjustment(
            '${adjustment > 0 ? '+' : ''}$adjustment',
          );
    return 'BMR ${basalMetabolicRate.round()} kcal × ${activityLevel.labelOf(l10n)} ${activityLevel.factor.toStringAsFixed(2)} · $adjustmentText';
  }
}

extension MealTypeLocalizations on MealType {
  String labelOf(AppLocalizations l10n) {
    return switch (this) {
      MealType.breakfast => l10n.mealTypeBreakfast,
      MealType.lunch => l10n.mealTypeLunch,
      MealType.dinner => l10n.mealTypeDinner,
      MealType.snack => l10n.mealTypeSnack,
    };
  }
}

extension ActivityLevelLocalizations on ActivityLevel {
  String labelOf(AppLocalizations l10n) {
    return switch (this) {
      ActivityLevel.light => l10n.activityLight,
      ActivityLevel.moderate => l10n.activityModerate,
      ActivityLevel.active => l10n.activityActive,
    };
  }

  String descriptionOf(AppLocalizations l10n) {
    return switch (this) {
      ActivityLevel.light => l10n.activityLightDescription,
      ActivityLevel.moderate => l10n.activityModerateDescription,
      ActivityLevel.active => l10n.activityActiveDescription,
    };
  }
}
