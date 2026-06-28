// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  name: json['name'] as String,
  age: (json['age'] as num).toInt(),
  height: (json['height'] as num).toDouble(),
  startingWeight: (json['startingWeight'] as num?)?.toDouble(),
  currentWeight: (json['currentWeight'] as num).toDouble(),
  targetWeight: (json['targetWeight'] as num).toDouble(),
  gender: json['gender'] as String? ?? 'female',
  dailyCalorieGoal: (json['dailyCalorieGoal'] as num?)?.toInt() ?? 0,
  dailyWaterGoalMl: (json['dailyWaterGoalMl'] as num?)?.toInt() ?? 0,
  dailyStepGoal: (json['dailyStepGoal'] as num?)?.toInt() ?? 0,
  wellnessGoal:
      $enumDecodeNullable(_$WellnessGoalEnumMap, json['wellnessGoal']) ??
      WellnessGoal.balanced,
  activityLevel:
      $enumDecodeNullable(_$ActivityLevelEnumMap, json['activityLevel']) ??
      ActivityLevel.moderate,
  onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
  avatarImagePath: json['avatarImagePath'] as String?,
  targetDate: json['targetDate'] == null
      ? null
      : DateTime.parse(json['targetDate'] as String),
  onboardedAt: json['onboardedAt'] == null
      ? null
      : DateTime.parse(json['onboardedAt'] as String),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'height': instance.height,
      'startingWeight': instance.startingWeight,
      'currentWeight': instance.currentWeight,
      'targetWeight': instance.targetWeight,
      'gender': instance.gender,
      'dailyCalorieGoal': instance.dailyCalorieGoal,
      'dailyWaterGoalMl': instance.dailyWaterGoalMl,
      'dailyStepGoal': instance.dailyStepGoal,
      'wellnessGoal': _$WellnessGoalEnumMap[instance.wellnessGoal]!,
      'activityLevel': _$ActivityLevelEnumMap[instance.activityLevel]!,
      'onboardingCompleted': instance.onboardingCompleted,
      'avatarImagePath': instance.avatarImagePath,
      'targetDate': instance.targetDate?.toIso8601String(),
      'onboardedAt': instance.onboardedAt?.toIso8601String(),
    };

const _$WellnessGoalEnumMap = {
  WellnessGoal.balanced: 'balanced',
  WellnessGoal.weightLoss: 'weightLoss',
  WellnessGoal.skinHealth: 'skinHealth',
  WellnessGoal.digestion: 'digestion',
  WellnessGoal.energy: 'energy',
  WellnessGoal.muscle: 'muscle',
  WellnessGoal.glucose: 'glucose',
};

const _$ActivityLevelEnumMap = {
  ActivityLevel.light: 'light',
  ActivityLevel.moderate: 'moderate',
  ActivityLevel.active: 'active',
};
