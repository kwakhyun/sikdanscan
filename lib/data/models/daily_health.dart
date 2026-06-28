import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_health.freezed.dart';
part 'daily_health.g.dart';

@freezed
abstract class DailyHealth with _$DailyHealth {
  const DailyHealth._();

  const factory DailyHealth({
    required String id,
    required DateTime date,
    @Default(0) int waterMl,
    @Default(0) int steps,
    @Default(0) double sleepHours,
    @Default(0) int exerciseMinutes,
    String? mood,
  }) = _DailyHealth;

  factory DailyHealth.fromJson(Map<String, dynamic> json) =>
      _$DailyHealthFromJson(json);

  int get waterCups => (waterMl / 250).floor();
  double get waterLiters => waterMl / 1000;
}
