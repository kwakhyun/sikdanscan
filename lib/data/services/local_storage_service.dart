import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _userProfileBox = 'user_profile';
  static const String _weightRecordsBox = 'weight_records';
  static const String _mealRecordsBox = 'meal_records';
  static const String _dailyHealthBox = 'daily_health';
  static const String _settingsBox = 'settings';

  static const String _chatHistoryKey = 'chat_history';
  static const String _pendingMealSyncKey = 'pending_meal_sync';
  static const String _localDataOwnerKey = 'local_data_owner';
  static const String _mealPullCursorKey = 'meal_pull_cursor';
  static const String _profileEditedAtKey = 'profile_edited_at';
  static const String _profileSyncPendingKey = 'profile_sync_pending';
  static const String _captureDraftKey = 'capture_draft';

  LocalStorageService();

  Future<void> initialize() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(_userProfileBox),
      Hive.openBox<String>(_weightRecordsBox),
      Hive.openBox<String>(_mealRecordsBox),
      Hive.openBox<String>(_dailyHealthBox),
      Hive.openBox<String>(_settingsBox),
    ]);
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _writableBox(_userProfileBox).put('profile', jsonEncode(profile));
  }

  Map<String, dynamic>? getUserProfile() {
    return _decodeJsonMap(_readableBox(_userProfileBox)?.get('profile'));
  }

  Future<void> saveWeightRecords(List<Map<String, dynamic>> records) async {
    await _writableBox(_weightRecordsBox).put('records', jsonEncode(records));
  }

  List<Map<String, dynamic>> getWeightRecords() {
    return _decodeJsonMapList(_readableBox(_weightRecordsBox)?.get('records'));
  }

  Future<void> addWeightRecord(Map<String, dynamic> record) async {
    final records = getWeightRecords();
    records.add(record);
    await saveWeightRecords(records);
  }

  Future<void> removeWeightRecord(String id) async {
    final records = getWeightRecords();
    records.removeWhere((r) => r['id'] == id);
    await saveWeightRecords(records);
  }

  Future<void> saveMealRecords(List<Map<String, dynamic>> records) async {
    await _writableBox(_mealRecordsBox).put('records', jsonEncode(records));
  }

  List<Map<String, dynamic>> getMealRecords() {
    return _decodeJsonMapList(_readableBox(_mealRecordsBox)?.get('records'));
  }

  Future<void> addMealRecord(Map<String, dynamic> record) async {
    final records = getMealRecords();
    records.add(record);
    await saveMealRecords(records);
  }

  Future<void> removeMealRecord(String id) async {
    final records = getMealRecords();
    records.removeWhere((r) => r['id'] == id);
    await saveMealRecords(records);
  }

  Future<void> saveDailyHealth(Map<String, dynamic> health) async {
    final date = DateTime.tryParse(health['date'] as String? ?? '');
    final dateKey = _dateKey(date ?? DateTime.now());
    await _writableBox(_dailyHealthBox).put(dateKey, jsonEncode(health));
  }

  Map<String, dynamic>? getDailyHealth(String dateKey) {
    return _decodeJsonMap(_readableBox(_dailyHealthBox)?.get(dateKey));
  }

  Map<String, dynamic>? getDailyHealthFor(DateTime date) {
    return getDailyHealth(_dateKey(date));
  }

  Map<String, dynamic>? getTodayHealth() {
    return getDailyHealthFor(DateTime.now());
  }

  Future<void> saveSetting(String key, dynamic value) async {
    await _writableBox(_settingsBox).put(key, jsonEncode(value));
  }

  T? getSetting<T>(String key) {
    final data = _readableBox(_settingsBox)?.get(key);
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data);
      return decoded is T ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> removeSetting(String key) async {
    await _readableBox(_settingsBox)?.delete(key);
  }

  /// Persisted AI coach conversation (most recent last).
  List<Map<String, dynamic>> getChatHistory() {
    return _decodeJsonMapList(_readableBox(_settingsBox)?.get(_chatHistoryKey));
  }

  Future<void> saveChatHistory(List<Map<String, dynamic>> messages) async {
    await _writableBox(_settingsBox).put(_chatHistoryKey, jsonEncode(messages));
  }

  /// Meal sync operations that failed and must be retried
  /// (`{"op": "upsert" | "delete", "id": "..."}`).
  List<Map<String, dynamic>> getPendingMealSync() {
    return _decodeJsonMapList(
      _readableBox(_settingsBox)?.get(_pendingMealSyncKey),
    );
  }

  Future<void> savePendingMealSync(
    List<Map<String, dynamic>> operations,
  ) async {
    await _writableBox(
      _settingsBox,
    ).put(_pendingMealSyncKey, jsonEncode(operations));
  }

  /// Id of the account whose data is on this device, or `null` for data
  /// that was never tied to an account. Kept on sign-out so signing in to a
  /// different account does not upload someone else's records into it.
  String? getLocalDataOwner() {
    try {
      return getSetting<String>(_localDataOwnerKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> setLocalDataOwner(String? userId) async {
    if (userId == null) {
      await removeSetting(_localDataOwnerKey);
    } else {
      await saveSetting(_localDataOwnerKey, userId);
    }
  }

  /// Clears the signed-in person's records (profile, weights, meals, water,
  /// coach conversation, sync queue) but keeps device preferences such as
  /// theme and language. Used when another account signs in on this device.
  /// Unfinished meal review (see MealCaptureController).
  Map<String, dynamic>? getCaptureDraft() {
    final raw = _readableBox(_settingsBox)?.get(_captureDraftKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCaptureDraft(Map<String, dynamic> draft) async {
    await _writableBox(_settingsBox).put(_captureDraftKey, jsonEncode(draft));
  }

  Future<void> clearCaptureDraft() async {
    await _readableBox(_settingsBox)?.delete(_captureDraftKey);
  }

  /// Server time of the newest meal row already pulled from the account.
  DateTime? getMealPullCursor() => _readTime(_mealPullCursorKey);

  Future<void> setMealPullCursor(DateTime? value) =>
      _writeTime(_mealPullCursorKey, value);

  /// When the profile was last changed on this device (or the server time
  /// of the copy taken from the account), for newer-wins profile sync.
  DateTime? getProfileEditedAt() => _readTime(_profileEditedAtKey);

  Future<void> setProfileEditedAt(DateTime? value) =>
      _writeTime(_profileEditedAtKey, value);

  /// A profile change has not reached the account yet.
  bool get profileSyncPending {
    try {
      return getSetting<bool>(_profileSyncPendingKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setProfileSyncPending(bool value) => value
      ? saveSetting(_profileSyncPendingKey, true)
      : removeSetting(_profileSyncPendingKey);

  DateTime? _readTime(String key) {
    try {
      final value = getSetting<String>(key);
      return value == null ? null : DateTime.tryParse(value)?.toUtc();
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeTime(String key, DateTime? value) {
    return value == null
        ? removeSetting(key)
        : saveSetting(key, value.toUtc().toIso8601String());
  }

  Future<void> clearUserData() async {
    await Future.wait([
      for (final name in const [
        _userProfileBox,
        _weightRecordsBox,
        _mealRecordsBox,
        _dailyHealthBox,
      ])
        if (_readableBox(name) != null) _readableBox(name)!.clear(),
    ]);
    final settings = _readableBox(_settingsBox);
    if (settings != null) {
      await settings.deleteAll(const [
        _chatHistoryKey,
        _pendingMealSyncKey,
        _mealPullCursorKey,
        _profileEditedAtKey,
        _profileSyncPendingKey,
        _captureDraftKey,
      ]);
    }
  }

  Future<void> clearAll() async {
    await Future.wait([
      for (final name in const [
        _userProfileBox,
        _weightRecordsBox,
        _mealRecordsBox,
        _dailyHealthBox,
        _settingsBox,
      ])
        if (_readableBox(name) != null) _readableBox(name)!.clear(),
    ]);
  }

  bool get hasData => _readableBox(_userProfileBox)?.isNotEmpty ?? false;

  /// Reads tolerate an unopened box (e.g. widget tests that never call
  /// [initialize]) and fall back to empty values.
  Box<String>? _readableBox(String name) {
    if (!Hive.isBoxOpen(name)) return null;
    return Hive.box<String>(name);
  }

  /// Writes require the box; failing loudly lets notifiers roll back.
  Box<String> _writableBox(String name) {
    final box = _readableBox(name);
    if (box == null) {
      throw StateError('Local storage box "$name" is not open.');
    }
    return box;
  }

  static String _dateKey(DateTime date) {
    return DateTime(date.year, date.month, date.day).toIso8601String();
  }

  static Map<String, dynamic>? _decodeJsonMap(String? data) {
    if (data == null || data.isEmpty) return null;

    try {
      final decoded = jsonDecode(data);
      if (decoded is! Map) return null;

      return decoded.map((key, value) => MapEntry(key.toString(), value));
    } catch (_) {
      return null;
    }
  }

  static List<Map<String, dynamic>> _decodeJsonMapList(String? data) {
    if (data == null || data.isEmpty) return [];

    try {
      final decoded = jsonDecode(data);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map>()
          .map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}
