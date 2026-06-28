// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_recognition_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FoodRecognitionResult {

 String get summary; double get confidence; bool get needsReview; String? get warning; List<RecognizedFoodItem> get items;
/// Create a copy of FoodRecognitionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodRecognitionResultCopyWith<FoodRecognitionResult> get copyWith => _$FoodRecognitionResultCopyWithImpl<FoodRecognitionResult>(this as FoodRecognitionResult, _$identity);

  /// Serializes this FoodRecognitionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodRecognitionResult&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.needsReview, needsReview) || other.needsReview == needsReview)&&(identical(other.warning, warning) || other.warning == warning)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,summary,confidence,needsReview,warning,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'FoodRecognitionResult(summary: $summary, confidence: $confidence, needsReview: $needsReview, warning: $warning, items: $items)';
}


}

/// @nodoc
abstract mixin class $FoodRecognitionResultCopyWith<$Res>  {
  factory $FoodRecognitionResultCopyWith(FoodRecognitionResult value, $Res Function(FoodRecognitionResult) _then) = _$FoodRecognitionResultCopyWithImpl;
@useResult
$Res call({
 String summary, double confidence, bool needsReview, String? warning, List<RecognizedFoodItem> items
});




}
/// @nodoc
class _$FoodRecognitionResultCopyWithImpl<$Res>
    implements $FoodRecognitionResultCopyWith<$Res> {
  _$FoodRecognitionResultCopyWithImpl(this._self, this._then);

  final FoodRecognitionResult _self;
  final $Res Function(FoodRecognitionResult) _then;

/// Create a copy of FoodRecognitionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? confidence = null,Object? needsReview = null,Object? warning = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,needsReview: null == needsReview ? _self.needsReview : needsReview // ignore: cast_nullable_to_non_nullable
as bool,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<RecognizedFoodItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [FoodRecognitionResult].
extension FoodRecognitionResultPatterns on FoodRecognitionResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodRecognitionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodRecognitionResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodRecognitionResult value)  $default,){
final _that = this;
switch (_that) {
case _FoodRecognitionResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodRecognitionResult value)?  $default,){
final _that = this;
switch (_that) {
case _FoodRecognitionResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String summary,  double confidence,  bool needsReview,  String? warning,  List<RecognizedFoodItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodRecognitionResult() when $default != null:
return $default(_that.summary,_that.confidence,_that.needsReview,_that.warning,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String summary,  double confidence,  bool needsReview,  String? warning,  List<RecognizedFoodItem> items)  $default,) {final _that = this;
switch (_that) {
case _FoodRecognitionResult():
return $default(_that.summary,_that.confidence,_that.needsReview,_that.warning,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String summary,  double confidence,  bool needsReview,  String? warning,  List<RecognizedFoodItem> items)?  $default,) {final _that = this;
switch (_that) {
case _FoodRecognitionResult() when $default != null:
return $default(_that.summary,_that.confidence,_that.needsReview,_that.warning,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FoodRecognitionResult implements FoodRecognitionResult {
  const _FoodRecognitionResult({this.summary = '', this.confidence = 0.0, this.needsReview = true, this.warning, final  List<RecognizedFoodItem> items = const <RecognizedFoodItem>[]}): _items = items;
  factory _FoodRecognitionResult.fromJson(Map<String, dynamic> json) => _$FoodRecognitionResultFromJson(json);

@override@JsonKey() final  String summary;
@override@JsonKey() final  double confidence;
@override@JsonKey() final  bool needsReview;
@override final  String? warning;
 final  List<RecognizedFoodItem> _items;
@override@JsonKey() List<RecognizedFoodItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of FoodRecognitionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodRecognitionResultCopyWith<_FoodRecognitionResult> get copyWith => __$FoodRecognitionResultCopyWithImpl<_FoodRecognitionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FoodRecognitionResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodRecognitionResult&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.needsReview, needsReview) || other.needsReview == needsReview)&&(identical(other.warning, warning) || other.warning == warning)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,summary,confidence,needsReview,warning,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'FoodRecognitionResult(summary: $summary, confidence: $confidence, needsReview: $needsReview, warning: $warning, items: $items)';
}


}

/// @nodoc
abstract mixin class _$FoodRecognitionResultCopyWith<$Res> implements $FoodRecognitionResultCopyWith<$Res> {
  factory _$FoodRecognitionResultCopyWith(_FoodRecognitionResult value, $Res Function(_FoodRecognitionResult) _then) = __$FoodRecognitionResultCopyWithImpl;
@override @useResult
$Res call({
 String summary, double confidence, bool needsReview, String? warning, List<RecognizedFoodItem> items
});




}
/// @nodoc
class __$FoodRecognitionResultCopyWithImpl<$Res>
    implements _$FoodRecognitionResultCopyWith<$Res> {
  __$FoodRecognitionResultCopyWithImpl(this._self, this._then);

  final _FoodRecognitionResult _self;
  final $Res Function(_FoodRecognitionResult) _then;

/// Create a copy of FoodRecognitionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? confidence = null,Object? needsReview = null,Object? warning = freezed,Object? items = null,}) {
  return _then(_FoodRecognitionResult(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,needsReview: null == needsReview ? _self.needsReview : needsReview // ignore: cast_nullable_to_non_nullable
as bool,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<RecognizedFoodItem>,
  ));
}


}


/// @nodoc
mixin _$RecognizedFoodItem {

 String get name; int get calories; double get carbs; double get protein; double get fat; String? get servingSize; double get confidence;
/// Create a copy of RecognizedFoodItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecognizedFoodItemCopyWith<RecognizedFoodItem> get copyWith => _$RecognizedFoodItemCopyWithImpl<RecognizedFoodItem>(this as RecognizedFoodItem, _$identity);

  /// Serializes this RecognizedFoodItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecognizedFoodItem&&(identical(other.name, name) || other.name == name)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.servingSize, servingSize) || other.servingSize == servingSize)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,calories,carbs,protein,fat,servingSize,confidence);

@override
String toString() {
  return 'RecognizedFoodItem(name: $name, calories: $calories, carbs: $carbs, protein: $protein, fat: $fat, servingSize: $servingSize, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $RecognizedFoodItemCopyWith<$Res>  {
  factory $RecognizedFoodItemCopyWith(RecognizedFoodItem value, $Res Function(RecognizedFoodItem) _then) = _$RecognizedFoodItemCopyWithImpl;
@useResult
$Res call({
 String name, int calories, double carbs, double protein, double fat, String? servingSize, double confidence
});




}
/// @nodoc
class _$RecognizedFoodItemCopyWithImpl<$Res>
    implements $RecognizedFoodItemCopyWith<$Res> {
  _$RecognizedFoodItemCopyWithImpl(this._self, this._then);

  final RecognizedFoodItem _self;
  final $Res Function(RecognizedFoodItem) _then;

/// Create a copy of RecognizedFoodItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? calories = null,Object? carbs = null,Object? protein = null,Object? fat = null,Object? servingSize = freezed,Object? confidence = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double,servingSize: freezed == servingSize ? _self.servingSize : servingSize // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RecognizedFoodItem].
extension RecognizedFoodItemPatterns on RecognizedFoodItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecognizedFoodItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecognizedFoodItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecognizedFoodItem value)  $default,){
final _that = this;
switch (_that) {
case _RecognizedFoodItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecognizedFoodItem value)?  $default,){
final _that = this;
switch (_that) {
case _RecognizedFoodItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int calories,  double carbs,  double protein,  double fat,  String? servingSize,  double confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecognizedFoodItem() when $default != null:
return $default(_that.name,_that.calories,_that.carbs,_that.protein,_that.fat,_that.servingSize,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int calories,  double carbs,  double protein,  double fat,  String? servingSize,  double confidence)  $default,) {final _that = this;
switch (_that) {
case _RecognizedFoodItem():
return $default(_that.name,_that.calories,_that.carbs,_that.protein,_that.fat,_that.servingSize,_that.confidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int calories,  double carbs,  double protein,  double fat,  String? servingSize,  double confidence)?  $default,) {final _that = this;
switch (_that) {
case _RecognizedFoodItem() when $default != null:
return $default(_that.name,_that.calories,_that.carbs,_that.protein,_that.fat,_that.servingSize,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecognizedFoodItem implements RecognizedFoodItem {
  const _RecognizedFoodItem({required this.name, required this.calories, required this.carbs, required this.protein, required this.fat, this.servingSize, this.confidence = 0.0});
  factory _RecognizedFoodItem.fromJson(Map<String, dynamic> json) => _$RecognizedFoodItemFromJson(json);

@override final  String name;
@override final  int calories;
@override final  double carbs;
@override final  double protein;
@override final  double fat;
@override final  String? servingSize;
@override@JsonKey() final  double confidence;

/// Create a copy of RecognizedFoodItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecognizedFoodItemCopyWith<_RecognizedFoodItem> get copyWith => __$RecognizedFoodItemCopyWithImpl<_RecognizedFoodItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecognizedFoodItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecognizedFoodItem&&(identical(other.name, name) || other.name == name)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.servingSize, servingSize) || other.servingSize == servingSize)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,calories,carbs,protein,fat,servingSize,confidence);

@override
String toString() {
  return 'RecognizedFoodItem(name: $name, calories: $calories, carbs: $carbs, protein: $protein, fat: $fat, servingSize: $servingSize, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$RecognizedFoodItemCopyWith<$Res> implements $RecognizedFoodItemCopyWith<$Res> {
  factory _$RecognizedFoodItemCopyWith(_RecognizedFoodItem value, $Res Function(_RecognizedFoodItem) _then) = __$RecognizedFoodItemCopyWithImpl;
@override @useResult
$Res call({
 String name, int calories, double carbs, double protein, double fat, String? servingSize, double confidence
});




}
/// @nodoc
class __$RecognizedFoodItemCopyWithImpl<$Res>
    implements _$RecognizedFoodItemCopyWith<$Res> {
  __$RecognizedFoodItemCopyWithImpl(this._self, this._then);

  final _RecognizedFoodItem _self;
  final $Res Function(_RecognizedFoodItem) _then;

/// Create a copy of RecognizedFoodItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? calories = null,Object? carbs = null,Object? protein = null,Object? fat = null,Object? servingSize = freezed,Object? confidence = null,}) {
  return _then(_RecognizedFoodItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double,servingSize: freezed == servingSize ? _self.servingSize : servingSize // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
