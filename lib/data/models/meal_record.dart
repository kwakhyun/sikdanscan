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
  const MealRecord._();

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

    /// Portion multiplier the stored nutrition values already include.
    /// Editing the portion rescales from the 1× base instead of compounding.
    @Default(1.0) double portion,

    /// Last local modification, used to resolve local/remote merge conflicts.
    DateTime? updatedAt,

    /// Supabase Storage object path once the photo has been uploaded.
    String? imageStoragePath,
  }) = _MealRecord;

  factory MealRecord.fromJson(Map<String, dynamic> json) =>
      _$MealRecordFromJson(json);

  double get effectivePortion => portion > 0 ? portion : 1.0;

  /// Returns a copy whose nutrition is rescaled to [nextPortion] of the base
  /// (1×) amount.
  MealRecord withPortion(double nextPortion) {
    final safePortion = nextPortion > 0 ? nextPortion : 1.0;
    final factor = safePortion / effectivePortion;
    return copyWith(
      portion: safePortion,
      calories: (calories * factor).round(),
      carbs: carbs * factor,
      protein: protein * factor,
      fat: fat * factor,
    );
  }
}
