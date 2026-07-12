import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toShortDate() => DateFormat('M/d').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime get dateOnly => DateTime(year, month, day);
}
