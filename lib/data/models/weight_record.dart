import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight_record.freezed.dart';
part 'weight_record.g.dart';

@freezed
abstract class WeightRecord with _$WeightRecord {
  const factory WeightRecord({
    required String id,
    required DateTime date,
    required double weight,
    double? bodyFat,
    double? muscleMass,
    String? memo,
  }) = _WeightRecord;

  factory WeightRecord.fromJson(Map<String, dynamic> json) =>
      _$WeightRecordFromJson(json);
}
