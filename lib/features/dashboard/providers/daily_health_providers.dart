import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/daily_health.dart';
import '../../../data/models/persisted_model_decoder.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../providers/service_providers.dart';

final dailyHealthProvider =
    StateNotifierProvider<DailyHealthNotifier, DailyHealth>((ref) {
      final storage = ref.read(localStorageServiceProvider);
      return DailyHealthNotifier(storage);
    });

class DailyHealthNotifier extends StateNotifier<DailyHealth> {
  DailyHealthNotifier(this._storage) : super(_loadHealth(_storage));

  final LocalStorageService _storage;

  static DailyHealth _loadHealth(LocalStorageService storage) {
    final data = storage.getTodayHealth();
    return PersistedModelDecoder.dailyHealth(data) ??
        DailyHealth(
          id: 'health_${DateTime.now().toIso8601String()}',
          date: DateTime.now(),
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
