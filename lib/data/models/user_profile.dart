import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum WellnessGoal {
  balanced('균형 관리', '식단 균형과 꾸준한 기록을 유지', 'assets/icons/app/goal_balanced.svg'),
  weightLoss(
    '체중 감량',
    '칼로리 과잉을 줄이고 포만감을 높이는 전략',
    'assets/icons/app/goal_weight_loss.svg',
  ),
  skinHealth(
    '피부 개선',
    '당류·지방 편중을 낮추고 회복 영양소 보강',
    'assets/icons/app/goal_skin_health.svg',
  ),
  digestion(
    '장 건강',
    '식이섬유와 수분 중심의 소화 컨디션 관리',
    'assets/icons/app/goal_digestion.svg',
  ),
  energy(
    '컨디션 개선',
    '끼니 균형과 혈당 변동을 줄이는 에너지 관리',
    'assets/icons/app/goal_energy.svg',
  ),
  muscle(
    '단백질 보강',
    '체중과 활동량에 맞춘 단백질 섭취 최적화',
    'assets/icons/app/goal_muscle.svg',
  ),
  glucose('혈당 안정', '탄수화물 비중과 식사 순서를 관리', 'assets/icons/app/goal_glucose.svg');

  const WellnessGoal(this.label, this.description, this.iconAsset);

  final String label;
  final String description;
  final String iconAsset;
}

enum ActivityLevel {
  light('가벼운 활동', '대부분 앉아서 생활하거나 가벼운 걷기 위주', 1.2, 7000),
  moderate('보통 활동', '주 2~4회 운동 또는 하루 이동량이 있는 편', 1.45, 9000),
  active('활동적', '주 5회 이상 운동하거나 활동량이 많은 편', 1.65, 11000);

  const ActivityLevel(this.label, this.description, this.factor, this.stepGoal);

  final String label;
  final String description;
  final double factor;
  final int stepGoal;

  String get iconAsset => switch (this) {
    ActivityLevel.light => 'assets/icons/app/activity_light.svg',
    ActivityLevel.moderate => 'assets/icons/app/activity_moderate.svg',
    ActivityLevel.active => 'assets/icons/app/activity_active.svg',
  };
}

@freezed
abstract class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    required String name,
    required int age,
    required double height,
    double? startingWeight,
    required double currentWeight,
    required double targetWeight,
    @Default('female') String gender,
    @Default(0) int dailyCalorieGoal,
    @Default(0) int dailyWaterGoalMl,
    @Default(0) int dailyStepGoal,
    @Default(WellnessGoal.balanced) WellnessGoal wellnessGoal,
    @Default(ActivityLevel.moderate) ActivityLevel activityLevel,
    @Default(false) bool onboardingCompleted,
    String? avatarImagePath,
    DateTime? targetDate,
    DateTime? onboardedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  factory UserProfile.defaultProfile() => const UserProfile(
    name: '',
    age: 0,
    height: 0,
    startingWeight: null,
    currentWeight: 0,
    targetWeight: 0,
    gender: 'female',
    dailyCalorieGoal: 0,
    dailyWaterGoalMl: 0,
    dailyStepGoal: 0,
    wellnessGoal: WellnessGoal.balanced,
    activityLevel: ActivityLevel.moderate,
    onboardingCompleted: false,
    avatarImagePath: null,
    targetDate: null,
    onboardedAt: null,
  );

  bool get hasBodyMetrics => age > 0 && height > 0 && currentWeight > 0;

  String get displayName {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '식단스캔 사용자' : trimmed;
  }

  double get bmi {
    if (height <= 0 || currentWeight <= 0) {
      return 0;
    }
    return currentWeight / ((height / 100) * (height / 100));
  }

  String get bmiCategory {
    if (bmi <= 0) return '알 수 없음';
    if (bmi < 18.5) return '저체중';
    if (bmi < 23) return '정상';
    if (bmi < 25) return '과체중';
    if (bmi < 30) return '비만';
    return '고도비만';
  }

  double get basalMetabolicRate {
    if (!hasBodyMetrics) return 0;
    final sexConstant = gender == 'male' ? 5 : -161;
    return (10 * currentWeight) + (6.25 * height) - (5 * age) + sexConstant;
  }

  int get maintenanceCalorieEstimate {
    final bmr = basalMetabolicRate;
    if (bmr <= 0) return 0;
    return (bmr * activityLevel.factor).round();
  }

  int get goalCalorieAdjustment {
    return switch (wellnessGoal) {
      WellnessGoal.weightLoss => -300,
      WellnessGoal.muscle => 150,
      WellnessGoal.glucose => -100,
      _ => 0,
    };
  }

  int get recommendedDailyCalorieGoal {
    final maintenance = maintenanceCalorieEstimate;
    if (maintenance <= 0) return 0;
    final recommended = maintenance + goalCalorieAdjustment;
    return recommended.clamp(1200, 3600).toInt();
  }

  int get recommendedWaterGoalMl {
    if (currentWeight <= 0) return 0;
    return ((currentWeight * 30) / 100).round() * 100;
  }

  String get calorieGoalBasisSummary {
    if (!hasBodyMetrics || maintenanceCalorieEstimate <= 0) {
      return '나이, 성별, 키, 현재 체중, 활동량을 입력하면 자동 계산됩니다.';
    }

    final adjustment = goalCalorieAdjustment;
    final adjustmentText = adjustment == 0
        ? '목표 보정 없음'
        : '${adjustment > 0 ? '+' : ''}$adjustment kcal 목표 보정';
    return 'BMR ${basalMetabolicRate.round()} kcal × ${activityLevel.label} ${activityLevel.factor.toStringAsFixed(2)} · $adjustmentText';
  }

  double get goalStartWeight => startingWeight ?? currentWeight;
  double get weightToLose => currentWeight - targetWeight;

  double get progressPercent {
    return progressPercentFrom(initialWeight: goalStartWeight);
  }

  double progressPercentFrom({
    required double initialWeight,
    double? currentWeight,
  }) {
    final effectiveCurrentWeight = currentWeight ?? this.currentWeight;
    final totalDelta = initialWeight - targetWeight;
    final completedDelta = initialWeight - effectiveCurrentWeight;

    if (totalDelta == 0) {
      return effectiveCurrentWeight == targetWeight ? 1.0 : 0.0;
    }

    return (completedDelta / totalDelta).clamp(0.0, 1.0).toDouble();
  }

  int? daysRemaining({DateTime? now}) {
    final target = targetDate;
    if (target == null) return null;

    final baseline = now ?? DateTime.now();
    final today = DateTime(baseline.year, baseline.month, baseline.day);
    final targetDay = DateTime(target.year, target.month, target.day);
    return targetDay.difference(today).inDays;
  }
}
