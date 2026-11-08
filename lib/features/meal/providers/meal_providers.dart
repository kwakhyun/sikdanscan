import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show StorageException;

import '../../../core/utils/formatters.dart';
import '../../../data/models/meal_record.dart';
import '../../../data/models/persisted_model_decoder.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/meal_image_store.dart';
import '../../../data/services/supabase_backend_service.dart';
import '../../../providers/service_providers.dart';

final mealRecordsProvider =
    StateNotifierProvider<MealRecordsNotifier, List<MealRecord>>((ref) {
      final storage = ref.read(localStorageServiceProvider);

      /// The signed-in account may receive this device's data only when it
      /// owns it (or the data was never tied to an account). Otherwise the
      /// operation stays queued until the sign-in merge replaces the data.
      void requireOwnership(SupabaseBackendService service) {
        final owner = storage.getLocalDataOwner();
        if (owner != null && owner != service.currentUser?.id) {
          throw const SupabaseAuthRequiredException();
        }
      }

      return MealRecordsNotifier(
        storage,
        remoteUpsert: (meal) async {
          final service = ref.read(supabaseBackendServiceProvider);
          if (!service.isConfigured || service.currentUser == null) return;
          requireOwnership(service);
          await service.upsertMealRecord(meal);
        },
        remoteDelete: (id, deletedAt) async {
          final service = ref.read(supabaseBackendServiceProvider);
          if (!service.isConfigured) return;
          if (service.currentUser == null) {
            // A deletion of an account's meal made while signed out must
            // reach the account on the next sign-in, or the merge would
            // bring the meal back. Guest data has nothing to delete remotely.
            if (storage.getLocalDataOwner() != null) {
              throw const SupabaseAuthRequiredException();
            }
            return;
          }
          requireOwnership(service);
          await service.deleteMealRecord(id, deletedAt: deletedAt);
        },
        imageUploader: (meal) async {
          final service = ref.read(supabaseBackendServiceProvider);
          if (!service.isConfigured || service.currentUser == null) {
            return null;
          }
          requireOwnership(service);
          final file = MealImageStore.resolveFile(meal.imageUrl);
          if (file == null) return null;
          final bytes = await file.readAsBytes();
          final contentType =
              MealImageStore.sniffContentType(bytes) ??
              MealImageStore.contentTypeOf(file.path);
          // The bucket accepts JPEG, PNG and WebP only.
          if (contentType == 'image/heic') return null;
          try {
            return await service.uploadMealImage(
              recordId: meal.id,
              bytes: bytes,
              extension: MealImageStore.extensionForContentType(contentType),
              contentType: contentType,
            );
          } on StorageException catch (error) {
            // A file the bucket rejects will never upload; anything else
            // (network, server) is retried.
            if (const {'400', '413', '415'}.contains(error.statusCode)) {
              return null;
            }
            rethrow;
          }
        },
        remoteDeleteImage: (path) async {
          final service = ref.read(supabaseBackendServiceProvider);
          if (!service.isConfigured || service.currentUser == null) return;
          requireOwnership(service);
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
    Future<void> Function(String id, DateTime deletedAt)? remoteDelete,
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
  final Future<void> Function(String id, DateTime deletedAt)? _remoteDelete;
  final Future<String?> Function(MealRecord)? _imageUploader;
  final Future<void> Function(String storagePath)? _remoteDeleteImage;
  final DateTime Function() _clock;

  Future<void> _syncChain = Future.value();

  /// Removed records whose undo window is still open (see [finalizeRemoval]).
  final _awaitingFinalize = <String, MealRecord>{};

  /// When each record was deleted on this device during this session.
  final _recentLocalDeletes = <String, DateTime>{};
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
    ids.forEach(_recentLocalDeletes.remove);
    await _queuePending('upsert', ids);
    unawaited(flushPendingSync());
  }

  /// Re-inserts a record removed moments ago (snackbar undo), using the
  /// notifier's own copy of it. Its photos are still there because
  /// [finalizeRemoval] only runs after the undo window.
  Future<void> restoreMeal(MealRecord meal) {
    final kept = _awaitingFinalize.remove(meal.id);
    return addMeal(kept ?? meal);
  }

  Future<void> removeMeal(String id) async {
    final removed = _byId(id);
    if (removed == null) return;
    await _commit(state.where((m) => m.id != id).toList());
    _awaitingFinalize[id] = removed;
    _recentLocalDeletes[id] = _stamp();
    await _queuePending('delete', {id});
    unawaited(flushPendingSync());
  }

  /// Runs once a removal can no longer be undone: deletes the photo from the
  /// device and from cloud storage when no remaining record uses it, counting
  /// other removals that can still be undone as users.
  Future<void> finalizeRemoval(MealRecord meal) async {
    final removed = _awaitingFinalize.remove(meal.id);
    if (!mounted || removed == null || state.any((m) => m.id == meal.id)) {
      return;
    }
    await purgeOrphanImage(removed.imageUrl);
    _deleteRemoteImageIfUnused(removed.imageStoragePath);
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
    final at = _stamp();
    for (final meal in removing) {
      _recentLocalDeletes[meal.id] = at;
    }
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
    final stillUsed = _referenced().any((meal) => meal.imageUrl == imageUrl);
    if (!stillUsed) await MealImageStore.delete(imageUrl);
  }

  /// Records that still need their photos: current ones plus removals that
  /// can be undone.
  Iterable<MealRecord> _referenced() =>
      state.followedBy(_awaitingFinalize.values);

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

  /// Merges [remote] with local records by id, keeping the newer copy of each.
  /// Meals deleted in the account ([remoteDeleted]) are removed here unless
  /// edited locally after the deletion. With [uploadLocalOnly] (a full
  /// snapshot) records missing remotely are uploaded; for a partial snapshot
  /// of recent changes they are simply kept. Returns what must be uploaded.
  Future<MealMergeResult> mergeWithRemote(
    List<MealRecord> remote, {
    Map<String, DateTime> remoteDeleted = const {},
    bool uploadLocalOnly = true,
  }) async {
    final before = state;
    // A meal deleted here while the snapshot was being fetched may already
    // be off the queue; treat it like a queued delete unless the account
    // copy was edited after the deletion.
    final recentlyDeleted = {
      for (final meal in remote)
        if (_recentLocalDeletes[meal.id] case final deletedAt?)
          if (!(meal.updatedAt?.isAfter(deletedAt) ?? false)) meal.id,
    };
    final result = mergeRecords(
      local: before,
      remote: remote,
      pendingDeleteIds: {...pendingDeleteIds, ...recentlyDeleted},
      remoteDeleted: remoteDeleted,
      uploadLocalOnly: uploadLocalOnly,
    );
    await _commit(result.merged);
    final kept = {for (final meal in result.merged) meal.id};
    for (final meal in before) {
      if (!kept.contains(meal.id)) await purgeOrphanImage(meal.imageUrl);
    }
    return result;
  }

  static MealMergeResult mergeRecords({
    required List<MealRecord> local,
    required List<MealRecord> remote,
    Set<String> pendingDeleteIds = const {},
    Map<String, DateTime> remoteDeleted = const {},
    bool uploadLocalOnly = true,
  }) {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final localById = {for (final meal in local) meal.id: meal};
    final merged = <String, MealRecord>{};
    final toUpload = <MealRecord>[];

    for (final entry in remoteDeleted.entries) {
      final localMeal = localById[entry.key];
      if (localMeal == null) continue;
      final editedAfter = localMeal.updatedAt?.isAfter(entry.value) ?? false;
      if (editedAfter) {
        // Edited here after it was deleted elsewhere: the edit wins.
        merged[localMeal.id] = localMeal;
        toUpload.add(localMeal);
      } else {
        // Deleted in the account: drop it here as well.
        localById.remove(localMeal.id);
      }
    }

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
      if (merged.containsKey(localMeal.id) ||
          !localById.containsKey(localMeal.id)) {
        continue;
      }
      merged[localMeal.id] = localMeal;
      if (uploadLocalOnly) toUpload.add(localMeal);
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

  /// On sign-out: queued uploads are dropped (the next sign-in merge derives
  /// them again), but deletions are kept so they still reach this account.
  Future<void> dropPendingUpserts() async {
    try {
      await _storage.savePendingMealSync(
        _readPending()
            .where((operation) => operation['op'] == 'delete')
            .toList(),
      );
    } catch (_) {}
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
      final at = operation['at'];
      final deletedAt =
          (at is String ? DateTime.tryParse(at) : null) ?? _stamp();
      try {
        await remoteDelete(id, deletedAt);
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
      final (record, photoPending) = await _withUploadedImage(meal);
      // Deleted while the photo was uploading: the queued delete wins.
      if (record == null) return;
      await remoteUpsert(record);
      // The row is synced; a photo that failed for a temporary reason keeps
      // the operation queued so it is uploaded on a later pass.
      if (!photoPending) await _removePending(id, token);
    } catch (_) {
      // Stays queued.
    }
  }

  /// Uploads the record's photo if it has not been uploaded yet and returns
  /// the *current* copy of the record with the storage path (`null` when the
  /// record was deleted meanwhile), and whether the photo still has to be
  /// uploaded. The photo is optional: the row is synced either way. A photo
  /// the uploader declines (returns `null`) is not retried; one that failed
  /// with an error is.
  Future<(MealRecord?, bool)> _withUploadedImage(MealRecord meal) async {
    final uploader = _imageUploader;
    if (uploader == null ||
        meal.imageStoragePath != null ||
        meal.imageUrl == null) {
      return (meal, false);
    }

    // Foods saved from one photo share a single uploaded object.
    final shared = state
        .where((m) => m.imageUrl == meal.imageUrl && m.imageStoragePath != null)
        .firstOrNull
        ?.imageStoragePath;
    String? storagePath = shared;
    var failed = false;
    if (storagePath == null) {
      try {
        storagePath = await uploader(meal);
      } catch (_) {
        storagePath = null;
        failed = true;
      }
    }
    if (!mounted) return (null, false);

    final latest = _byId(meal.id);
    if (latest == null) {
      if (shared == null) _deleteRemoteImageIfUnused(storagePath);
      return (null, false);
    }
    if (storagePath == null || latest.imageStoragePath != null) {
      return (latest, failed);
    }

    final updated = latest.copyWith(imageStoragePath: storagePath);
    await _commit([
      for (final m in state)
        if (m.id == updated.id) updated else m,
    ]);
    return (updated, false);
  }

  void _deleteRemoteImageIfUnused(String? storagePath) {
    final remoteDeleteImage = _remoteDeleteImage;
    if (remoteDeleteImage == null || storagePath == null) return;
    bool used() => _referenced().any((m) => m.imageStoragePath == storagePath);
    if (used()) return;
    unawaited(
      _enqueue(() async {
        if (mounted && used()) return;
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
    final at = _stamp().toIso8601String();
    for (final id in ids) {
      pending.add({
        'op': op,
        'id': id,
        'v': '$base-${_opCounter++}',
        // Edit time of a deletion, so the server can tell it from later edits.
        if (op == 'delete') 'at': at,
      });
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

/// The current hour, for values that depend on the time of day (e.g. which
/// meals are expected by now). Ticks on the hour and on app resume.
final currentHourProvider =
    StateNotifierProvider<CurrentHourNotifier, DateTime>(
      (ref) => CurrentHourNotifier(),
    );

class CurrentHourNotifier extends StateNotifier<DateTime> {
  CurrentHourNotifier({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(_hourOf((clock ?? DateTime.now)())) {
    _schedule();
  }

  final DateTime Function() _clock;
  Timer? _timer;

  static DateTime _hourOf(DateTime time) =>
      DateTime(time.year, time.month, time.day, time.hour);

  void refresh() {
    final hour = _hourOf(_clock());
    if (hour != state) state = hour;
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final now = _clock();
    final next = DateTime(now.year, now.month, now.day, now.hour + 1);
    _timer = Timer(next.difference(now) + const Duration(seconds: 1), refresh);
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
