// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_recognition_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodRecognitionResult _$FoodRecognitionResultFromJson(
  Map<String, dynamic> json,
) => _FoodRecognitionResult(
  summary: json['summary'] as String? ?? '',
  confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
  needsReview: json['needsReview'] as bool? ?? true,
  warning: json['warning'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => RecognizedFoodItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RecognizedFoodItem>[],
);

Map<String, dynamic> _$FoodRecognitionResultToJson(
  _FoodRecognitionResult instance,
) => <String, dynamic>{
  'summary': instance.summary,
  'confidence': instance.confidence,
  'needsReview': instance.needsReview,
  'warning': instance.warning,
  'items': instance.items,
};

_RecognizedFoodItem _$RecognizedFoodItemFromJson(Map<String, dynamic> json) =>
    _RecognizedFoodItem(
      name: json['name'] as String,
      calories: (json['calories'] as num).toInt(),
      carbs: (json['carbs'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      servingSize: json['servingSize'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$RecognizedFoodItemToJson(_RecognizedFoodItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'calories': instance.calories,
      'carbs': instance.carbs,
      'protein': instance.protein,
      'fat': instance.fat,
      'servingSize': instance.servingSize,
      'confidence': instance.confidence,
    };
