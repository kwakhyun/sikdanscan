// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String get name; int get age; double get height; double? get startingWeight; double get currentWeight; double get targetWeight; String get gender; int get dailyCalorieGoal; int get dailyWaterGoalMl; int get dailyStepGoal; WellnessGoal get wellnessGoal; ActivityLevel get activityLevel; bool get onboardingCompleted; String? get avatarImagePath; DateTime? get targetDate; DateTime? get onboardedAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.height, height) || other.height == height)&&(identical(other.startingWeight, startingWeight) || other.startingWeight == startingWeight)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.targetWeight, targetWeight) || other.targetWeight == targetWeight)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dailyCalorieGoal, dailyCalorieGoal) || other.dailyCalorieGoal == dailyCalorieGoal)&&(identical(other.dailyWaterGoalMl, dailyWaterGoalMl) || other.dailyWaterGoalMl == dailyWaterGoalMl)&&(identical(other.dailyStepGoal, dailyStepGoal) || other.dailyStepGoal == dailyStepGoal)&&(identical(other.wellnessGoal, wellnessGoal) || other.wellnessGoal == wellnessGoal)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.avatarImagePath, avatarImagePath) || other.avatarImagePath == avatarImagePath)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.onboardedAt, onboardedAt) || other.onboardedAt == onboardedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,age,height,startingWeight,currentWeight,targetWeight,gender,dailyCalorieGoal,dailyWaterGoalMl,dailyStepGoal,wellnessGoal,activityLevel,onboardingCompleted,avatarImagePath,targetDate,onboardedAt);

@override
String toString() {
  return 'UserProfile(name: $name, age: $age, height: $height, startingWeight: $startingWeight, currentWeight: $currentWeight, targetWeight: $targetWeight, gender: $gender, dailyCalorieGoal: $dailyCalorieGoal, dailyWaterGoalMl: $dailyWaterGoalMl, dailyStepGoal: $dailyStepGoal, wellnessGoal: $wellnessGoal, activityLevel: $activityLevel, onboardingCompleted: $onboardingCompleted, avatarImagePath: $avatarImagePath, targetDate: $targetDate, onboardedAt: $onboardedAt)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String name, int age, double height, double? startingWeight, double currentWeight, double targetWeight, String gender, int dailyCalorieGoal, int dailyWaterGoalMl, int dailyStepGoal, WellnessGoal wellnessGoal, ActivityLevel activityLevel, bool onboardingCompleted, String? avatarImagePath, DateTime? targetDate, DateTime? onboardedAt
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? age = null,Object? height = null,Object? startingWeight = freezed,Object? currentWeight = null,Object? targetWeight = null,Object? gender = null,Object? dailyCalorieGoal = null,Object? dailyWaterGoalMl = null,Object? dailyStepGoal = null,Object? wellnessGoal = null,Object? activityLevel = null,Object? onboardingCompleted = null,Object? avatarImagePath = freezed,Object? targetDate = freezed,Object? onboardedAt = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,startingWeight: freezed == startingWeight ? _self.startingWeight : startingWeight // ignore: cast_nullable_to_non_nullable
as double?,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,targetWeight: null == targetWeight ? _self.targetWeight : targetWeight // ignore: cast_nullable_to_non_nullable
as double,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,dailyCalorieGoal: null == dailyCalorieGoal ? _self.dailyCalorieGoal : dailyCalorieGoal // ignore: cast_nullable_to_non_nullable
as int,dailyWaterGoalMl: null == dailyWaterGoalMl ? _self.dailyWaterGoalMl : dailyWaterGoalMl // ignore: cast_nullable_to_non_nullable
as int,dailyStepGoal: null == dailyStepGoal ? _self.dailyStepGoal : dailyStepGoal // ignore: cast_nullable_to_non_nullable
as int,wellnessGoal: null == wellnessGoal ? _self.wellnessGoal : wellnessGoal // ignore: cast_nullable_to_non_nullable
as WellnessGoal,activityLevel: null == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as ActivityLevel,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,avatarImagePath: freezed == avatarImagePath ? _self.avatarImagePath : avatarImagePath // ignore: cast_nullable_to_non_nullable
as String?,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,onboardedAt: freezed == onboardedAt ? _self.onboardedAt : onboardedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int age,  double height,  double? startingWeight,  double currentWeight,  double targetWeight,  String gender,  int dailyCalorieGoal,  int dailyWaterGoalMl,  int dailyStepGoal,  WellnessGoal wellnessGoal,  ActivityLevel activityLevel,  bool onboardingCompleted,  String? avatarImagePath,  DateTime? targetDate,  DateTime? onboardedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.name,_that.age,_that.height,_that.startingWeight,_that.currentWeight,_that.targetWeight,_that.gender,_that.dailyCalorieGoal,_that.dailyWaterGoalMl,_that.dailyStepGoal,_that.wellnessGoal,_that.activityLevel,_that.onboardingCompleted,_that.avatarImagePath,_that.targetDate,_that.onboardedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int age,  double height,  double? startingWeight,  double currentWeight,  double targetWeight,  String gender,  int dailyCalorieGoal,  int dailyWaterGoalMl,  int dailyStepGoal,  WellnessGoal wellnessGoal,  ActivityLevel activityLevel,  bool onboardingCompleted,  String? avatarImagePath,  DateTime? targetDate,  DateTime? onboardedAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.name,_that.age,_that.height,_that.startingWeight,_that.currentWeight,_that.targetWeight,_that.gender,_that.dailyCalorieGoal,_that.dailyWaterGoalMl,_that.dailyStepGoal,_that.wellnessGoal,_that.activityLevel,_that.onboardingCompleted,_that.avatarImagePath,_that.targetDate,_that.onboardedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int age,  double height,  double? startingWeight,  double currentWeight,  double targetWeight,  String gender,  int dailyCalorieGoal,  int dailyWaterGoalMl,  int dailyStepGoal,  WellnessGoal wellnessGoal,  ActivityLevel activityLevel,  bool onboardingCompleted,  String? avatarImagePath,  DateTime? targetDate,  DateTime? onboardedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.name,_that.age,_that.height,_that.startingWeight,_that.currentWeight,_that.targetWeight,_that.gender,_that.dailyCalorieGoal,_that.dailyWaterGoalMl,_that.dailyStepGoal,_that.wellnessGoal,_that.activityLevel,_that.onboardingCompleted,_that.avatarImagePath,_that.targetDate,_that.onboardedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile extends UserProfile {
  const _UserProfile({required this.name, required this.age, required this.height, this.startingWeight, required this.currentWeight, required this.targetWeight, this.gender = 'female', this.dailyCalorieGoal = 0, this.dailyWaterGoalMl = 0, this.dailyStepGoal = 0, this.wellnessGoal = WellnessGoal.balanced, this.activityLevel = ActivityLevel.moderate, this.onboardingCompleted = false, this.avatarImagePath, this.targetDate, this.onboardedAt}): super._();
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String name;
@override final  int age;
@override final  double height;
@override final  double? startingWeight;
@override final  double currentWeight;
@override final  double targetWeight;
@override@JsonKey() final  String gender;
@override@JsonKey() final  int dailyCalorieGoal;
@override@JsonKey() final  int dailyWaterGoalMl;
@override@JsonKey() final  int dailyStepGoal;
@override@JsonKey() final  WellnessGoal wellnessGoal;
@override@JsonKey() final  ActivityLevel activityLevel;
@override@JsonKey() final  bool onboardingCompleted;
@override final  String? avatarImagePath;
@override final  DateTime? targetDate;
@override final  DateTime? onboardedAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.height, height) || other.height == height)&&(identical(other.startingWeight, startingWeight) || other.startingWeight == startingWeight)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.targetWeight, targetWeight) || other.targetWeight == targetWeight)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dailyCalorieGoal, dailyCalorieGoal) || other.dailyCalorieGoal == dailyCalorieGoal)&&(identical(other.dailyWaterGoalMl, dailyWaterGoalMl) || other.dailyWaterGoalMl == dailyWaterGoalMl)&&(identical(other.dailyStepGoal, dailyStepGoal) || other.dailyStepGoal == dailyStepGoal)&&(identical(other.wellnessGoal, wellnessGoal) || other.wellnessGoal == wellnessGoal)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.avatarImagePath, avatarImagePath) || other.avatarImagePath == avatarImagePath)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.onboardedAt, onboardedAt) || other.onboardedAt == onboardedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,age,height,startingWeight,currentWeight,targetWeight,gender,dailyCalorieGoal,dailyWaterGoalMl,dailyStepGoal,wellnessGoal,activityLevel,onboardingCompleted,avatarImagePath,targetDate,onboardedAt);

@override
String toString() {
  return 'UserProfile(name: $name, age: $age, height: $height, startingWeight: $startingWeight, currentWeight: $currentWeight, targetWeight: $targetWeight, gender: $gender, dailyCalorieGoal: $dailyCalorieGoal, dailyWaterGoalMl: $dailyWaterGoalMl, dailyStepGoal: $dailyStepGoal, wellnessGoal: $wellnessGoal, activityLevel: $activityLevel, onboardingCompleted: $onboardingCompleted, avatarImagePath: $avatarImagePath, targetDate: $targetDate, onboardedAt: $onboardedAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String name, int age, double height, double? startingWeight, double currentWeight, double targetWeight, String gender, int dailyCalorieGoal, int dailyWaterGoalMl, int dailyStepGoal, WellnessGoal wellnessGoal, ActivityLevel activityLevel, bool onboardingCompleted, String? avatarImagePath, DateTime? targetDate, DateTime? onboardedAt
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? age = null,Object? height = null,Object? startingWeight = freezed,Object? currentWeight = null,Object? targetWeight = null,Object? gender = null,Object? dailyCalorieGoal = null,Object? dailyWaterGoalMl = null,Object? dailyStepGoal = null,Object? wellnessGoal = null,Object? activityLevel = null,Object? onboardingCompleted = null,Object? avatarImagePath = freezed,Object? targetDate = freezed,Object? onboardedAt = freezed,}) {
  return _then(_UserProfile(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,startingWeight: freezed == startingWeight ? _self.startingWeight : startingWeight // ignore: cast_nullable_to_non_nullable
as double?,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,targetWeight: null == targetWeight ? _self.targetWeight : targetWeight // ignore: cast_nullable_to_non_nullable
as double,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,dailyCalorieGoal: null == dailyCalorieGoal ? _self.dailyCalorieGoal : dailyCalorieGoal // ignore: cast_nullable_to_non_nullable
as int,dailyWaterGoalMl: null == dailyWaterGoalMl ? _self.dailyWaterGoalMl : dailyWaterGoalMl // ignore: cast_nullable_to_non_nullable
as int,dailyStepGoal: null == dailyStepGoal ? _self.dailyStepGoal : dailyStepGoal // ignore: cast_nullable_to_non_nullable
as int,wellnessGoal: null == wellnessGoal ? _self.wellnessGoal : wellnessGoal // ignore: cast_nullable_to_non_nullable
as WellnessGoal,activityLevel: null == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as ActivityLevel,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,avatarImagePath: freezed == avatarImagePath ? _self.avatarImagePath : avatarImagePath // ignore: cast_nullable_to_non_nullable
as String?,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,onboardedAt: freezed == onboardedAt ? _self.onboardedAt : onboardedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
