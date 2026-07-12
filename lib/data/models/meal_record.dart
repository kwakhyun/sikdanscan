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

  static MealType fromTime(DateTime time) {
    final hour = time.hour;
    if (hour >= 4 && hour < 11) return MealType.breakfast;
    if (hour >= 11 && hour < 16) return MealType.lunch;
    if (hour >= 16 && hour < 22) return MealType.dinner;
    return MealType.snack;
  }
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
