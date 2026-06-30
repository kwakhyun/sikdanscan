import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikdanscan/providers/app_providers.dart';
import 'package:sikdanscan/data/models/weight_record.dart';
import 'package:sikdanscan/data/models/user_profile.dart';
import 'package:sikdanscan/data/models/meal_record.dart';
import 'package:sikdanscan/data/services/local_storage_service.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    final path =
        '/tmp/hive_provider_test_${DateTime.now().millisecondsSinceEpoch}';
    Hive.init(path);
    await Hive.openBox<String>('user_profile');
    await Hive.openBox<String>('weight_records');
    await Hive.openBox<String>('meal_records');
    await Hive.openBox<String>('daily_health');
    await Hive.openBox<String>('settings');
  });

  setUp(() async {
    await _clearHiveBoxes();
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('UserProfileNotifier', () {
    test('default profile requires onboarding', () {
      final profile = container.read(userProfileProvider);
      expect(profile.onboardingCompleted, false);
      expect(profile.name, isEmpty);
      expect(profile.displayName, '식단스캔 사용자');
    });

    test('updateWeight updates currentWeight', () async {
      await container.read(userProfileProvider.notifier).updateWeight(65.0);
      final profile = container.read(userProfileProvider);
      expect(profile.currentWeight, 65.0);
    });

    test('updateProfile updates all fields', () async {
      final original = container.read(userProfileProvider);
      await container
          .read(userProfileProvider.notifier)
          .updateProfile(original.copyWith(name: '테스트 유저', age: 25));
      final updated = container.read(userProfileProvider);
      expect(updated.name, '테스트 유저');
      expect(updated.age, 25);
    });

    test(
      'falls back to default profile when persisted data is invalid',
      () async {
        await Hive.box<String>(
          'user_profile',
        ).put('profile', jsonEncode({'age': 'invalid'}));

        final profile = container.read(userProfileProvider);

        expect(profile.onboardingCompleted, false);
        expect(profile.name, isEmpty);
        expect(profile.currentWeight, 0);
      },
    );

    test(
      'rolls back optimistic profile state when persistence fails',
      () async {
        final notifier = UserProfileNotifier(_ThrowingProfileStorage());
        final previous = notifier.state;

        await expectLater(
          notifier.updateWeight(64),
          throwsA(isA<StateError>()),
        );

        expect(notifier.state, previous);
      },
    );
    test("syncs completed profile remotely after local persistence", () async {
      final syncedProfiles = <UserProfile>[];
      final notifier = UserProfileNotifier(
        LocalStorageService(),
        remoteSync: (profile) async => syncedProfiles.add(profile),
      );
      final profile = UserProfile.defaultProfile().copyWith(
        name: "원격 유저",
        age: 30,
        height: 170,
        currentWeight: 65,
        targetWeight: 60,
        onboardingCompleted: true,
      );

      await notifier.updateProfile(profile);

      expect(syncedProfiles.single.name, "원격 유저");
    });

    test("keeps local profile when remote sync fails", () async {
      final notifier = UserProfileNotifier(
        LocalStorageService(),
        remoteSync: (_) async => throw StateError("remote failed"),
      );
      final profile = UserProfile.defaultProfile().copyWith(
        name: "로컬 유지",
        age: 31,
        height: 171,
        currentWeight: 66,
        targetWeight: 61,
        onboardingCompleted: true,
      );

      await notifier.updateProfile(profile);

      expect(notifier.state.name, "로컬 유지");
    });
  });

  group('Service providers', () {
    test('Supabase is optional by default', () {
      expect(container.read(supabaseConfiguredProvider), isFalse);
    });
  });

  group('WeightRecordsNotifier', () {
    test('can add a weight record', () async {
      final initialLength = container.read(weightRecordsProvider).length;
      await container
          .read(weightRecordsProvider.notifier)
          .addRecord(
            WeightRecord(id: 'test_1', date: DateTime.now(), weight: 70.0),
          );
      expect(container.read(weightRecordsProvider).length, initialLength + 1);
    });

    test('can remove a weight record', () async {
      await container
          .read(weightRecordsProvider.notifier)
          .addRecord(
            WeightRecord(id: 'to_remove', date: DateTime.now(), weight: 71.0),
          );
      final lengthBefore = container.read(weightRecordsProvider).length;
      await container
          .read(weightRecordsProvider.notifier)
          .removeRecord('to_remove');
      expect(container.read(weightRecordsProvider).length, lengthBefore - 1);
    });

    test('drops invalid persisted weight records', () async {
      final valid = WeightRecord(
        id: 'valid_weight',
        date: DateTime(2026, 1, 1),
        weight: 70,
      ).toJson();
      await Hive.box<String>('weight_records').put(
        'records',
        jsonEncode([
          valid,
          {'id': 'bad'},
        ]),
      );

      final records = container.read(weightRecordsProvider);

      expect(records, hasLength(1));
      expect(records.single.id, 'valid_weight');
    });
  });

  group('MealRecordsNotifier', () {
    test('can add a meal', () async {
      final initialLength = container.read(mealRecordsProvider).length;
      await container
          .read(mealRecordsProvider.notifier)
          .addMeal(
            MealRecord(
              id: 'meal_test_1',
              date: DateTime.now(),
              mealType: MealType.breakfast,
              name: '테스트 식사',
              calories: 300,
              carbs: 40,
              protein: 20,
              fat: 10,
            ),
          );
      expect(container.read(mealRecordsProvider).length, initialLength + 1);
    });

    test('can remove a meal', () async {
      await container
          .read(mealRecordsProvider.notifier)
          .addMeal(
            MealRecord(
              id: 'meal_remove',
              date: DateTime.now(),
              mealType: MealType.lunch,
              name: '삭제할 식사',
              calories: 500,
              carbs: 60,
              protein: 30,
              fat: 15,
            ),
          );
      final lengthBefore = container.read(mealRecordsProvider).length;
      await container
          .read(mealRecordsProvider.notifier)
          .removeMeal('meal_remove');
      expect(container.read(mealRecordsProvider).length, lengthBefore - 1);
    });

    test('drops invalid persisted meal records', () async {
      final valid = MealRecord(
        id: 'valid_meal',
        date: DateTime(2026, 1, 1),
        mealType: MealType.breakfast,
        name: '현미밥',
        calories: 300,
        carbs: 60,
        protein: 8,
        fat: 2,
      ).toJson();
      await Hive.box<String>('meal_records').put(
        'records',
        jsonEncode([
          valid,
          {'id': 'bad_meal', 'mealType': 'unknown'},
        ]),
      );

      final records = container.read(mealRecordsProvider);

      expect(records, hasLength(1));
      expect(records.single.id, 'valid_meal');
    });

    test('rolls back optimistic meal state when persistence fails', () async {
      final notifier = MealRecordsNotifier(_ThrowingMealStorage());
      final previous = notifier.state;

      await expectLater(
        notifier.addMeal(
          MealRecord(
            id: 'will_fail',
            date: DateTime(2026, 1, 1),
            mealType: MealType.lunch,
            name: '저장 실패 식사',
            calories: 400,
            carbs: 50,
            protein: 20,
            fat: 10,
          ),
        ),
        throwsA(isA<StateError>()),
      );

      expect(notifier.state, previous);
    });
    test("syncs meal upsert and delete callbacks", () async {
      final upserts = <String>[];
      final deletes = <String>[];
      final notifier = MealRecordsNotifier(
        LocalStorageService(),
        remoteUpsert: (meal) async => upserts.add(meal.id),
        remoteDelete: (id) async => deletes.add(id),
      );
      final date = DateTime(2026, 1, 1);

      await notifier.addMeal(
        MealRecord(
          id: "remote_meal",
          date: date,
          mealType: MealType.lunch,
          name: "원격 식사",
          calories: 400,
          carbs: 45,
          protein: 25,
          fat: 12,
        ),
      );
      await notifier.removeMeal("remote_meal");
      await notifier.addMeal(
        MealRecord(
          id: "clear_meal",
          date: date,
          mealType: MealType.dinner,
          name: "삭제 식사",
          calories: 500,
          carbs: 50,
          protein: 30,
          fat: 14,
        ),
      );
      await notifier.clearDay(date);

      expect(upserts, ["remote_meal", "clear_meal"]);
      expect(deletes, ["remote_meal", "clear_meal"]);
    });

    test("keeps local meal when remote sync fails", () async {
      final notifier = MealRecordsNotifier(
        LocalStorageService(),
        remoteUpsert: (_) async => throw StateError("remote failed"),
      );

      await notifier.addMeal(
        MealRecord(
          id: "offline_meal",
          date: DateTime(2026, 1, 1),
          mealType: MealType.lunch,
          name: "오프라인 식사",
          calories: 420,
          carbs: 48,
          protein: 24,
          fat: 13,
        ),
      );

      expect(notifier.state.single.id, "offline_meal");
    });
  });

  group('DailyHealthNotifier', () {
    test('addWater increases waterMl', () async {
      final before = container.read(dailyHealthProvider).waterMl;
      await container.read(dailyHealthProvider.notifier).addWater(250);
      expect(container.read(dailyHealthProvider).waterMl, before + 250);
    });

    test('removeWater decreases waterMl', () async {
      // First add enough water
      await container.read(dailyHealthProvider.notifier).addWater(500);
      final before = container.read(dailyHealthProvider).waterMl;
      await container.read(dailyHealthProvider.notifier).removeWater(250);
      expect(container.read(dailyHealthProvider).waterMl, before - 250);
    });

    test('removeWater does not go below zero', () async {
      // Remove excessive water
      await container.read(dailyHealthProvider.notifier).removeWater(99999);
      expect(container.read(dailyHealthProvider).waterMl, 0);
    });

    test('updateSteps sets steps', () async {
      await container.read(dailyHealthProvider.notifier).updateSteps(8000);
      expect(container.read(dailyHealthProvider).steps, 8000);
    });

    test('updateSleep sets sleep hours', () async {
      await container.read(dailyHealthProvider.notifier).updateSleep(7.5);
      expect(container.read(dailyHealthProvider).sleepHours, 7.5);
    });

    test('updateExercise sets exercise minutes', () async {
      await container.read(dailyHealthProvider.notifier).updateExercise(45);
      expect(container.read(dailyHealthProvider).exerciseMinutes, 45);
    });

    test('updateMood sets mood', () async {
      await container.read(dailyHealthProvider.notifier).updateMood('happy');
      expect(container.read(dailyHealthProvider).mood, 'happy');
    });

    test(
      'falls back to an empty health record when persisted data is invalid',
      () async {
        final now = DateTime.now();
        final todayKey = DateTime(
          now.year,
          now.month,
          now.day,
        ).toIso8601String();
        await Hive.box<String>(
          'daily_health',
        ).put(todayKey, jsonEncode({'id': 'bad', 'date': 'not-a-date'}));

        final health = container.read(dailyHealthProvider);

        expect(health.id, startsWith('health_'));
        expect(health.waterMl, 0);
        expect(health.steps, 0);
      },
    );
  });

  group('SettingsBoolNotifier', () {
    test('notifications default to true', () {
      expect(container.read(notificationsEnabledProvider), true);
    });

    test('toggle changes value', () async {
      await container.read(notificationsEnabledProvider.notifier).toggle();
      expect(container.read(notificationsEnabledProvider), false);
      await container.read(notificationsEnabledProvider.notifier).toggle();
      expect(container.read(notificationsEnabledProvider), true);
    });

    test('dark mode defaults to false', () {
      expect(container.read(darkModeProvider), false);
    });

    test('setValue sets value directly', () async {
      await container.read(darkModeProvider.notifier).setValue(true);
      expect(container.read(darkModeProvider), true);
    });

    test('rolls back setting state when persistence fails', () async {
      final notifier = SettingsBoolNotifier(
        _ThrowingSettingsStorage(),
        'dark_mode',
        false,
      );

      await expectLater(notifier.setValue(true), throwsA(isA<StateError>()));

      expect(notifier.state, false);
    });
  });

  group('LanguageNotifier', () {
    test('defaults to system language preference', () {
      expect(container.read(languageProvider), AppLocalePreference.system);
      expect(container.read(languageProvider).locale, isNull);
    });

    test(
      'saves and restores korean, english, and system preferences',
      () async {
        await container
            .read(languageProvider.notifier)
            .setPreference(AppLocalePreference.english);

        expect(container.read(languageProvider), AppLocalePreference.english);
        expect(
          Hive.box<String>('settings').get('app_locale_preference'),
          '"en"',
        );

        container.dispose();
        container = ProviderContainer();
        expect(container.read(languageProvider), AppLocalePreference.english);

        await container
            .read(languageProvider.notifier)
            .setPreference(AppLocalePreference.korean);
        expect(container.read(languageProvider), AppLocalePreference.korean);
        expect(
          Hive.box<String>('settings').get('app_locale_preference'),
          '"ko"',
        );

        await container
            .read(languageProvider.notifier)
            .setPreference(AppLocalePreference.system);
        expect(container.read(languageProvider), AppLocalePreference.system);
        expect(
          Hive.box<String>('settings').get('app_locale_preference'),
          '"system"',
        );
      },
    );

    test('data reset invalidates language preference back to system', () async {
      await container
          .read(languageProvider.notifier)
          .setPreference(AppLocalePreference.english);
      expect(container.read(languageProvider), AppLocalePreference.english);

      await container.read(dataResetProvider)();

      expect(container.read(languageProvider), AppLocalePreference.system);
      expect(Hive.box<String>('settings').get('app_locale_preference'), isNull);
    });
  });

  group('Computed Providers', () {
    test('selectedDateMealsProvider filters by date', () async {
      // Set selected date to today
      container.read(selectedDateProvider.notifier).state = DateTime.now();

      // Add a meal for today
      await container
          .read(mealRecordsProvider.notifier)
          .addMeal(
            MealRecord(
              id: 'today_meal',
              date: DateTime.now(),
              mealType: MealType.breakfast,
              name: '오늘 아침',
              calories: 300,
              carbs: 40,
              protein: 20,
              fat: 10,
            ),
          );

      final todayMeals = container.read(selectedDateMealsProvider);
      expect(todayMeals.any((m) => m.id == 'today_meal'), true);

      // Set selected date to tomorrow - should not include today's meal
      container.read(selectedDateProvider.notifier).state = DateTime.now().add(
        const Duration(days: 1),
      );
      final tomorrowMeals = container.read(selectedDateMealsProvider);
      expect(tomorrowMeals.any((m) => m.id == 'today_meal'), false);
    });

    test('mealsByTypeProvider filters by type', () async {
      container.read(selectedDateProvider.notifier).state = DateTime.now();

      await container
          .read(mealRecordsProvider.notifier)
          .addMeal(
            MealRecord(
              id: 'snack_type',
              date: DateTime.now(),
              mealType: MealType.snack,
              name: '간식 테스트',
              calories: 100,
              carbs: 15,
              protein: 5,
              fat: 3,
            ),
          );

      final snacks = container.read(mealsByTypeProvider(MealType.snack));
      expect(snacks.any((m) => m.id == 'snack_type'), true);

      final dinners = container.read(mealsByTypeProvider(MealType.dinner));
      expect(dinners.any((m) => m.id == 'snack_type'), false);
    });
  });
}

Future<void> _clearHiveBoxes() {
  return Future.wait([
    Hive.box<String>('user_profile').clear(),
    Hive.box<String>('weight_records').clear(),
    Hive.box<String>('meal_records').clear(),
    Hive.box<String>('daily_health').clear(),
    Hive.box<String>('settings').clear(),
  ]);
}

class _ThrowingProfileStorage extends LocalStorageService {
  @override
  Map<String, dynamic>? getUserProfile() => null;

  @override
  Future<void> saveUserProfile(Map<String, dynamic> profile) {
    throw StateError('profile write failed');
  }
}

class _ThrowingMealStorage extends LocalStorageService {
  @override
  List<Map<String, dynamic>> getMealRecords() => const [];

  @override
  Future<void> saveMealRecords(List<Map<String, dynamic>> records) {
    throw StateError('meal write failed');
  }
}

class _ThrowingSettingsStorage extends LocalStorageService {
  @override
  T? getSetting<T>(String key) => null;

  @override
  Future<void> saveSetting(String key, dynamic value) {
    throw StateError('setting write failed');
  }
}
