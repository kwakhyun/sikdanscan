import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/meal_record.dart';
import '../../../data/models/user_profile.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../meal/providers/meal_providers.dart';
import '../../profile/providers/profile_providers.dart';

/// Text resolved against the current [AppLocalizations] when rendered, so the
/// strategy has the same content in every supported language.
typedef L10nText = String Function(AppLocalizations l10n);

final mealStrategyProvider = Provider<MealStrategy>((ref) {
  final profile = ref.watch(userProfileProvider);
  final weight = ref.watch(currentWeightProvider);
  final meals = ref.watch(todayMealsProvider);
  // The logging factor compares with the meals expected by this hour.
  final hour = ref.watch(currentHourProvider);
  return MealStrategyBuilder.build(
    profile: weight > 0 ? profile.copyWith(currentWeight: weight) : profile,
    meals: meals,
    now: hour,
  );
});

/// One component of the strategy score, shown in the detail sheet.
class StrategyFactor {
  const StrategyFactor({
    required this.label,
    required this.earned,
    required this.max,
  });

  final L10nText label;
  final int earned;
  final int max;

  bool get isMet => earned >= max;
}

class MealStrategy {
  const MealStrategy({
    required this.goal,
    required this.score,
    required this.title,
    required this.summary,
    required this.primaryAction,
    required this.actions,
    required this.alertLevel,
    this.factors = const [],
  });

  final WellnessGoal goal;
  final int score;
  final L10nText title;
  final L10nText summary;
  final L10nText primaryAction;
  final List<L10nText> actions;
  final StrategyAlertLevel alertLevel;
  final List<StrategyFactor> factors;
}

enum StrategyAlertLevel { empty, good, watch, urgent }

/// Rule-based coaching: compares today's calories and macro ratios with the
/// selected goal. It is deterministic (no AI call), which the UI states.
class MealStrategyBuilder {
  const MealStrategyBuilder._();

  static MealStrategy build({
    required UserProfile profile,
    required List<MealRecord> meals,
    DateTime? now,
  }) {
    if (meals.isEmpty) {
      final goal = profile.wellnessGoal;
      return MealStrategy(
        goal: goal,
        score: 0,
        title: (l) => l.strategyEmptyTitle,
        summary: (l) => l.strategyEmptySummary(goal.labelOf(l)),
        primaryAction: (l) => l.strategyEmptyPrimary,
        actions: [
          (l) => l.strategyTipPhotoAngle,
          (l) => l.strategyTipReviewBeforeSave,
        ],
        alertLevel: StrategyAlertLevel.empty,
      );
    }

    final calories = meals.fold(0, (sum, meal) => sum + meal.calories);
    final carbs = meals.fold(0.0, (sum, meal) => sum + meal.carbs);
    final protein = meals.fold(0.0, (sum, meal) => sum + meal.protein);
    final fat = meals.fold(0.0, (sum, meal) => sum + meal.fat);
    final macroCalories = (carbs * 4) + (protein * 4) + (fat * 9);
    final carbRatio = macroCalories <= 0 ? 0.0 : (carbs * 4) / macroCalories;
    final proteinRatio = macroCalories <= 0
        ? 0.0
        : (protein * 4) / macroCalories;
    final fatRatio = macroCalories <= 0 ? 0.0 : (fat * 9) / macroCalories;
    final calorieProgress = calories / profile.dailyCalorieGoal.clamp(1, 10000);
    final goalProtein = proteinGoal(profile);
    final proteinGap = goalProtein - protein;
    final logging = _loggingProgress(meals, now ?? DateTime.now());

    return switch (profile.wellnessGoal) {
      WellnessGoal.weightLoss => _weightLoss(
        calorieProgress,
        proteinGap,
        fatRatio,
      ),
      WellnessGoal.skinHealth => _skinHealth(carbRatio, proteinGap, fatRatio),
      WellnessGoal.digestion => _digestion(carbs, fatRatio, logging),
      WellnessGoal.energy => _energy(carbRatio, proteinGap, calorieProgress),
      WellnessGoal.muscle => _muscle(
        protein,
        goalProtein,
        calorieProgress,
        logging,
      ),
      WellnessGoal.glucose => _glucose(carbRatio, proteinRatio, logging),
      WellnessGoal.balanced => _balanced(
        calorieProgress,
        carbRatio,
        proteinRatio,
        fatRatio,
        logging,
      ),
    };
  }

  /// Share (0–1) of the main meals expected by this time of day that have
  /// been logged: breakfast until 11:00, plus lunch until 17:00, then dinner.
  static double _loggingProgress(List<MealRecord> meals, DateTime now) {
    final expected = now.hour < 11 ? 1 : (now.hour < 17 ? 2 : 3);
    final mainMeals = meals
        .map((meal) => meal.mealType)
        .where((type) => type != MealType.snack)
        .toSet()
        .length;
    // A snack-only log still counts as one logged meal.
    final logged = mainMeals == 0 && meals.isNotEmpty ? 1 : mainMeals;
    return (logged / expected).clamp(0.0, 1.0);
  }

  static StrategyFactor _consistency(double progress, int max) {
    return StrategyFactor(
      label: (l) => l.strategyFactorConsistency,
      earned: (max * progress).round(),
      max: max,
    );
  }

  /// The goal's main rule sets the level; an otherwise good day with an
  /// unmet factor is shown as "watch" so the badge matches the breakdown.
  static StrategyAlertLevel _level(
    StrategyAlertLevel primary,
    List<StrategyFactor> factors,
  ) {
    if (primary != StrategyAlertLevel.good) return primary;
    return factors.every((factor) => factor.isMet)
        ? StrategyAlertLevel.good
        : StrategyAlertLevel.watch;
  }

  /// Daily protein target in grams for the profile's goal.
  static double proteinGoal(UserProfile profile) {
    return switch (profile.wellnessGoal) {
      WellnessGoal.muscle => profile.currentWeight * 1.6,
      WellnessGoal.weightLoss => profile.currentWeight * 1.3,
      WellnessGoal.skinHealth => profile.currentWeight * 1.1,
      _ => profile.currentWeight * 1.0,
    };
  }

  static StrategyFactor _factor(L10nText label, bool met, int max, int low) {
    return StrategyFactor(label: label, earned: met ? max : low, max: max);
  }

  static int _score(List<StrategyFactor> factors) {
    return factors.fold(0, (sum, f) => sum + f.earned).clamp(0, 100);
  }

  static MealStrategy _weightLoss(
    double calorieProgress,
    double proteinGap,
    double fatRatio,
  ) {
    final overTarget = calorieProgress > 1.0;
    final lowProtein = proteinGap > 15;
    final fatHeavy = fatRatio > 0.35;
    final factors = [
      _factor((l) => l.strategyFactorCalories, !overTarget, 34, 8),
      _factor((l) => l.strategyFactorProtein, !lowProtein, 33, 14),
      _factor((l) => l.strategyFactorFat, !fatHeavy, 33, 16),
    ];

    return MealStrategy(
      goal: WellnessGoal.weightLoss,
      score: _score(factors),
      factors: factors,
      title: overTarget
          ? (l) => l.strategyWeightLossOverTitle
          : (l) => l.strategyWeightLossOnTrackTitle,
      summary: overTarget
          ? (l) => l.strategyWeightLossOverSummary
          : (l) => l.strategyWeightLossOnTrackSummary,
      primaryAction: lowProtein
          ? (l) => l.strategyWeightLossAddProtein
          : (l) => l.strategyWeightLossVeggiesFirst,
      actions: [
        if (fatHeavy) (l) => l.strategyActionSkipFriedSauce,
        if (overTarget) (l) => l.strategyActionLightProteinMeal,
        (l) => l.strategyActionWalkAppetite,
      ],
      alertLevel: _level(
        overTarget ? StrategyAlertLevel.urgent : StrategyAlertLevel.good,
        factors,
      ),
    );
  }

  static MealStrategy _skinHealth(
    double carbRatio,
    double proteinGap,
    double fatRatio,
  ) {
    final highCarb = carbRatio > 0.58;
    final highFat = fatRatio > 0.38;
    final lowProtein = proteinGap > 18;
    final factors = [
      _factor((l) => l.strategyFactorCarbs, !highCarb, 34, 16),
      _factor((l) => l.strategyFactorFat, !highFat, 33, 15),
      _factor((l) => l.strategyFactorProtein, !lowProtein, 33, 18),
    ];

    return MealStrategy(
      goal: WellnessGoal.skinHealth,
      score: _score(factors),
      factors: factors,
      title: highCarb || highFat
          ? (l) => l.strategySkinFixTitle
          : (l) => l.strategySkinGoodTitle,
      summary: highCarb
          ? (l) => l.strategySkinHighCarbSummary
          : (l) => l.strategySkinBalancedSummary,
      primaryAction: (l) => l.strategySkinPrimary,
      actions: [
        if (highFat) (l) => l.strategyActionNoCreamy,
        if (highCarb) (l) => l.strategyActionNoSugarDrinks,
        (l) => l.strategyActionVitaminC,
      ],
      alertLevel: _level(
        highCarb || highFat
            ? StrategyAlertLevel.watch
            : StrategyAlertLevel.good,
        factors,
      ),
    );
  }

  static MealStrategy _digestion(
    double carbs,
    double fatRatio,
    double logging,
  ) {
    final heavyFat = fatRatio > 0.38;
    final lowVolume = carbs < 80;
    final factors = [
      _factor((l) => l.strategyFactorFat, !heavyFat, 42, 18),
      _factor((l) => l.strategyFactorVolume, !lowVolume, 28, 18),
      _consistency(logging, 30),
    ];

    return MealStrategy(
      goal: WellnessGoal.digestion,
      score: _score(factors),
      factors: factors,
      title: heavyFat
          ? (l) => l.strategyDigestionHeavyTitle
          : (l) => l.strategyDigestionGoodTitle,
      summary: heavyFat
          ? (l) => l.strategyDigestionHeavySummary
          : (l) => l.strategyDigestionGoodSummary,
      primaryAction: (l) => l.strategyDigestionPrimary,
      actions: [
        (l) => l.strategyActionSolidsOverBroth,
        (l) => l.strategyActionFermented,
        if (heavyFat) (l) => l.strategyActionSkipFattyMeat,
      ],
      alertLevel: _level(
        heavyFat ? StrategyAlertLevel.watch : StrategyAlertLevel.good,
        factors,
      ),
    );
  }

  static MealStrategy _energy(
    double carbRatio,
    double proteinGap,
    double calorieProgress,
  ) {
    final carbHeavy = carbRatio > 0.62;
    final lowProtein = proteinGap > 20;
    final tooLow = calorieProgress < 0.45;
    final factors = [
      _factor((l) => l.strategyFactorCarbs, !carbHeavy, 34, 16),
      _factor((l) => l.strategyFactorProtein, !lowProtein, 33, 15),
      _factor((l) => l.strategyFactorVolume, !tooLow, 33, 20),
    ];

    return MealStrategy(
      goal: WellnessGoal.energy,
      score: _score(factors),
      factors: factors,
      title: carbHeavy
          ? (l) => l.strategyEnergyCarbTitle
          : (l) => l.strategyEnergyGoodTitle,
      summary: tooLow
          ? (l) => l.strategyEnergyLowSummary
          : (l) => l.strategyEnergyGoodSummary,
      primaryAction: lowProtein
          ? (l) => l.strategyEnergyAddProtein
          : (l) => l.strategyEnergyPairCarbs,
      actions: [
        if (carbHeavy) (l) => l.strategyActionWaterOverSweet,
        (l) => l.strategyActionSmartSnack,
        (l) => l.strategyActionStretch,
      ],
      alertLevel: _level(
        carbHeavy || tooLow
            ? StrategyAlertLevel.watch
            : StrategyAlertLevel.good,
        factors,
      ),
    );
  }

  static MealStrategy _muscle(
    double protein,
    double goalProtein,
    double calorieProgress,
    double logging,
  ) {
    final gap = goalProtein - protein;
    final lowProtein = gap > 20;
    final tooLowCalories = calorieProgress < 0.55;
    final factors = [
      _factor((l) => l.strategyFactorProtein, !lowProtein, 50, 20),
      _factor((l) => l.strategyFactorVolume, !tooLowCalories, 25, 12),
      _consistency(logging, 25),
    ];
    final proteinText = protein.toStringAsFixed(0);
    final goalText = goalProtein.toStringAsFixed(0);
    final gapText = gap.clamp(0, 80).toStringAsFixed(0);

    return MealStrategy(
      goal: WellnessGoal.muscle,
      score: _score(factors),
      factors: factors,
      title: lowProtein
          ? (l) => l.strategyMuscleLowTitle
          : (l) => l.strategyMuscleCloseTitle,
      summary: (l) => l.strategyMuscleSummary(proteinText, goalText),
      primaryAction: lowProtein
          ? (l) => l.strategyMuscleAddProtein(gapText)
          : (l) => l.strategyMuscleRecovery,
      actions: [
        (l) => l.strategyActionLeanProtein,
        if (tooLowCalories) (l) => l.strategyActionPreWorkoutSnack,
        (l) => l.strategyActionSpreadProtein,
      ],
      alertLevel: _level(
        lowProtein ? StrategyAlertLevel.watch : StrategyAlertLevel.good,
        factors,
      ),
    );
  }

  static MealStrategy _glucose(
    double carbRatio,
    double proteinRatio,
    double logging,
  ) {
    final carbHeavy = carbRatio > 0.55;
    final lowProtein = proteinRatio < 0.18;
    final factors = [
      _factor((l) => l.strategyFactorCarbs, !carbHeavy, 45, 18),
      _factor((l) => l.strategyFactorProtein, !lowProtein, 35, 16),
      _consistency(logging, 20),
    ];

    return MealStrategy(
      goal: WellnessGoal.glucose,
      score: _score(factors),
      factors: factors,
      title: carbHeavy
          ? (l) => l.strategyGlucoseCarbTitle
          : (l) => l.strategyGlucoseGoodTitle,
      summary: carbHeavy
          ? (l) => l.strategyGlucoseCarbSummary
          : (l) => l.strategyGlucoseGoodSummary,
      primaryAction: (l) => l.strategyGlucosePrimary,
      actions: [
        if (lowProtein) (l) => l.strategyActionAddProteinSide,
        (l) => l.strategyActionWalk10,
        (l) => l.strategyActionNoDessert,
      ],
      alertLevel: _level(
        carbHeavy ? StrategyAlertLevel.watch : StrategyAlertLevel.good,
        factors,
      ),
    );
  }

  static MealStrategy _balanced(
    double calorieProgress,
    double carbRatio,
    double proteinRatio,
    double fatRatio,
    double logging,
  ) {
    final balancedMacros =
        carbRatio >= 0.35 &&
        carbRatio <= 0.58 &&
        proteinRatio >= 0.18 &&
        proteinRatio <= 0.35 &&
        fatRatio <= 0.38;
    final factors = [
      _factor((l) => l.strategyFactorCalories, calorieProgress <= 1.05, 34, 18),
      _factor((l) => l.strategyFactorBalance, balancedMacros, 43, 22),
      _consistency(logging, 23),
    ];

    return MealStrategy(
      goal: WellnessGoal.balanced,
      score: _score(factors),
      factors: factors,
      title: balancedMacros
          ? (l) => l.strategyBalancedGoodTitle
          : (l) => l.strategyBalancedFixTitle,
      summary: balancedMacros
          ? (l) => l.strategyBalancedGoodSummary
          : (l) => l.strategyBalancedFixSummary,
      primaryAction: (l) => l.strategyBalancedPrimary,
      actions: [
        (l) => l.strategyActionLogWater,
        (l) => l.strategyActionReviewRecords,
      ],
      alertLevel: _level(
        balancedMacros ? StrategyAlertLevel.good : StrategyAlertLevel.watch,
        factors,
      ),
    );
  }
}
