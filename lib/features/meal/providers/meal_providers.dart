import 'dart:async';

import 'package:flutter/foundation.dart';
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
          final bytes = await file.readAsBytes();
          final contentType =
              MealImageStore.sniffContentType(bytes) ??
              MealImageStore.contentTypeOf(file.path);
          // The bucket accepts JPEG, PNG and WebP only.
          if (contentType == 'image/heic') return null;
          return service.uploadMealImage(
            recordId: meal.id,
            bytes: bytes,
            extension: MealImageStore.extensionForContentType(contentType),
            contentType: contentType,
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

/// Local-first meal log.
///
/// Every change is committed to the device first and returns right away.
/// The matching remote operation is recorded in a persisted queue and run in
/// the background, one operation at a time, so the UI never waits on the
/// network and operations for one record never overlap or reorder. Failed
/// operations stay queued and are retried by [flushPendingSync] (app resume,
/// sign-in, manual sync, the next change).
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

  Future<void> _syncChain = Future.value();
  Future<void>? _queuedDrain;
  bool _drainQueued = false;
  int _opCounter = 0;

  static List<MealRecord> _loadRecords(LocalStorageService storage) {
    final data = storage.getMealRecords();
    if (data.isNotEmpty) {
      return PersistedModelDecoder.list(data, PersistedModelDecoder.mealRecord);
    }
    return const [];
  }

  /// Completes once every remote operation queued so far has run.
  @visibleForTesting
  Future<void> get syncIdle async {
    Future<void> observed;
    do {
      observed = _syncChain;
      await observed;
    } while (!identical(observed, _syncChain));
  }

  Future<void> addMeal(MealRecord meal) => addMeals([meal]);

  /// Saves several records in one local write (e.g. every food of a photo).
  Future<void> addMeals(List<MealRecord> meals) async {
    if (meals.isEmpty) return;
    final now = _stamp();
    final stamped = [for (final meal in meals) meal.copyWith(updatedAt: now)];
    final ids = {for (final meal in stamped) meal.id};
    await _commit([...state.where((m) => !ids.contains(m.id)), ...stamped]);
    await _queuePending('upsert', ids);
    unawaited(flushPendingSync());
  }

  /// Re-inserts a record removed moments ago (snackbar undo). Its cloud photo
  /// is still there because [finalizeRemoval] only runs after the undo window.
  Future<void> restoreMeal(MealRecord meal) => addMeal(meal);

  Future<void> removeMeal(String id) async {
    if (!state.any((m) => m.id == id)) return;
    await _commit(state.where((m) => m.id != id).toList());
    await _queuePending('delete', {id});
    unawaited(flushPendingSync());
  }

  /// Runs once a removal can no longer be undone: deletes the photo from the
  /// device and from cloud storage when no remaining record uses it.
  Future<void> finalizeRemoval(MealRecord meal) async {
    if (!mounted || state.any((m) => m.id == meal.id)) return;
    await purgeOrphanImage(meal.imageUrl);
    _deleteRemoteImageIfUnused(meal.imageStoragePath);
  }

  Future<void> updateMeal(MealRecord meal) async {
    if (!state.any((m) => m.id == meal.id)) return;
    final stamped = meal.copyWith(updatedAt: _stamp());
    await _commit([
      for (final m in state)
        if (m.id == meal.id) stamped else m,
    ]);
    await _queuePending('upsert', {meal.id});
    unawaited(flushPendingSync());
  }

  Future<void> clearDay(DateTime date) async {
    final removing = state.where((m) => m.date.isSameDay(date)).toList();
    if (removing.isEmpty) return;

    await _commit(state.where((m) => !m.date.isSameDay(date)).toList());
    await _queuePending('delete', {for (final meal in removing) meal.id});
    unawaited(flushPendingSync());
    for (final meal in removing) {
      await purgeOrphanImage(meal.imageUrl);
      _deleteRemoteImageIfUnused(meal.imageStoragePath);
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

  /// Queues [meals] for upload (e.g. after a sign-in merge) and waits until
  /// the queue has been worked through once.
  Future<void> uploadRecords(Iterable<MealRecord> meals) async {
    final ids = {for (final meal in meals) meal.id};
    if (ids.isEmpty) return;
    await _queuePending('upsert', ids);
    await flushPendingSync();
  }

  /// Works through the queued remote operations in order. Concurrent calls
  /// share one pass that has not started yet; a call made while a pass is
  /// running schedules another pass, so nothing queued is missed.
  Future<void> flushPendingSync() {
    if (_remoteUpsert == null && _remoteDelete == null) return Future.value();
    final queued = _queuedDrain;
    if (_drainQueued && queued != null) return queued;
    _drainQueued = true;
    return _queuedDrain = _enqueue(() async {
      _drainQueued = false;
      for (final operation in _readPending()) {
        if (!mounted) return;
        await _runOperation(operation);
      }
    });
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

  /// Edit times are kept in UTC so a time zone or DST change on the device
  /// does not reorder them.
  DateTime _stamp() => _clock().toUtc();

  MealRecord? _byId(String id) => state.where((m) => m.id == id).firstOrNull;

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

  Future<void> _enqueue(Future<void> Function() job) {
    final next = _syncChain.then((_) => job()).catchError((Object _) {});
    _syncChain = next;
    return next;
  }

  Future<void> _runOperation(Map<String, dynamic> operation) async {
    final id = operation['id'];
    if (id is! String) return;
    final token = operation['v'];
    // A newer operation for the same record replaced this one; the pass
    // scheduled by that change handles it.
    final current = _readPending().where((o) => o['id'] == id).firstOrNull;
    if (current == null || current['v'] != token) return;

    if (operation['op'] == 'delete') {
      final remoteDelete = _remoteDelete;
      if (remoteDelete == null) return;
      try {
        await remoteDelete(id);
        await _removePending(id, token);
      } catch (_) {
        // Stays queued.
      }
      return;
    }

    final remoteUpsert = _remoteUpsert;
    if (remoteUpsert == null) return;
    final meal = _byId(id);
    if (meal == null) {
      await _removePending(id, token);
      return;
    }
    try {
      final record = await _withUploadedImage(meal);
      // Deleted while the photo was uploading: the queued delete wins.
      if (record == null) return;
      await remoteUpsert(record);
      await _removePending(id, token);
    } catch (_) {
      // Stays queued.
    }
  }

  /// Uploads the record's photo if it has not been uploaded yet and returns
  /// the *current* copy of the record with the storage path, or `null` when
  /// the record was deleted meanwhile. The photo is optional: if its upload
  /// fails, the row is still synced and the photo is retried next time.
  Future<MealRecord?> _withUploadedImage(MealRecord meal) async {
    final uploader = _imageUploader;
    if (uploader == null ||
        meal.imageStoragePath != null ||
        meal.imageUrl == null) {
      return meal;
    }

    // Foods saved from one photo share a single uploaded object.
    final shared = state
        .where((m) => m.imageUrl == meal.imageUrl && m.imageStoragePath != null)
        .firstOrNull
        ?.imageStoragePath;
    String? storagePath = shared;
    if (storagePath == null) {
      try {
        storagePath = await uploader(meal);
      } catch (_) {
        storagePath = null;
      }
    }
    if (!mounted) return null;

    final latest = _byId(meal.id);
    if (latest == null) {
      if (shared == null) _deleteRemoteImageIfUnused(storagePath);
      return null;
    }
    if (storagePath == null || latest.imageStoragePath != null) return latest;

    final updated = latest.copyWith(imageStoragePath: storagePath);
    await _commit([
      for (final m in state)
        if (m.id == updated.id) updated else m,
    ]);
    return updated;
  }

  void _deleteRemoteImageIfUnused(String? storagePath) {
    final remoteDeleteImage = _remoteDeleteImage;
    if (remoteDeleteImage == null || storagePath == null) return;
    if (state.any((m) => m.imageStoragePath == storagePath)) return;
    unawaited(
      _enqueue(() async {
        if (mounted && state.any((m) => m.imageStoragePath == storagePath)) {
          return;
        }
        try {
          await remoteDeleteImage(storagePath);
        } catch (_) {
          // Orphaned storage objects are harmless and removed on account
          // deletion.
        }
      }),
    );
  }

  List<Map<String, dynamic>> _readPending() {
    try {
      return _storage.getPendingMealSync();
    } catch (_) {
      return [];
    }
  }

  Future<void> _queuePending(String op, Set<String> ids) async {
    final pending = _readPending()
      ..removeWhere((operation) => ids.contains(operation['id']));
    final base = DateTime.now().microsecondsSinceEpoch;
    for (final id in ids) {
      pending.add({'op': op, 'id': id, 'v': '$base-${_opCounter++}'});
    }
    try {
      await _storage.savePendingMealSync(pending);
    } catch (_) {
      // Without storage the retry queue cannot persist; the next manual sync
      // still merges everything.
    }
  }

  /// Removes the queued operation for [id] if it is still the one that just
  /// ran (identified by [token]); a newer operation is kept.
  Future<void> _removePending(String id, Object? token) async {
    final pending = _readPending();
    final before = pending.length;
    pending.removeWhere(
      (operation) => operation['id'] == id && operation['v'] == token,
    );
    if (pending.length == before) return;
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
///
/// Follows [todayDateProvider] across midnight while the user is looking at
/// today, and stays put once they have moved to another day.
final selectedDateProvider = StateProvider<DateTime>((ref) {
  ref.listen<DateTime>(todayDateProvider, (previous, next) {
    if (previous != null && ref.controller.state.isSameDay(previous)) {
      ref.controller.state = next;
    }
  });
  return ref.read(todayDateProvider);
});

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
