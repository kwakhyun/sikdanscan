import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_record.freezed.dart';
part 'meal_record.g.dart';

enum MealType {
  breakfast('아침', 'assets/icons/app/meal_breakfast.svg'),
  lunch('점심', 'assets/icons/app/meal_lunch.svg'),
  dinner('저녁', 'assets/icons/app/meal_dinner.svg'),
  snack('간식', 'assets/icons/app/meal_snack.svg');

  final String label;
  final String iconAsset;
  const MealType(this.label, this.iconAsset);
}

@freezed
abstract class MealRecord with _$MealRecord {
  const factory MealRecord({
    required String id,
    required DateTime date,
    required MealType mealType,
    required String name,
    required int calories,
    required double carbs,
    required double protein,
    required double fat,
    String? imageUrl,
    String? servingSize,
    @Default(false) bool isAiRecognized,
    double? recognitionConfidence,
    String? memo,
  }) = _MealRecord;

  factory MealRecord.fromJson(Map<String, dynamic> json) =>
      _$MealRecordFromJson(json);
}
