import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/meal_record.dart';
import '../../../data/models/persisted_model_decoder.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/meal_image_store.dart';
import '../../../providers/service_providers.dart';

final mealRecordsProvider =
    StateNotifierProvider<MealRecordsNotifier, List<MealRecord>>((ref) {
      final storage = ref.read(localStorageServiceProvider);
      return MealRecordsNotifier(
        storage,
        remoteUpsert: (meal) async {
          final service = ref.read(supabaseBackendServiceProvider);
          if (!service.isConfigured || service.currentUser == null) return;
          await service.upsertMealRecord(meal);
        },
        remoteDelete: (id) async {
          final service = ref.read(supabaseBackendServiceProvider);
          if (!service.isConfigured || service.currentUser == null) return;
          await service.deleteMealRecord(id);
        },
        imageUploader: (meal) async {
          final service = ref.read(supabaseBackendServiceProvider);
          if (!service.isConfigured || service.currentUser == null) {
            return null;
          }
          final file = MealImageStore.resolveFile(meal.imageUrl);
          if (file == null) return null;
          return service.uploadMealImage(
            recordId: meal.id,
            bytes: await file.readAsBytes(),
            extension: MealImageStore.extensionOf(file.path),
            contentType: MealImageStore.contentTypeOf(file.path),
          );
        },
        remoteDeleteImage: (path) async {
          final service = ref.read(supabaseBackendServiceProvider);
          if (!service.isConfigured || service.currentUser == null) return;
          await service.deleteMealImage(path);
        },
      );
    });

/// Result of merging local records with the signed-in account's records.
class MealMergeResult {
  const MealMergeResult({required this.merged, required this.toUpload});

  final List<MealRecord> merged;

  /// Local records that are missing remotely or newer than the remote copy.
  final List<MealRecord> toUpload;
}

class MealRecordsNotifier extends StateNotifier<List<MealRecord>> {
  MealRecordsNotifier(
    this._storage, {
    Future<void> Function(MealRecord)? remoteUpsert,
    Future<void> Function(String)? remoteDelete,
    Future<String?> Function(MealRecord)? imageUploader,
    Future<void> Function(String storagePath)? remoteDeleteImage,
    DateTime Function()? clock,
  }) : _remoteUpsert = remoteUpsert,
       _remoteDelete = remoteDelete,
       _imageUploader = imageUploader,
       _remoteDeleteImage = remoteDeleteImage,
       _clock = clock ?? DateTime.now,
       super(_loadRecords(_storage));

  final LocalStorageService _storage;
  final Future<void> Function(MealRecord)? _remoteUpsert;
  final Future<void> Function(String)? _remoteDelete;
  final Future<String?> Function(MealRecord)? _imageUploader;
  final Future<void> Function(String storagePath)? _remoteDeleteImage;
  final DateTime Function() _clock;

  static List<MealRecord> _loadRecords(LocalStorageService storage) {
    final data = storage.getMealRecords();
    if (data.isNotEmpty) {
      return PersistedModelDecoder.list(data, PersistedModelDecoder.mealRecord);
    }
    return const [];
  }

  Future<void> addMeal(MealRecord meal) async {
    final stamped = meal.copyWith(updatedAt: _clock());
    await _commit([...state.where((m) => m.id != meal.id), stamped]);
    await syncRecord(stamped);
  }

  /// Re-inserts a record removed moments ago (snackbar undo).
  Future<void> restoreMeal(MealRecord meal) => addMeal(meal);

  Future<void> removeMeal(String id) async {
    final removed = state.where((m) => m.id == id).toList();
    await _commit(state.where((m) => m.id != id).toList());
    await _tryRemoteDelete(id);
    for (final meal in removed) {
      await _tryRemoteDeleteImage(meal.imageStoragePath);
    }
  }

  Future<void> updateMeal(MealRecord meal) async {
    if (!state.any((m) => m.id == meal.id)) return;
    final stamped = meal.copyWith(updatedAt: _clock());
    await _commit([
      for (final m in state)
        if (m.id == meal.id) stamped else m,
    ]);
    await syncRecord(stamped);
  }

  Future<void> clearDay(DateTime date) async {
    final removing = state.where((m) => m.date.isSameDay(date)).toList();

    await _commit(state.where((m) => !m.date.isSameDay(date)).toList());

    for (final meal in removing) {
      await _tryRemoteDelete(meal.id);
      await _tryRemoteDeleteImage(meal.imageStoragePath);
    }
  }

  Future<void> replaceAll(List<MealRecord> meals) async {
    await _commit(meals);
  }

  /// Deletes the local photo once no remaining record references it.
  Future<void> purgeOrphanImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;
    final stillUsed = state.any((meal) => meal.imageUrl == imageUrl);
    if (!stillUsed) await MealImageStore.delete(imageUrl);
  }

  /// Uploads the photo (once) and upserts [meal] remotely. Failures are queued
  /// and retried by [flushPendingSync].
  Future<void> syncRecord(MealRecord meal) async {
    if (_remoteUpsert == null) return;

    try {
      var record = meal;
      final uploader = _imageUploader;
      if (uploader != null &&
          record.imageStoragePath == null &&
          record.imageUrl != null) {
        final storagePath = await uploader(record);
        if (storagePath != null) {
          record = record.copyWith(imageStoragePath: storagePath);
          if (state.any((m) => m.id == record.id)) {
            await _commit([
              for (final m in state)
                if (m.id == record.id) record else m,
            ]);
          }
        }
      }
      await _remoteUpsert(record);
      await _removePending(meal.id);
    } catch (_) {
      await _queuePending('upsert', meal.id);
    }
  }

  /// Retries remote operations that failed earlier (e.g. while offline).
  Future<void> flushPendingSync() async {
    final pending = _readPending();
    if (pending.isEmpty) return;

    for (final operation in pending) {
      final id = operation['id'] as String?;
      if (id == null) continue;
      if (operation['op'] == 'delete') {
        await _tryRemoteDelete(id);
      } else {
        final meal = state.where((m) => m.id == id).firstOrNull;
        if (meal == null) {
          await _removePending(id);
        } else {
          await syncRecord(meal);
        }
      }
    }
  }

  Set<String> get pendingDeleteIds => _readPending()
      .where((operation) => operation['op'] == 'delete')
      .map((operation) => operation['id'])
      .whereType<String>()
      .toSet();

  /// Merges [remote] with local records by id, keeping the newer copy of each
  /// and never dropping local-only records. Returns what must be uploaded.
  Future<MealMergeResult> mergeWithRemote(List<MealRecord> remote) async {
    final result = mergeRecords(
      local: state,
      remote: remote,
      pendingDeleteIds: pendingDeleteIds,
    );
    await _commit(result.merged);
    return result;
  }

  static MealMergeResult mergeRecords({
    required List<MealRecord> local,
    required List<MealRecord> remote,
    Set<String> pendingDeleteIds = const {},
  }) {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final localById = {for (final meal in local) meal.id: meal};
    final merged = <String, MealRecord>{};
    final toUpload = <MealRecord>[];

    for (final remoteMeal in remote) {
      if (pendingDeleteIds.contains(remoteMeal.id)) continue;
      final localMeal = localById[remoteMeal.id];
      if (localMeal == null) {
        merged[remoteMeal.id] = remoteMeal;
        continue;
      }
      final localTime = localMeal.updatedAt ?? epoch;
      final remoteTime = remoteMeal.updatedAt ?? epoch;
      if (localTime.isAfter(remoteTime)) {
        merged[localMeal.id] = localMeal;
        toUpload.add(localMeal);
      } else {
        merged[remoteMeal.id] = remoteMeal.copyWith(
          imageUrl: localMeal.imageUrl ?? remoteMeal.imageUrl,
          imageStoragePath:
              remoteMeal.imageStoragePath ?? localMeal.imageStoragePath,
        );
      }
    }

    for (final localMeal in local) {
      if (merged.containsKey(localMeal.id)) continue;
      merged[localMeal.id] = localMeal;
      toUpload.add(localMeal);
    }

    final records = merged.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return MealMergeResult(merged: records, toUpload: toUpload);
  }

  Future<void> clearPendingSync() async {
    try {
      await _storage.savePendingMealSync(const []);
    } catch (_) {
      // Storage unavailable (tests); nothing to clear.
    }
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

  Future<void> _tryRemoteDelete(String id) async {
    final remoteDelete = _remoteDelete;
    if (remoteDelete == null) return;

    try {
      await remoteDelete(id);
      await _removePending(id);
    } catch (_) {
      await _queuePending('delete', id);
    }
  }

  Future<void> _tryRemoteDeleteImage(String? storagePath) async {
    final remoteDeleteImage = _remoteDeleteImage;
    if (remoteDeleteImage == null || storagePath == null) return;
    try {
      await remoteDeleteImage(storagePath);
    } catch (_) {
      // Orphaned storage objects are harmless and removed on account delete.
    }
  }

  List<Map<String, dynamic>> _readPending() {
    try {
      return _storage.getPendingMealSync();
    } catch (_) {
      return [];
    }
  }

  Future<void> _queuePending(String op, String id) async {
    final pending = _readPending()
      ..removeWhere((operation) => operation['id'] == id)
      ..add({'op': op, 'id': id});
    try {
      await _storage.savePendingMealSync(pending);
    } catch (_) {
      // Without storage the retry queue cannot persist; the next manual sync
      // still merges everything.
    }
  }

  Future<void> _removePending(String id) async {
    final pending = _readPending();
    if (!pending.any((operation) => operation['id'] == id)) return;
    pending.removeWhere((operation) => operation['id'] == id);
    try {
      await _storage.savePendingMealSync(pending);
    } catch (_) {}
  }
}

/// Today's calendar date. Kept separate from the report's [selectedDateProvider]
/// so Daily always shows today, and refreshed at midnight / on app resume.
final todayDateProvider = StateNotifierProvider<TodayDateNotifier, DateTime>(
  (ref) => TodayDateNotifier(),
);

class TodayDateNotifier extends StateNotifier<DateTime> {
  TodayDateNotifier({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super((clock ?? DateTime.now)().dateOnly) {
    _scheduleMidnightRefresh();
  }

  final DateTime Function() _clock;
  Timer? _timer;

  void refresh() {
    final today = _clock().dateOnly;
    if (today != state) state = today;
    _scheduleMidnightRefresh();
  }

  void _scheduleMidnightRefresh() {
    _timer?.cancel();
    final now = _clock();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _timer = Timer(
      nextMidnight.difference(now) + const Duration(seconds: 1),
      refresh,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Anchor date of the Report tab (day / week / month navigation).
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

List<MealRecord> _mealsOn(List<MealRecord> meals, DateTime date) {
  return meals.where((m) => m.date.isSameDay(date)).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

/// Meals on the Report tab's selected day.
final selectedDateMealsProvider = Provider<List<MealRecord>>((ref) {
  return _mealsOn(
    ref.watch(mealRecordsProvider),
    ref.watch(selectedDateProvider),
  );
});

/// Meals logged today (Daily tab, strategy, AI coach context).
final todayMealsProvider = Provider<List<MealRecord>>((ref) {
  return _mealsOn(ref.watch(mealRecordsProvider), ref.watch(todayDateProvider));
});

final todayCaloriesProvider = Provider<int>((ref) {
  final meals = ref.watch(todayMealsProvider);
  return meals.fold(0, (sum, meal) => sum + meal.calories);
});

final todayMacrosProvider = Provider<Map<String, double>>((ref) {
  final meals = ref.watch(todayMealsProvider);
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

/// Distinct foods logged recently (newest first) for one-tap re-logging.
final recentFoodsProvider = Provider<List<MealRecord>>((ref) {
  final meals = [...ref.watch(mealRecordsProvider)]
    ..sort((a, b) => b.date.compareTo(a.date));
  final seen = <String>{};
  final recent = <MealRecord>[];
  for (final meal in meals) {
    final key = meal.name.trim().toLowerCase();
    if (key.isEmpty || !seen.add(key)) continue;
    recent.add(meal);
    if (recent.length >= 12) break;
  }
  return recent;
});
