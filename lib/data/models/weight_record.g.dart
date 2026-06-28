// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeightRecord _$WeightRecordFromJson(Map<String, dynamic> json) =>
    _WeightRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
      bodyFat: (json['bodyFat'] as num?)?.toDouble(),
      muscleMass: (json['muscleMass'] as num?)?.toDouble(),
      memo: json['memo'] as String?,
    );

Map<String, dynamic> _$WeightRecordToJson(_WeightRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'weight': instance.weight,
      'bodyFat': instance.bodyFat,
      'muscleMass': instance.muscleMass,
      'memo': instance.memo,
    };
