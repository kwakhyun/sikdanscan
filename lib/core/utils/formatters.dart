import 'package:intl/intl.dart';

/// Locale-aware number and date formatting.
///
/// Every screen formats through these helpers instead of hand-written
/// `languageCode == 'en'` branches, so Korean and English stay consistent.
class AppFormat {
  AppFormat._();

  static String integer(num value, String locale) {
    return NumberFormat.decimalPattern(locale).format(value.round());
  }

  static String kcal(num value, String locale) =>
      '${integer(value, locale)} kcal';

  static String grams(num value) => '${value.toStringAsFixed(0)}g';

  static String decimal(num value, {int digits = 1}) {
    return value.toStringAsFixed(digits);
  }

  /// 24h clock, e.g. `08:30`.
  static String time(DateTime date) => DateFormat('HH:mm').format(date);

  /// e.g. `11월 7일 토요일` / `Saturday, November 7`.
  static String fullDate(DateTime date, String locale) {
    return DateFormat.MMMMEEEEd(locale).format(date);
  }

  /// e.g. `11월 7일 (토)` / `Sat, Nov 7`.
  static String mediumDate(DateTime date, String locale) {
    return DateFormat.MMMEd(locale).format(date);
  }

  /// e.g. `2026. 11. 7.` / `Nov 7, 2026`.
  static String yearMonthDay(DateTime date, String locale) {
    return DateFormat.yMMMd(locale).format(date);
  }

  /// e.g. `2026년 11월` / `November 2026`.
  static String monthYear(DateTime date, String locale) {
    return DateFormat.yMMMM(locale).format(date);
  }

  /// Compact numeric date, e.g. `11/7`.
  static String shortDate(DateTime date) => DateFormat('M/d').format(date);

  /// e.g. `토` / `Sat`.
  static String weekdayShort(DateTime date, String locale) {
    return DateFormat.E(locale).format(date);
  }
}

extension DateOnlyX on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
