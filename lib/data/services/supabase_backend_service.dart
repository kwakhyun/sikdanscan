import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/food_recognition_result.dart';
import '../models/meal_record.dart';
import '../models/user_profile.dart';
import 'supabase_config.dart';

class SupabaseBackendService {
  static const oauthRedirectUrl = 'sikdanscan://auth/callback';

  const SupabaseBackendService({
    required SupabaseConfig config,
    SupabaseClient? client,
  }) : _config = config,
       _client = client;

  final SupabaseConfig _config;
  final SupabaseClient? _client;

  bool get isConfigured => _config.isConfigured && _client != null;

  User? get currentUser => _client?.auth.currentUser;

  Stream<AuthState> get authStateChanges =>
      _requireClient().auth.onAuthStateChange;

  Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
    String displayName = '',
  }) {
    return _requireClient().auth.signUp(
      email: email.trim(),
      password: password,
      data: {'display_name': displayName.trim()},
    );
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _requireClient().auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<bool> signInWithOAuthProvider(OAuthProvider provider) {
    return _requireClient().auth.signInWithOAuth(
      provider,
      redirectTo: oauthRedirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() {
    return _requireClient().auth.signOut();
  }

  Future<void> upsertProfile(UserProfile profile) async {
    final userId = _requireUserId();
    await _requireClient()
        .from('profiles')
        .upsert(_profileToRow(userId, profile));
  }

  Future<UserProfile?> fetchProfile() async {
    final userId = _requireUserId();
    final row = await _requireClient()
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;

    return _profileFromRow(Map<String, dynamic>.from(row));
  }

  Future<void> upsertMealRecord(MealRecord record) async {
    final userId = _requireUserId();
    await _requireClient()
        .from('meal_records')
        .upsert(_mealRecordToRow(userId, record));
  }

  Future<List<MealRecord>> fetchMealRecords({
    DateTime? from,
    DateTime? to,
  }) async {
    final userId = _requireUserId();
    var query = _requireClient()
        .from('meal_records')
        .select()
        .eq('user_id', userId);
    if (from != null) {
      query = query.gte('date', from.toUtc().toIso8601String());
    }
    if (to != null) {
      query = query.lt('date', to.toUtc().toIso8601String());
    }

    final rows = await query.order('date', ascending: false);
    return rows
        .whereType<Map>()
        .map((row) => _mealRecordFromRow(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<void> deleteMealRecord(String id) async {
    final userId = _requireUserId();
    await _requireClient()
        .from('meal_records')
        .delete()
        .eq('user_id', userId)
        .eq('id', id);
  }

  Future<void> saveFoodRecognitionResult({
    required FoodRecognitionResult result,
    String? mealRecordId,
    String? imagePath,
  }) async {
    final userId = _requireUserId();
    await _requireClient().from('food_recognition_results').insert({
      'user_id': userId,
      'meal_record_id': mealRecordId,
      'image_path': imagePath,
      'summary': result.summary,
      'confidence': result.confidence,
      'needs_review': result.needsReview,
      'warning': result.warning,
      'items': result.items.map((item) => item.toJson()).toList(),
    });
  }

  Future<String> uploadMealImage({
    required String recordId,
    required Uint8List bytes,
    String extension = 'jpg',
    String contentType = 'image/jpeg',
  }) {
    return _uploadUserFile(
      bucket: 'meal-images',
      objectName: '$recordId.$extension',
      bytes: bytes,
      contentType: contentType,
    );
  }

  Future<String> uploadAvatarImage({
    required Uint8List bytes,
    String extension = 'jpg',
    String contentType = 'image/jpeg',
  }) {
    return _uploadUserFile(
      bucket: 'avatars',
      objectName: 'avatar.$extension',
      bytes: bytes,
      contentType: contentType,
    );
  }

  Future<String> createSignedImageUrl({
    required String bucket,
    required String path,
    int expiresInSeconds = 60 * 10,
  }) {
    return _requireClient().storage
        .from(bucket)
        .createSignedUrl(path, expiresInSeconds);
  }

  Future<String> _uploadUserFile({
    required String bucket,
    required String objectName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final userId = _requireUserId();
    final path = '$userId/$objectName';
    await _requireClient().storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
            cacheControl: '3600',
          ),
        );
    return path;
  }

  SupabaseClient _requireClient() {
    final client = _client;
    if (!_config.isConfigured || client == null) {
      throw const SupabaseNotConfiguredException();
    }
    return client;
  }

  String _requireUserId() {
    final userId = _requireClient().auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const SupabaseAuthRequiredException();
    }
    return userId;
  }

  static Map<String, dynamic> _profileToRow(
    String userId,
    UserProfile profile,
  ) {
    return {
      'id': userId,
      'name': profile.name,
      'age': profile.age,
      'height': profile.height,
      'starting_weight': profile.startingWeight,
      'current_weight': profile.currentWeight,
      'target_weight': profile.targetWeight,
      'gender': profile.gender,
      'daily_calorie_goal': profile.dailyCalorieGoal,
      'daily_water_goal_ml': profile.dailyWaterGoalMl,
      'daily_step_goal': profile.dailyStepGoal,
      'wellness_goal': profile.wellnessGoal.name,
      'activity_level': profile.activityLevel.name,
      'onboarding_completed': profile.onboardingCompleted,
      'avatar_image_path': profile.avatarImagePath,
      'target_date': profile.targetDate?.toUtc().toIso8601String(),
      'onboarded_at': profile.onboardedAt?.toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  static UserProfile _profileFromRow(Map<String, dynamic> row) {
    return UserProfile(
      name: _readString(row['name']),
      age: _readInt(row['age']),
      height: _readDouble(row['height']),
      startingWeight: _readNullableDouble(row['starting_weight']),
      currentWeight: _readDouble(row['current_weight']),
      targetWeight: _readDouble(row['target_weight']),
      gender: _readString(row['gender'], fallback: 'female'),
      dailyCalorieGoal: _readInt(row['daily_calorie_goal']),
      dailyWaterGoalMl: _readInt(row['daily_water_goal_ml']),
      dailyStepGoal: _readInt(row['daily_step_goal']),
      wellnessGoal: _wellnessGoalFromName(row['wellness_goal'] as String?),
      activityLevel: _activityLevelFromName(row['activity_level'] as String?),
      onboardingCompleted: row['onboarding_completed'] == true,
      avatarImagePath: row['avatar_image_path'] as String?,
      targetDate: _readDateTime(row['target_date']),
      onboardedAt: _readDateTime(row['onboarded_at']),
    );
  }

  static Map<String, dynamic> _mealRecordToRow(
    String userId,
    MealRecord record,
  ) {
    return {
      'id': record.id,
      'user_id': userId,
      'date': record.date.toUtc().toIso8601String(),
      'meal_type': record.mealType.name,
      'name': record.name,
      'calories': record.calories,
      'carbs': record.carbs,
      'protein': record.protein,
      'fat': record.fat,
      'image_url': record.imageUrl,
      'serving_size': record.servingSize,
      'is_ai_recognized': record.isAiRecognized,
      'recognition_confidence': record.recognitionConfidence,
      'memo': record.memo,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  static MealRecord _mealRecordFromRow(Map<String, dynamic> row) {
    return MealRecord(
      id: _readString(row['id']),
      date: _readDateTime(row['date']) ?? DateTime.now(),
      mealType: _mealTypeFromName(row['meal_type'] as String?),
      name: _readString(row['name']),
      calories: _readInt(row['calories']),
      carbs: _readDouble(row['carbs']),
      protein: _readDouble(row['protein']),
      fat: _readDouble(row['fat']),
      imageUrl: row['image_url'] as String?,
      servingSize: row['serving_size'] as String?,
      isAiRecognized: row['is_ai_recognized'] == true,
      recognitionConfidence: _readNullableDouble(row['recognition_confidence']),
      memo: row['memo'] as String?,
    );
  }

  static WellnessGoal _wellnessGoalFromName(String? name) {
    return WellnessGoal.values.firstWhere(
      (goal) => goal.name == name,
      orElse: () => WellnessGoal.balanced,
    );
  }

  static ActivityLevel _activityLevelFromName(String? name) {
    return ActivityLevel.values.firstWhere(
      (level) => level.name == name,
      orElse: () => ActivityLevel.moderate,
    );
  }

  static MealType _mealTypeFromName(String? name) {
    return MealType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => MealType.breakfast,
    );
  }

  static String _readString(Object? value, {String fallback = ''}) {
    return value is String ? value : fallback;
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _readDouble(Object? value) {
    return _readNullableDouble(value) ?? 0;
  }

  static double? _readNullableDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _readDateTime(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

class SupabaseNotConfiguredException implements Exception {
  const SupabaseNotConfiguredException();

  @override
  String toString() => 'Supabase is not configured.';
}

class SupabaseAuthRequiredException implements Exception {
  const SupabaseAuthRequiredException();

  @override
  String toString() => 'A signed-in Supabase user is required.';
}
