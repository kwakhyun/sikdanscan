import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/daily_health.dart';
import '../../../data/models/persisted_model_decoder.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../providers/service_providers.dart';
import '../../meal/providers/meal_providers.dart';

/// Today's hydration/activity record. Re-created when the calendar day
/// changes so water intake starts from zero after midnight.
final dailyHealthProvider =
    StateNotifierProvider<DailyHealthNotifier, DailyHealth>((ref) {
      final storage = ref.read(localStorageServiceProvider);
      final today = ref.watch(todayDateProvider);
      return DailyHealthNotifier(storage, date: today);
    });

class DailyHealthNotifier extends StateNotifier<DailyHealth> {
  DailyHealthNotifier(this._storage, {DateTime? date})
    : super(_loadHealth(_storage, date ?? DateTime.now()));

  /// One glass, the step used by the water card.
  static const glassMl = 250;

  final LocalStorageService _storage;

  static DailyHealth _loadHealth(LocalStorageService storage, DateTime date) {
    final data = storage.getDailyHealthFor(date);
    return PersistedModelDecoder.dailyHealth(data) ??
        DailyHealth(
          id: 'health_${DateTime(date.year, date.month, date.day).toIso8601String()}',
          date: DateTime(date.year, date.month, date.day),
        );
  }

  Future<void> addWater(int ml) async {
    await _commit(state.copyWith(waterMl: state.waterMl + ml));
  }

  Future<void> removeWater(int ml) async {
    await _commit(
      state.copyWith(waterMl: (state.waterMl - ml).clamp(0, 10000)),
    );
  }

  Future<void> updateSteps(int steps) async {
    await _commit(state.copyWith(steps: steps));
  }

  Future<void> updateSleep(double hours) async {
    await _commit(state.copyWith(sleepHours: hours));
  }

  Future<void> updateExercise(int minutes) async {
    await _commit(state.copyWith(exerciseMinutes: minutes));
  }

  Future<void> updateMood(String mood) async {
    await _commit(state.copyWith(mood: mood));
  }

  Future<void> _commit(DailyHealth nextState) async {
    final previousState = state;
    state = nextState;

    try {
      await _storage.saveDailyHealth(nextState.toJson());
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }
}
