import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _userProfileBox = 'user_profile';
  static const String _weightRecordsBox = 'weight_records';
  static const String _mealRecordsBox = 'meal_records';
  static const String _dailyHealthBox = 'daily_health';
  static const String _settingsBox = 'settings';

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
    final box = Hive.box<String>(_userProfileBox);
    await box.put('profile', jsonEncode(profile));
  }

  Map<String, dynamic>? getUserProfile() {
    final box = Hive.box<String>(_userProfileBox);
    return _decodeJsonMap(box.get('profile'));
  }

  Future<void> saveWeightRecords(List<Map<String, dynamic>> records) async {
    final box = Hive.box<String>(_weightRecordsBox);
    await box.put('records', jsonEncode(records));
  }

  List<Map<String, dynamic>> getWeightRecords() {
    final box = Hive.box<String>(_weightRecordsBox);
    return _decodeJsonMapList(box.get('records'));
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
    final box = Hive.box<String>(_mealRecordsBox);
    await box.put('records', jsonEncode(records));
  }

  List<Map<String, dynamic>> getMealRecords() {
    final box = Hive.box<String>(_mealRecordsBox);
    return _decodeJsonMapList(box.get('records'));
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
    final box = Hive.box<String>(_dailyHealthBox);
    final date = DateTime.tryParse(health['date'] as String? ?? '');
    final dateKey = _dateKey(date ?? DateTime.now());
    await box.put(dateKey, jsonEncode(health));
  }

  Map<String, dynamic>? getDailyHealth(String dateKey) {
    final box = Hive.box<String>(_dailyHealthBox);
    return _decodeJsonMap(box.get(dateKey));
  }

  Map<String, dynamic>? getTodayHealth() {
    return getDailyHealth(_dateKey(DateTime.now()));
  }

  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box<String>(_settingsBox);
    await box.put(key, jsonEncode(value));
  }

  T? getSetting<T>(String key) {
    final box = Hive.box<String>(_settingsBox);
    final data = box.get(key);
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data);
      return decoded is T ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await Future.wait([
      Hive.box<String>(_userProfileBox).clear(),
      Hive.box<String>(_weightRecordsBox).clear(),
      Hive.box<String>(_mealRecordsBox).clear(),
      Hive.box<String>(_dailyHealthBox).clear(),
      Hive.box<String>(_settingsBox).clear(),
    ]);
  }

  bool get hasData {
    final box = Hive.box<String>(_userProfileBox);
    return box.isNotEmpty;
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
    if (data == null || data.isEmpty) return const [];

    try {
      final decoded = jsonDecode(data);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map>()
          .map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
