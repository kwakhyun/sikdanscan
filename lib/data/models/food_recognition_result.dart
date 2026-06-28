import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_recognition_result.freezed.dart';
part 'food_recognition_result.g.dart';

@freezed
abstract class FoodRecognitionResult with _$FoodRecognitionResult {
  const factory FoodRecognitionResult({
    @Default('') String summary,
    @Default(0.0) double confidence,
    @Default(true) bool needsReview,
    String? warning,
    @Default(<RecognizedFoodItem>[]) List<RecognizedFoodItem> items,
  }) = _FoodRecognitionResult;

  factory FoodRecognitionResult.fromJson(Map<String, dynamic> json) =>
      _$FoodRecognitionResultFromJson(json);
}

@freezed
abstract class RecognizedFoodItem with _$RecognizedFoodItem {
  const factory RecognizedFoodItem({
    required String name,
    required int calories,
    required double carbs,
    required double protein,
    required double fat,
    String? servingSize,
    @Default(0.0) double confidence,
  }) = _RecognizedFoodItem;

  factory RecognizedFoodItem.fromJson(Map<String, dynamic> json) =>
      _$RecognizedFoodItemFromJson(json);
}
