import 'package:flutter/widgets.dart';

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
