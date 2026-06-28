// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_health.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DailyHealth {

 String get id; DateTime get date; int get waterMl; int get steps; double get sleepHours; int get exerciseMinutes; String? get mood;
/// Create a copy of DailyHealth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyHealthCopyWith<DailyHealth> get copyWith => _$DailyHealthCopyWithImpl<DailyHealth>(this as DailyHealth, _$identity);

  /// Serializes this DailyHealth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyHealth&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.waterMl, waterMl) || other.waterMl == waterMl)&&(identical(other.steps, steps) || other.steps == steps)&&(identical(other.sleepHours, sleepHours) || other.sleepHours == sleepHours)&&(identical(other.exerciseMinutes, exerciseMinutes) || other.exerciseMinutes == exerciseMinutes)&&(identical(other.mood, mood) || other.mood == mood));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,waterMl,steps,sleepHours,exerciseMinutes,mood);

@override
String toString() {
  return 'DailyHealth(id: $id, date: $date, waterMl: $waterMl, steps: $steps, sleepHours: $sleepHours, exerciseMinutes: $exerciseMinutes, mood: $mood)';
}


}

/// @nodoc
abstract mixin class $DailyHealthCopyWith<$Res>  {
  factory $DailyHealthCopyWith(DailyHealth value, $Res Function(DailyHealth) _then) = _$DailyHealthCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, int waterMl, int steps, double sleepHours, int exerciseMinutes, String? mood
});




}
/// @nodoc
class _$DailyHealthCopyWithImpl<$Res>
    implements $DailyHealthCopyWith<$Res> {
  _$DailyHealthCopyWithImpl(this._self, this._then);

  final DailyHealth _self;
  final $Res Function(DailyHealth) _then;

/// Create a copy of DailyHealth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? waterMl = null,Object? steps = null,Object? sleepHours = null,Object? exerciseMinutes = null,Object? mood = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,waterMl: null == waterMl ? _self.waterMl : waterMl // ignore: cast_nullable_to_non_nullable
as int,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as int,sleepHours: null == sleepHours ? _self.sleepHours : sleepHours // ignore: cast_nullable_to_non_nullable
as double,exerciseMinutes: null == exerciseMinutes ? _self.exerciseMinutes : exerciseMinutes // ignore: cast_nullable_to_non_nullable
as int,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyHealth].
extension DailyHealthPatterns on DailyHealth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyHealth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyHealth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyHealth value)  $default,){
final _that = this;
switch (_that) {
case _DailyHealth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyHealth value)?  $default,){
final _that = this;
switch (_that) {
case _DailyHealth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  int waterMl,  int steps,  double sleepHours,  int exerciseMinutes,  String? mood)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyHealth() when $default != null:
return $default(_that.id,_that.date,_that.waterMl,_that.steps,_that.sleepHours,_that.exerciseMinutes,_that.mood);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  int waterMl,  int steps,  double sleepHours,  int exerciseMinutes,  String? mood)  $default,) {final _that = this;
switch (_that) {
case _DailyHealth():
return $default(_that.id,_that.date,_that.waterMl,_that.steps,_that.sleepHours,_that.exerciseMinutes,_that.mood);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  int waterMl,  int steps,  double sleepHours,  int exerciseMinutes,  String? mood)?  $default,) {final _that = this;
switch (_that) {
case _DailyHealth() when $default != null:
return $default(_that.id,_that.date,_that.waterMl,_that.steps,_that.sleepHours,_that.exerciseMinutes,_that.mood);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyHealth extends DailyHealth {
  const _DailyHealth({required this.id, required this.date, this.waterMl = 0, this.steps = 0, this.sleepHours = 0, this.exerciseMinutes = 0, this.mood}): super._();
  factory _DailyHealth.fromJson(Map<String, dynamic> json) => _$DailyHealthFromJson(json);

@override final  String id;
@override final  DateTime date;
@override@JsonKey() final  int waterMl;
@override@JsonKey() final  int steps;
@override@JsonKey() final  double sleepHours;
@override@JsonKey() final  int exerciseMinutes;
@override final  String? mood;

/// Create a copy of DailyHealth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyHealthCopyWith<_DailyHealth> get copyWith => __$DailyHealthCopyWithImpl<_DailyHealth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyHealthToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyHealth&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.waterMl, waterMl) || other.waterMl == waterMl)&&(identical(other.steps, steps) || other.steps == steps)&&(identical(other.sleepHours, sleepHours) || other.sleepHours == sleepHours)&&(identical(other.exerciseMinutes, exerciseMinutes) || other.exerciseMinutes == exerciseMinutes)&&(identical(other.mood, mood) || other.mood == mood));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,waterMl,steps,sleepHours,exerciseMinutes,mood);

@override
String toString() {
  return 'DailyHealth(id: $id, date: $date, waterMl: $waterMl, steps: $steps, sleepHours: $sleepHours, exerciseMinutes: $exerciseMinutes, mood: $mood)';
}


}

/// @nodoc
abstract mixin class _$DailyHealthCopyWith<$Res> implements $DailyHealthCopyWith<$Res> {
  factory _$DailyHealthCopyWith(_DailyHealth value, $Res Function(_DailyHealth) _then) = __$DailyHealthCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, int waterMl, int steps, double sleepHours, int exerciseMinutes, String? mood
});




}
/// @nodoc
class __$DailyHealthCopyWithImpl<$Res>
    implements _$DailyHealthCopyWith<$Res> {
  __$DailyHealthCopyWithImpl(this._self, this._then);

  final _DailyHealth _self;
  final $Res Function(_DailyHealth) _then;

/// Create a copy of DailyHealth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? waterMl = null,Object? steps = null,Object? sleepHours = null,Object? exerciseMinutes = null,Object? mood = freezed,}) {
  return _then(_DailyHealth(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,waterMl: null == waterMl ? _self.waterMl : waterMl // ignore: cast_nullable_to_non_nullable
as int,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as int,sleepHours: null == sleepHours ? _self.sleepHours : sleepHours // ignore: cast_nullable_to_non_nullable
as double,exerciseMinutes: null == exerciseMinutes ? _self.exerciseMinutes : exerciseMinutes // ignore: cast_nullable_to_non_nullable
as int,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
