// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_health.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DailyHealth _$DailyHealthFromJson(Map<String, dynamic> json) => _DailyHealth(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  waterMl: (json['waterMl'] as num?)?.toInt() ?? 0,
  steps: (json['steps'] as num?)?.toInt() ?? 0,
  sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 0,
  exerciseMinutes: (json['exerciseMinutes'] as num?)?.toInt() ?? 0,
  mood: json['mood'] as String?,
);

Map<String, dynamic> _$DailyHealthToJson(_DailyHealth instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'waterMl': instance.waterMl,
      'steps': instance.steps,
      'sleepHours': instance.sleepHours,
      'exerciseMinutes': instance.exerciseMinutes,
      'mood': instance.mood,
    };
