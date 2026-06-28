import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/meal_record.dart';
import '../../../data/models/persisted_model_decoder.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../providers/service_providers.dart';

final mealRecordsProvider =
    StateNotifierProvider<MealRecordsNotifier, List<MealRecord>>((ref) {
      final storage = ref.read(localStorageServiceProvider);
      return MealRecordsNotifier(storage);
    });

class MealRecordsNotifier extends StateNotifier<List<MealRecord>> {
  MealRecordsNotifier(this._storage) : super(_loadRecords(_storage));

  final LocalStorageService _storage;

  static List<MealRecord> _loadRecords(LocalStorageService storage) {
    final data = storage.getMealRecords();
    if (data.isNotEmpty) {
      return PersistedModelDecoder.list(data, PersistedModelDecoder.mealRecord);
    }
    return const [];
  }

  Future<void> addMeal(MealRecord meal) async {
    await _commit([...state, meal]);
  }

  Future<void> removeMeal(String id) async {
    await _commit(state.where((m) => m.id != id).toList());
  }

  Future<void> clearDay(DateTime date) async {
    await _commit(
      state
          .where(
            (m) =>
                m.date.year != date.year ||
                m.date.month != date.month ||
                m.date.day != date.day,
          )
          .toList(),
    );
  }

  Future<void> _commit(List<MealRecord> nextState) async {
    final previousState = state;
    state = nextState;

    try {
      await _storage.saveMealRecords(nextState.map((m) => m.toJson()).toList());
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }
}

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

final selectedDateMealsProvider = Provider<List<MealRecord>>((ref) {
  final meals = ref.watch(mealRecordsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return meals
      .where(
        (m) =>
            m.date.year == selectedDate.year &&
            m.date.month == selectedDate.month &&
            m.date.day == selectedDate.day,
      )
      .toList();
});

final todayCaloriesProvider = Provider<int>((ref) {
  final meals = ref.watch(selectedDateMealsProvider);
  return meals.fold(0, (sum, meal) => sum + meal.calories);
});

final todayMacrosProvider = Provider<Map<String, double>>((ref) {
  final meals = ref.watch(selectedDateMealsProvider);
  return {
    'carbs': meals.fold(0.0, (sum, m) => sum + m.carbs),
    'protein': meals.fold(0.0, (sum, m) => sum + m.protein),
    'fat': meals.fold(0.0, (sum, m) => sum + m.fat),
  };
});

final mealsByTypeProvider = Provider.family<List<MealRecord>, MealType>((
  ref,
  type,
) {
  final meals = ref.watch(selectedDateMealsProvider);
  return meals.where((m) => m.mealType == type).toList();
});
