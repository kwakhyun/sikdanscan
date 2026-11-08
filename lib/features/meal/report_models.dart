import '../../core/utils/formatters.dart';
import '../../data/models/meal_record.dart';

enum ReportRange { day, week, month }

/// Inclusive calendar range shown in the report.
class ReportPeriod {
  const ReportPeriod({
    required this.range,
    required this.start,
    required this.end,
  });

  factory ReportPeriod.from({
    required ReportRange range,
    required DateTime anchorDate,
  }) {
    final day = anchorDate.dateOnly;
    return switch (range) {
      ReportRange.day => ReportPeriod(range: range, start: day, end: day),
      ReportRange.week => () {
        // Calendar arithmetic: subtracting 24h blocks lands on 23:00 of the
        // previous day when a DST change falls inside the week.
        final start = DateTime(
          day.year,
          day.month,
          day.day - (day.weekday - 1),
        );
        return ReportPeriod(
          range: range,
          start: start,
          end: DateTime(start.year, start.month, start.day + 6),
        );
      }(),
      ReportRange.month => ReportPeriod(
        range: range,
        start: DateTime(day.year, day.month),
        end: DateTime(day.year, day.month + 1, 0),
      ),
    };
  }

  final ReportRange range;
  final DateTime start;
  final DateTime end;

  int get dayCount =>
      DateTime.utc(
        end.year,
        end.month,
        end.day,
      ).difference(DateTime.utc(start.year, start.month, start.day)).inDays +
      1;

  List<DateTime> get days => [
    for (var i = 0; i < dayCount; i++)
      DateTime(start.year, start.month, start.day + i),
  ];

  /// Days of the period that have already started (future days excluded).
  int elapsedDays(DateTime today) {
    final day = today.dateOnly;
    if (day.isBefore(start)) return 0;
    if (day.isAfter(end)) return dayCount;
    return DateTime.utc(
          day.year,
          day.month,
          day.day,
        ).difference(DateTime.utc(start.year, start.month, start.day)).inDays +
        1;
  }

  bool contains(DateTime date) {
    final day = date.dateOnly;
    return !day.isBefore(start) && !day.isAfter(end);
  }

  bool isCurrent(DateTime today) => contains(today);

  ReportPeriod shift(int direction) {
    return switch (range) {
      ReportRange.day => ReportPeriod.from(
        range: range,
        anchorDate: DateTime(start.year, start.month, start.day + direction),
      ),
      ReportRange.week => ReportPeriod.from(
        range: range,
        anchorDate: DateTime(
          start.year,
          start.month,
          start.day + 7 * direction,
        ),
      ),
      ReportRange.month => ReportPeriod.from(
        range: range,
        anchorDate: DateTime(start.year, start.month + direction),
      ),
    };
  }

  List<MealRecord> filter(List<MealRecord> meals) {
    return meals.where((meal) => contains(meal.date)).toList();
  }
}

/// Totals and goal comparison for a period.
///
/// The goal only counts days that have started, and the daily average only
/// counts days with at least one record, so unlogged and future days do not
/// make intake look lower than it was.
class ReportSummary {
  const ReportSummary({
    required this.period,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.recordedDays,
    required this.goalDays,
    required this.dailyCalorieGoal,
  });

  factory ReportSummary.from({
    required List<MealRecord> meals,
    required ReportPeriod period,
    required int dailyCalorieGoal,
    required DateTime today,
  }) {
    final inPeriod = period.filter(meals);
    final recordedDays = inPeriod.map((meal) => meal.date.dateOnly).toSet();
    return ReportSummary(
      period: period,
      calories: inPeriod.fold(0, (sum, meal) => sum + meal.calories),
      carbs: inPeriod.fold(0.0, (sum, meal) => sum + meal.carbs),
      protein: inPeriod.fold(0.0, (sum, meal) => sum + meal.protein),
      fat: inPeriod.fold(0.0, (sum, meal) => sum + meal.fat),
      recordedDays: recordedDays.length,
      goalDays: period.elapsedDays(today),
      dailyCalorieGoal: dailyCalorieGoal,
    );
  }

  final ReportPeriod period;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final int recordedDays;

  /// Days counted toward the goal (started days of the period).
  final int goalDays;
  final int dailyCalorieGoal;

  int get calorieGoal =>
      dailyCalorieGoal <= 0 ? 0 : dailyCalorieGoal * goalDays;

  int get remainingCalories => calorieGoal - calories;

  double get progress => calorieGoal <= 0 ? 0 : calories / calorieGoal;

  /// Average over days that have records.
  int get dailyAverageCalories =>
      recordedDays == 0 ? 0 : (calories / recordedDays).round();
}

/// Calories per day of the period, in order.
List<(DateTime day, int calories)> dailyCalories(
  ReportPeriod period,
  List<MealRecord> meals,
) {
  final byDay = <DateTime, int>{};
  for (final meal in period.filter(meals)) {
    final day = meal.date.dateOnly;
    byDay[day] = (byDay[day] ?? 0) + meal.calories;
  }
  return [for (final day in period.days) (day, byDay[day] ?? 0)];
}
