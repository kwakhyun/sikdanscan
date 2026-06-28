// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MealRecord _$MealRecordFromJson(Map<String, dynamic> json) => _MealRecord(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
  name: json['name'] as String,
  calories: (json['calories'] as num).toInt(),
  carbs: (json['carbs'] as num).toDouble(),
  protein: (json['protein'] as num).toDouble(),
  fat: (json['fat'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String?,
  servingSize: json['servingSize'] as String?,
  isAiRecognized: json['isAiRecognized'] as bool? ?? false,
  recognitionConfidence: (json['recognitionConfidence'] as num?)?.toDouble(),
  memo: json['memo'] as String?,
);

Map<String, dynamic> _$MealRecordToJson(_MealRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
      'name': instance.name,
      'calories': instance.calories,
      'carbs': instance.carbs,
      'protein': instance.protein,
      'fat': instance.fat,
      'imageUrl': instance.imageUrl,
      'servingSize': instance.servingSize,
      'isAiRecognized': instance.isAiRecognized,
      'recognitionConfidence': instance.recognitionConfidence,
      'memo': instance.memo,
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
};
