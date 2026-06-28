import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/meal_record.dart';
import '../../../data/models/user_profile.dart';
import '../../meal/providers/meal_providers.dart';
import '../../profile/providers/profile_providers.dart';

final mealStrategyProvider = Provider<MealStrategy>((ref) {
  final profile = ref.watch(userProfileProvider);
  final meals = ref.watch(selectedDateMealsProvider);
  final languageCode = ref.watch(languageProvider).languageCode;
  return MealStrategyBuilder.build(
    profile: profile,
    meals: meals,
    locale: languageCode,
  );
});

class MealStrategy {
  const MealStrategy({
    required this.goal,
    required this.score,
    required this.title,
    required this.summary,
    required this.primaryAction,
    required this.actions,
    required this.alertLevel,
  });

  final WellnessGoal goal;
  final int score;
  final String title;
  final String summary;
  final String primaryAction;
  final List<String> actions;
  final StrategyAlertLevel alertLevel;
}

enum StrategyAlertLevel { empty, good, watch, urgent }

class MealStrategyBuilder {
  const MealStrategyBuilder._();

  static MealStrategy build({
    required UserProfile profile,
    required List<MealRecord> meals,
    String locale = 'ko',
  }) {
    if (locale.toLowerCase().startsWith('en')) {
      return _buildEnglish(profile: profile, meals: meals);
    }

    if (meals.isEmpty) {
      return MealStrategy(
        goal: profile.wellnessGoal,
        score: 0,
        title: '첫 식사를 스캔해 전략을 시작하세요',
        summary:
            '${profile.wellnessGoal.label} 목표에 맞춰 오늘 식단의 강점과 보완점을 자동으로 정리합니다.',
        primaryAction: '음식 사진을 촬영하면 목표별 코칭이 생성됩니다.',
        actions: const ['음식이 잘 보이도록 위에서 촬영', '인식 결과 저장 전 음식명과 양 확인'],
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
    final proteinGoal = _proteinGoal(profile);
    final proteinGap = proteinGoal - protein;

    return switch (profile.wellnessGoal) {
      WellnessGoal.weightLoss => _weightLoss(
        profile,
        calorieProgress,
        proteinGap,
        fatRatio,
      ),
      WellnessGoal.skinHealth => _skinHealth(carbRatio, proteinGap, fatRatio),
      WellnessGoal.digestion => _digestion(carbs, fatRatio),
      WellnessGoal.energy => _energy(carbRatio, proteinGap, calorieProgress),
      WellnessGoal.muscle => _muscle(protein, proteinGoal, calorieProgress),
      WellnessGoal.glucose => _glucose(carbRatio, proteinRatio),
      WellnessGoal.balanced => _balanced(
        calorieProgress,
        carbRatio,
        proteinRatio,
        fatRatio,
      ),
    };
  }

  static MealStrategy _buildEnglish({
    required UserProfile profile,
    required List<MealRecord> meals,
  }) {
    if (meals.isEmpty) {
      return MealStrategy(
        goal: profile.wellnessGoal,
        score: 0,
        title: 'Scan your first meal to start a strategy',
        summary:
            'SikdanScan will summarize strengths and gaps for your goal after you record food.',
        primaryAction: 'Capture a meal photo to generate goal-based coaching.',
        actions: const [
          'Take the photo from above with food clearly visible',
          'Review food names and portions before saving',
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
    final fatRatio = macroCalories <= 0 ? 0.0 : (fat * 9) / macroCalories;
    final calorieProgress = calories / profile.dailyCalorieGoal.clamp(1, 10000);
    final proteinGoal = _proteinGoal(profile);
    final proteinGap = proteinGoal - protein;
    final lowProtein = proteinGap > 18;
    final carbHeavy = carbRatio > 0.58;
    final fatHeavy = fatRatio > 0.38;
    final overTarget = calorieProgress > 1.0;

    return switch (profile.wellnessGoal) {
      WellnessGoal.skinHealth => MealStrategy(
        goal: WellnessGoal.skinHealth,
        score: _score([
          if (!carbHeavy) 34 else 16,
          if (!fatHeavy) 33 else 15,
          if (!lowProtein) 33 else 18,
        ]),
        title: carbHeavy || fatHeavy
            ? 'Your skin goal needs a correction'
            : 'Skin-friendly balance is on track',
        summary: carbHeavy
            ? 'Carbs are high today. Choose a next meal that reduces glucose spikes.'
            : 'Today’s intake is not overly skewed. Add antioxidant-rich foods if possible.',
        primaryAction:
            'Prioritize fish, tofu, or eggs with leafy vegetables next.',
        actions: [
          if (fatHeavy)
            'Skip oily dishes and cream sauces for the rest of today',
          if (carbHeavy)
            'Choose water or unsweetened tea instead of dessert drinks',
          'Add a small portion of vitamin C-rich fruit',
        ],
        alertLevel: carbHeavy || fatHeavy
            ? StrategyAlertLevel.watch
            : StrategyAlertLevel.good,
      ),
      WellnessGoal.muscle => MealStrategy(
        goal: WellnessGoal.muscle,
        score: _score([
          if (!lowProtein) 50 else 20,
          if (calorieProgress >= 0.55) 25 else 12,
          25,
        ]),
        title: lowProtein
            ? 'Protein needs attention'
            : 'You are getting close to your protein goal',
        summary:
            'Today’s protein is ${protein.toStringAsFixed(0)}g. Your goal is ${proteinGoal.toStringAsFixed(0)}g.',
        primaryAction: lowProtein
            ? 'Aim to add ${proteinGap.clamp(0, 80).toStringAsFixed(0)}g of protein at the next meal.'
            : 'After exercise, add water and a small amount of carbs.',
        actions: const [
          'Choose chicken breast, fish, tofu, or Greek yogurt',
          'Spread protein across meals instead of all at once',
        ],
        alertLevel: lowProtein
            ? StrategyAlertLevel.watch
            : StrategyAlertLevel.good,
      ),
      _ => MealStrategy(
        goal: profile.wellnessGoal,
        score: _score([
          if (!overTarget) 34 else 18,
          if (!carbHeavy) 33 else 16,
          if (!fatHeavy) 33 else 16,
        ]),
        title: overTarget
            ? 'Keep the rest of today lighter'
            : 'Your meal flow is manageable',
        summary: overTarget
            ? 'You are above today’s calorie target. Make the next meal protein and vegetables first.'
            : 'Your intake is within a workable range. Balance the next meal with protein, fiber, and hydration.',
        primaryAction:
            'Build the next plate with protein, vegetables, and a moderate carb portion.',
        actions: const [
          'Drink water before the next meal',
          'Walk 10 minutes after eating',
          'Review the saved food names and portions',
        ],
        alertLevel: overTarget
            ? StrategyAlertLevel.watch
            : StrategyAlertLevel.good,
      ),
    };
  }

  static double _proteinGoal(UserProfile profile) {
    return switch (profile.wellnessGoal) {
      WellnessGoal.muscle => profile.currentWeight * 1.6,
      WellnessGoal.weightLoss => profile.currentWeight * 1.3,
      WellnessGoal.skinHealth => profile.currentWeight * 1.1,
      _ => profile.currentWeight * 1.0,
    };
  }

  static MealStrategy _weightLoss(
    UserProfile profile,
    double calorieProgress,
    double proteinGap,
    double fatRatio,
  ) {
    final overTarget = calorieProgress > 1.0;
    final lowProtein = proteinGap > 15;
    final score = _score([
      if (!overTarget) 34 else 8,
      if (!lowProtein) 33 else 14,
      if (fatRatio <= 0.35) 33 else 16,
    ]);

    return MealStrategy(
      goal: WellnessGoal.weightLoss,
      score: score,
      title: overTarget ? '남은 식사는 가볍게 보정하세요' : '감량 흐름은 유지 중입니다',
      summary: overTarget
          ? '오늘 목표 칼로리를 넘겼습니다. 다음 식사는 포만감 높은 단백질과 채소 중심이 좋습니다.'
          : '현재 섭취량은 목표 범위 안입니다. 단백질을 채우면 야식 가능성을 줄일 수 있습니다.',
      primaryAction: lowProtein
          ? '다음 식사에 닭가슴살, 달걀, 두부 중 하나를 추가하세요.'
          : '탄수화물 추가보다 채소와 수분을 먼저 보강하세요.',
      actions: [
        if (fatRatio > 0.35) '튀김·소스류는 다음 식사에서 제외',
        if (overTarget) '남은 식사는 400kcal 안쪽의 단백질 식사로 조정',
        '식사 후 10분 걷기로 혈당과 식욕 변동 완화',
      ],
      alertLevel: overTarget
          ? StrategyAlertLevel.urgent
          : StrategyAlertLevel.good,
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
    final score = _score([
      if (!highCarb) 34 else 16,
      if (!highFat) 33 else 15,
      if (!lowProtein) 33 else 18,
    ]);

    return MealStrategy(
      goal: WellnessGoal.skinHealth,
      score: score,
      title: highCarb || highFat ? '피부 목표 기준 보정이 필요합니다' : '피부 친화적인 흐름입니다',
      summary: highCarb
          ? '탄수화물 비중이 높아 다음 식사는 혈당 변동을 줄이는 조합이 좋습니다.'
          : '오늘 식단은 과도하게 한쪽으로 치우치지 않았습니다. 항산화 식품을 더하면 좋습니다.',
      primaryAction: '다음 식사는 생선·두부·달걀 + 녹황색 채소 조합을 우선하세요.',
      actions: [
        if (highFat) '기름진 메뉴와 크림 소스는 오늘 추가하지 않기',
        if (highCarb) '디저트·당 음료 대신 물 또는 무가당 차 선택',
        '비타민 C가 있는 과일은 한 번에 소량만 추가',
      ],
      alertLevel: highCarb || highFat
          ? StrategyAlertLevel.watch
          : StrategyAlertLevel.good,
    );
  }

  static MealStrategy _digestion(double carbs, double fatRatio) {
    final heavyFat = fatRatio > 0.38;
    final lowCarbVolume = carbs < 80;
    final score = _score([
      if (!heavyFat) 42 else 18,
      if (!lowCarbVolume) 28 else 18,
      30,
    ]);

    return MealStrategy(
      goal: WellnessGoal.digestion,
      score: score,
      title: heavyFat ? '소화 부담을 낮춰야 합니다' : '장 건강 루틴을 이어가세요',
      summary: heavyFat
          ? '지방 비중이 높으면 더부룩함이 생길 수 있습니다. 다음 식사는 담백하게 보정하세요.'
          : '오늘은 장 건강 목표에 맞춰 수분과 식이섬유를 더하기 좋은 상태입니다.',
      primaryAction: '채소 반 접시와 물 500ml를 다음 식사 전후로 나눠 보강하세요.',
      actions: [
        '국물보다 건더기 중심으로 선택',
        '요거트, 김치, 나물류 중 하나 추가',
        if (heavyFat) '튀김·기름진 고기는 다음 식사에서 제외',
      ],
      alertLevel: heavyFat ? StrategyAlertLevel.watch : StrategyAlertLevel.good,
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
    final score = _score([
      if (!carbHeavy) 34 else 16,
      if (!lowProtein) 33 else 15,
      if (!tooLow) 33 else 20,
    ]);

    return MealStrategy(
      goal: WellnessGoal.energy,
      score: score,
      title: carbHeavy ? '오후 에너지 변동을 줄이세요' : '컨디션 유지에 좋은 균형입니다',
      summary: tooLow
          ? '섭취량이 낮아 오후 집중력 저하가 올 수 있습니다.'
          : '끼니 균형을 유지하면 피로감과 간식 욕구를 줄일 수 있습니다.',
      primaryAction: lowProtein
          ? '단백질 간식 또는 달걀/두부를 추가하세요.'
          : '다음 식사는 탄수화물 단독보다 단백질과 함께 구성하세요.',
      actions: [
        if (carbHeavy) '단 음료 대신 물 또는 아메리카노 선택',
        '간식은 견과류 소량이나 그릭요거트로 선택',
        '식후 5분 스트레칭으로 졸림 완화',
      ],
      alertLevel: carbHeavy || tooLow
          ? StrategyAlertLevel.watch
          : StrategyAlertLevel.good,
    );
  }

  static MealStrategy _muscle(
    double protein,
    double proteinGoal,
    double calorieProgress,
  ) {
    final gap = proteinGoal - protein;
    final lowProtein = gap > 20;
    final tooLowCalories = calorieProgress < 0.55;
    final score = _score([
      if (!lowProtein) 50 else 20,
      if (!tooLowCalories) 25 else 12,
      25,
    ]);

    return MealStrategy(
      goal: WellnessGoal.muscle,
      score: score,
      title: lowProtein ? '단백질 보강이 우선입니다' : '단백질 목표에 가까워지고 있습니다',
      summary:
          '오늘 단백질은 ${protein.toStringAsFixed(0)}g, 목표는 ${proteinGoal.toStringAsFixed(0)}g입니다.',
      primaryAction: lowProtein
          ? '다음 식사에 단백질 ${gap.clamp(0, 80).toStringAsFixed(0)}g 보강을 목표로 하세요.'
          : '운동 후에는 수분과 탄수화물을 소량 함께 보강하세요.',
      actions: [
        '닭가슴살·생선·두부·그릭요거트 중 하나 선택',
        if (tooLowCalories) '섭취량이 낮으니 운동 전후 간식을 추가',
        '단백질은 한 끼에 몰지 말고 나눠 섭취',
      ],
      alertLevel: lowProtein
          ? StrategyAlertLevel.watch
          : StrategyAlertLevel.good,
    );
  }

  static MealStrategy _glucose(double carbRatio, double proteinRatio) {
    final carbHeavy = carbRatio > 0.55;
    final lowProtein = proteinRatio < 0.18;
    final score = _score([
      if (!carbHeavy) 45 else 18,
      if (!lowProtein) 35 else 16,
      20,
    ]);

    return MealStrategy(
      goal: WellnessGoal.glucose,
      score: score,
      title: carbHeavy ? '탄수화물 속도 조절이 필요합니다' : '혈당 안정 흐름입니다',
      summary: carbHeavy
          ? '탄수화물 비중이 높습니다. 다음 식사는 식사 순서와 단백질 보강이 중요합니다.'
          : '현재 비율은 급격한 변동을 줄이기 좋은 편입니다.',
      primaryAction: '다음 식사는 채소 → 단백질 → 탄수화물 순서로 드세요.',
      actions: [
        if (lowProtein) '밥/면 단독 식사는 피하고 단백질 반찬 추가',
        '식후 10분 걷기',
        '단 음료와 디저트는 오늘 추가하지 않기',
      ],
      alertLevel: carbHeavy
          ? StrategyAlertLevel.watch
          : StrategyAlertLevel.good,
    );
  }

  static MealStrategy _balanced(
    double calorieProgress,
    double carbRatio,
    double proteinRatio,
    double fatRatio,
  ) {
    final balancedMacros =
        carbRatio >= 0.35 &&
        carbRatio <= 0.58 &&
        proteinRatio >= 0.18 &&
        proteinRatio <= 0.35 &&
        fatRatio <= 0.38;
    final score = _score([
      if (calorieProgress <= 1.05) 34 else 18,
      if (balancedMacros) 43 else 22,
      23,
    ]);

    return MealStrategy(
      goal: WellnessGoal.balanced,
      score: score,
      title: balancedMacros ? '균형이 좋은 하루입니다' : '한쪽으로 치우친 영양소를 보정하세요',
      summary: balancedMacros
          ? '현재 칼로리와 탄단지 흐름이 안정적입니다.'
          : '다음 식사에서 부족한 축을 보강하면 하루 균형이 좋아집니다.',
      primaryAction: '다음 식사는 단백질, 채소, 탄수화물을 한 접시에 함께 구성하세요.',
      actions: const ['물 섭취를 함께 기록', '오늘 기록을 한 번 확인'],
      alertLevel: balancedMacros
          ? StrategyAlertLevel.good
          : StrategyAlertLevel.watch,
    );
  }

  static int _score(List<int> parts) {
    return parts.fold(0, (sum, value) => sum + value).clamp(0, 100);
  }
}
