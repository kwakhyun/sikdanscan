// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeightRecord {

 String get id; DateTime get date; double get weight; double? get bodyFat; double? get muscleMass; String? get memo;
/// Create a copy of WeightRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeightRecordCopyWith<WeightRecord> get copyWith => _$WeightRecordCopyWithImpl<WeightRecord>(this as WeightRecord, _$identity);

  /// Serializes this WeightRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeightRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.bodyFat, bodyFat) || other.bodyFat == bodyFat)&&(identical(other.muscleMass, muscleMass) || other.muscleMass == muscleMass)&&(identical(other.memo, memo) || other.memo == memo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,weight,bodyFat,muscleMass,memo);

@override
String toString() {
  return 'WeightRecord(id: $id, date: $date, weight: $weight, bodyFat: $bodyFat, muscleMass: $muscleMass, memo: $memo)';
}


}

/// @nodoc
abstract mixin class $WeightRecordCopyWith<$Res>  {
  factory $WeightRecordCopyWith(WeightRecord value, $Res Function(WeightRecord) _then) = _$WeightRecordCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, double weight, double? bodyFat, double? muscleMass, String? memo
});




}
/// @nodoc
class _$WeightRecordCopyWithImpl<$Res>
    implements $WeightRecordCopyWith<$Res> {
  _$WeightRecordCopyWithImpl(this._self, this._then);

  final WeightRecord _self;
  final $Res Function(WeightRecord) _then;

/// Create a copy of WeightRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? weight = null,Object? bodyFat = freezed,Object? muscleMass = freezed,Object? memo = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,bodyFat: freezed == bodyFat ? _self.bodyFat : bodyFat // ignore: cast_nullable_to_non_nullable
as double?,muscleMass: freezed == muscleMass ? _self.muscleMass : muscleMass // ignore: cast_nullable_to_non_nullable
as double?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WeightRecord].
extension WeightRecordPatterns on WeightRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeightRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeightRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeightRecord value)  $default,){
final _that = this;
switch (_that) {
case _WeightRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeightRecord value)?  $default,){
final _that = this;
switch (_that) {
case _WeightRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  double weight,  double? bodyFat,  double? muscleMass,  String? memo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeightRecord() when $default != null:
return $default(_that.id,_that.date,_that.weight,_that.bodyFat,_that.muscleMass,_that.memo);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  double weight,  double? bodyFat,  double? muscleMass,  String? memo)  $default,) {final _that = this;
switch (_that) {
case _WeightRecord():
return $default(_that.id,_that.date,_that.weight,_that.bodyFat,_that.muscleMass,_that.memo);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  double weight,  double? bodyFat,  double? muscleMass,  String? memo)?  $default,) {final _that = this;
switch (_that) {
case _WeightRecord() when $default != null:
return $default(_that.id,_that.date,_that.weight,_that.bodyFat,_that.muscleMass,_that.memo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeightRecord implements WeightRecord {
  const _WeightRecord({required this.id, required this.date, required this.weight, this.bodyFat, this.muscleMass, this.memo});
  factory _WeightRecord.fromJson(Map<String, dynamic> json) => _$WeightRecordFromJson(json);

@override final  String id;
@override final  DateTime date;
@override final  double weight;
@override final  double? bodyFat;
@override final  double? muscleMass;
@override final  String? memo;

/// Create a copy of WeightRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeightRecordCopyWith<_WeightRecord> get copyWith => __$WeightRecordCopyWithImpl<_WeightRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeightRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeightRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.bodyFat, bodyFat) || other.bodyFat == bodyFat)&&(identical(other.muscleMass, muscleMass) || other.muscleMass == muscleMass)&&(identical(other.memo, memo) || other.memo == memo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,weight,bodyFat,muscleMass,memo);

@override
String toString() {
  return 'WeightRecord(id: $id, date: $date, weight: $weight, bodyFat: $bodyFat, muscleMass: $muscleMass, memo: $memo)';
}


}

/// @nodoc
abstract mixin class _$WeightRecordCopyWith<$Res> implements $WeightRecordCopyWith<$Res> {
  factory _$WeightRecordCopyWith(_WeightRecord value, $Res Function(_WeightRecord) _then) = __$WeightRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, double weight, double? bodyFat, double? muscleMass, String? memo
});




}
/// @nodoc
class __$WeightRecordCopyWithImpl<$Res>
    implements _$WeightRecordCopyWith<$Res> {
  __$WeightRecordCopyWithImpl(this._self, this._then);

  final _WeightRecord _self;
  final $Res Function(_WeightRecord) _then;

/// Create a copy of WeightRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? weight = null,Object? bodyFat = freezed,Object? muscleMass = freezed,Object? memo = freezed,}) {
  return _then(_WeightRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,bodyFat: freezed == bodyFat ? _self.bodyFat : bodyFat // ignore: cast_nullable_to_non_nullable
as double?,muscleMass: freezed == muscleMass ? _self.muscleMass : muscleMass // ignore: cast_nullable_to_non_nullable
as double?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
