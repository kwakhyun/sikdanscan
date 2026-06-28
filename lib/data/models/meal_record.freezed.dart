// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MealRecord {

 String get id; DateTime get date; MealType get mealType; String get name; int get calories; double get carbs; double get protein; double get fat; String? get imageUrl; String? get servingSize; bool get isAiRecognized; double? get recognitionConfidence; String? get memo;
/// Create a copy of MealRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealRecordCopyWith<MealRecord> get copyWith => _$MealRecordCopyWithImpl<MealRecord>(this as MealRecord, _$identity);

  /// Serializes this MealRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.name, name) || other.name == name)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.servingSize, servingSize) || other.servingSize == servingSize)&&(identical(other.isAiRecognized, isAiRecognized) || other.isAiRecognized == isAiRecognized)&&(identical(other.recognitionConfidence, recognitionConfidence) || other.recognitionConfidence == recognitionConfidence)&&(identical(other.memo, memo) || other.memo == memo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,mealType,name,calories,carbs,protein,fat,imageUrl,servingSize,isAiRecognized,recognitionConfidence,memo);

@override
String toString() {
  return 'MealRecord(id: $id, date: $date, mealType: $mealType, name: $name, calories: $calories, carbs: $carbs, protein: $protein, fat: $fat, imageUrl: $imageUrl, servingSize: $servingSize, isAiRecognized: $isAiRecognized, recognitionConfidence: $recognitionConfidence, memo: $memo)';
}


}

/// @nodoc
abstract mixin class $MealRecordCopyWith<$Res>  {
  factory $MealRecordCopyWith(MealRecord value, $Res Function(MealRecord) _then) = _$MealRecordCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, MealType mealType, String name, int calories, double carbs, double protein, double fat, String? imageUrl, String? servingSize, bool isAiRecognized, double? recognitionConfidence, String? memo
});




}
/// @nodoc
class _$MealRecordCopyWithImpl<$Res>
    implements $MealRecordCopyWith<$Res> {
  _$MealRecordCopyWithImpl(this._self, this._then);

  final MealRecord _self;
  final $Res Function(MealRecord) _then;

/// Create a copy of MealRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? mealType = null,Object? name = null,Object? calories = null,Object? carbs = null,Object? protein = null,Object? fat = null,Object? imageUrl = freezed,Object? servingSize = freezed,Object? isAiRecognized = null,Object? recognitionConfidence = freezed,Object? memo = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,servingSize: freezed == servingSize ? _self.servingSize : servingSize // ignore: cast_nullable_to_non_nullable
as String?,isAiRecognized: null == isAiRecognized ? _self.isAiRecognized : isAiRecognized // ignore: cast_nullable_to_non_nullable
as bool,recognitionConfidence: freezed == recognitionConfidence ? _self.recognitionConfidence : recognitionConfidence // ignore: cast_nullable_to_non_nullable
as double?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MealRecord].
extension MealRecordPatterns on MealRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MealRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MealRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MealRecord value)  $default,){
final _that = this;
switch (_that) {
case _MealRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MealRecord value)?  $default,){
final _that = this;
switch (_that) {
case _MealRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  MealType mealType,  String name,  int calories,  double carbs,  double protein,  double fat,  String? imageUrl,  String? servingSize,  bool isAiRecognized,  double? recognitionConfidence,  String? memo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealRecord() when $default != null:
return $default(_that.id,_that.date,_that.mealType,_that.name,_that.calories,_that.carbs,_that.protein,_that.fat,_that.imageUrl,_that.servingSize,_that.isAiRecognized,_that.recognitionConfidence,_that.memo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  MealType mealType,  String name,  int calories,  double carbs,  double protein,  double fat,  String? imageUrl,  String? servingSize,  bool isAiRecognized,  double? recognitionConfidence,  String? memo)  $default,) {final _that = this;
switch (_that) {
case _MealRecord():
return $default(_that.id,_that.date,_that.mealType,_that.name,_that.calories,_that.carbs,_that.protein,_that.fat,_that.imageUrl,_that.servingSize,_that.isAiRecognized,_that.recognitionConfidence,_that.memo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  MealType mealType,  String name,  int calories,  double carbs,  double protein,  double fat,  String? imageUrl,  String? servingSize,  bool isAiRecognized,  double? recognitionConfidence,  String? memo)?  $default,) {final _that = this;
switch (_that) {
case _MealRecord() when $default != null:
return $default(_that.id,_that.date,_that.mealType,_that.name,_that.calories,_that.carbs,_that.protein,_that.fat,_that.imageUrl,_that.servingSize,_that.isAiRecognized,_that.recognitionConfidence,_that.memo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MealRecord implements MealRecord {
  const _MealRecord({required this.id, required this.date, required this.mealType, required this.name, required this.calories, required this.carbs, required this.protein, required this.fat, this.imageUrl, this.servingSize, this.isAiRecognized = false, this.recognitionConfidence, this.memo});
  factory _MealRecord.fromJson(Map<String, dynamic> json) => _$MealRecordFromJson(json);

@override final  String id;
@override final  DateTime date;
@override final  MealType mealType;
@override final  String name;
@override final  int calories;
@override final  double carbs;
@override final  double protein;
@override final  double fat;
@override final  String? imageUrl;
@override final  String? servingSize;
@override@JsonKey() final  bool isAiRecognized;
@override final  double? recognitionConfidence;
@override final  String? memo;

/// Create a copy of MealRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealRecordCopyWith<_MealRecord> get copyWith => __$MealRecordCopyWithImpl<_MealRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.name, name) || other.name == name)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.servingSize, servingSize) || other.servingSize == servingSize)&&(identical(other.isAiRecognized, isAiRecognized) || other.isAiRecognized == isAiRecognized)&&(identical(other.recognitionConfidence, recognitionConfidence) || other.recognitionConfidence == recognitionConfidence)&&(identical(other.memo, memo) || other.memo == memo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,date,mealType,name,calories,carbs,protein,fat,imageUrl,servingSize,isAiRecognized,recognitionConfidence,memo);

@override
String toString() {
  return 'MealRecord(id: $id, date: $date, mealType: $mealType, name: $name, calories: $calories, carbs: $carbs, protein: $protein, fat: $fat, imageUrl: $imageUrl, servingSize: $servingSize, isAiRecognized: $isAiRecognized, recognitionConfidence: $recognitionConfidence, memo: $memo)';
}


}

/// @nodoc
abstract mixin class _$MealRecordCopyWith<$Res> implements $MealRecordCopyWith<$Res> {
  factory _$MealRecordCopyWith(_MealRecord value, $Res Function(_MealRecord) _then) = __$MealRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, MealType mealType, String name, int calories, double carbs, double protein, double fat, String? imageUrl, String? servingSize, bool isAiRecognized, double? recognitionConfidence, String? memo
});




}
/// @nodoc
class __$MealRecordCopyWithImpl<$Res>
    implements _$MealRecordCopyWith<$Res> {
  __$MealRecordCopyWithImpl(this._self, this._then);

  final _MealRecord _self;
  final $Res Function(_MealRecord) _then;

/// Create a copy of MealRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? mealType = null,Object? name = null,Object? calories = null,Object? carbs = null,Object? protein = null,Object? fat = null,Object? imageUrl = freezed,Object? servingSize = freezed,Object? isAiRecognized = null,Object? recognitionConfidence = freezed,Object? memo = freezed,}) {
  return _then(_MealRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,servingSize: freezed == servingSize ? _self.servingSize : servingSize // ignore: cast_nullable_to_non_nullable
as String?,isAiRecognized: null == isAiRecognized ? _self.isAiRecognized : isAiRecognized // ignore: cast_nullable_to_non_nullable
as bool,recognitionConfidence: freezed == recognitionConfidence ? _self.recognitionConfidence : recognitionConfidence // ignore: cast_nullable_to_non_nullable
as double?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
