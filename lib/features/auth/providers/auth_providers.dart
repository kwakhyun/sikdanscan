import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/services/meal_image_store.dart';
import '../../../data/services/supabase_backend_service.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/user_session.dart';
import '../../meal/providers/meal_providers.dart';
import '../../profile/providers/profile_providers.dart';

enum SocialLoginProvider { google, kakao, apple }

extension SocialLoginProviderX on SocialLoginProvider {
  OAuthProvider get oauthProvider {
    return switch (this) {
      SocialLoginProvider.google => OAuthProvider.google,
      SocialLoginProvider.kakao => OAuthProvider.kakao,
      SocialLoginProvider.apple => OAuthProvider.apple,
    };
  }
}

final supabaseUserProvider = StreamProvider<User?>((ref) async* {
  final service = ref.watch(supabaseBackendServiceProvider);
  if (!service.isConfigured) {
    yield null;
    return;
  }

  yield service.currentUser;
  await for (final state in service.authStateChanges) {
    yield state.session?.user;
  }
});

final supabaseAuthControllerProvider =
    StateNotifierProvider<SupabaseAuthController, AsyncValue<void>>((ref) {
      return SupabaseAuthController(ref);
    });

class SupabaseAuthController extends StateNotifier<AsyncValue<void>> {
  SupabaseAuthController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _run(() async {
      await _service.signUpWithPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      await _mergeAfterSignIn();
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await _run(() async {
      await _service.signInWithPassword(email: email, password: password);
      await _mergeAfterSignIn();
    });
  }

  Future<bool> signInWithOAuth(SocialLoginProvider provider) async {
    var launched = false;
    await _run(() async {
      launched = await _service.signInWithOAuthProvider(provider.oauthProvider);
    });
    return launched;
  }

  Future<void> mergeAfterSignIn() async {
    await _run(_mergeAfterSignIn);
  }

  Future<void> signOut() async {
    await _run(() async {
      final meals = _ref.read(mealRecordsProvider.notifier);
      // Give queued changes a short chance to reach the account first.
      await meals.flushPendingSync().timeout(
        const Duration(seconds: 5),
        onTimeout: () {},
      );
      try {
        await _service.signOut();
      } catch (_) {
        // Offline sign-out still ends the local session; only report a
        // failure while the user is actually still signed in.
        if (_service.currentUser != null) rethrow;
      } finally {
        // Queued uploads are derived again by the next sign-in merge; queued
        // deletions are kept so the account still receives them (another
        // account signing in clears them with the rest of the data).
        await meals.dropPendingUpserts();
      }
    });
  }

  /// Deletes the account and all cloud data. Local data is reset by the
  /// caller afterwards.
  Future<void> deleteAccount() async {
    await _run(() async {
      await _service.deleteAccount();
      await _ref.read(mealRecordsProvider.notifier).clearPendingSync();
    });
  }

  /// Manual "sync now": retries failed uploads, then merges both ways.
  Future<void> syncLocalToRemote() async {
    await _run(_mergeAfterSignIn);
  }

  /// Quietly brings in what changed in the account since the last pull
  /// (other devices' meals, deletions and profile edits). Runs on app start
  /// and resume, at most every few minutes, and never switches accounts.
  Future<void> pullAccountChanges({bool force = false}) async {
    final service = _service;
    final user = service.isConfigured ? service.currentUser : null;
    if (user == null || _pulling) return;
    final storage = _ref.read(localStorageServiceProvider);
    final now = DateTime.now();
    final last = _lastPull;
    if (!force && last != null && now.difference(last) < pullInterval) return;
    if (storage.getLocalDataOwner() != user.id) {
      _lastPull = now;
      // The sign-in merge did not finish (e.g. offline, or the app was
      // closed during an OAuth sign-in): finish it now. Uploads stay blocked
      // until then.
      if (_pulling) return;
      _pulling = true;
      try {
        await _mergeAfterSignIn();
      } catch (_) {
      } finally {
        _pulling = false;
      }
      return;
    }

    _pulling = true;
    _lastPull = now;
    try {
      await _reconcileProfile(preferRemote: false);
      final meals = _ref.read(mealRecordsProvider.notifier);
      await meals.flushPendingSync();
      final cursor = storage.getMealPullCursor();
      // A little overlap covers writes committed out of order.
      final snapshot = await service.fetchMealSnapshot(
        changedSince: cursor?.subtract(const Duration(minutes: 2)),
      );
      final result = await meals.mergeWithRemote(
        snapshot.records,
        remoteDeleted: snapshot.deleted,
        uploadLocalOnly: cursor == null,
      );
      await meals.uploadRecords(result.toUpload);
      await _saveCursor(snapshot.cursor);
    } catch (_) {
      // Offline or not migrated yet: the next resume tries again.
    } finally {
      _pulling = false;
    }
  }

  static const pullInterval = Duration(minutes: 3);
  bool _pulling = false;
  DateTime? _lastPull;

  Future<void> _mergeAfterSignIn() async {
    final service = _service;
    final user = service.currentUser;
    if (!service.isConfigured || user == null) return;

    final storage = _ref.read(localStorageServiceProvider);
    final owner = storage.getLocalDataOwner();
    if (owner != null && owner != user.id) {
      await _replaceLocalDataWithAccount();
    } else {
      // Data that was never tied to an account adopts the account's profile
      // when it has one; this account's own data is reconciled newer-wins.
      await _reconcileProfile(preferRemote: owner == null);
      await _mergeMeals();
    }
    await storage.setLocalDataOwner(user.id);
    _lastPull = DateTime.now();
  }

  /// Newer-wins between the device profile and the account profile, using
  /// this device's last edit time and the server time of the account copy.
  Future<void> _reconcileProfile({required bool preferRemote}) async {
    final service = _service;
    final storage = _ref.read(localStorageServiceProvider);
    final notifier = _ref.read(userProfileProvider.notifier);
    final remote = await service.fetchProfileSnapshot();
    // Read the device copy after the fetch so an edit made meanwhile counts.
    final local = _ref.read(userProfileProvider);
    final localEditedAt = storage.getProfileEditedAt();
    final remoteProfile = remote?.profile;
    final remoteTime = remote?.updatedAt;

    if (remoteProfile != null && remoteProfile == local) {
      // The account already has this device's copy (e.g. our own upload
      // echoed back with a later server time); nothing to do.
      if (storage.profileSyncPending) {
        await storage.setProfileSyncPending(false);
      }
      return;
    }

    final remoteUsable =
        remoteProfile != null && remoteProfile.onboardingCompleted;
    final remoteIsNewer =
        remoteUsable &&
        (preferRemote ||
            !local.onboardingCompleted ||
            localEditedAt == null ||
            (remoteTime != null && remoteTime.isAfter(localEditedAt)));

    if (remoteIsNewer) {
      await notifier.applyRemote(remoteProfile, remoteTime);
    } else if (local.onboardingCompleted &&
        (remote == null ||
            storage.profileSyncPending ||
            remoteTime == null ||
            localEditedAt == null ||
            localEditedAt.isAfter(remoteTime))) {
      await service.upsertProfile(local);
      await storage.setProfileSyncPending(false);
    }
  }

  /// Merges by record id so meals logged before signing in are kept and
  /// uploaded instead of being replaced by the account's records, and meals
  /// deleted in the account are not brought back.
  Future<void> _mergeMeals() async {
    final meals = _ref.read(mealRecordsProvider.notifier);
    await meals.flushPendingSync();
    final snapshot = await _service.fetchMealSnapshot();
    final result = await meals.mergeWithRemote(
      snapshot.records,
      remoteDeleted: snapshot.deleted,
    );
    await meals.uploadRecords(result.toUpload);
    await _saveCursor(snapshot.cursor);
  }

  Future<void> _saveCursor(DateTime? cursor) async {
    if (cursor == null) return;
    final storage = _ref.read(localStorageServiceProvider);
    final previous = storage.getMealPullCursor();
    if (previous == null || cursor.isAfter(previous)) {
      await storage.setMealPullCursor(cursor);
    }
  }

  Future<void> _replaceLocalDataWithAccount() async {
    final service = _service;
    final remote = await service.fetchProfileSnapshot();
    final snapshot = await service.fetchMealSnapshot();

    await _ref.read(mealRecordsProvider.notifier).clearPendingSync();
    final storage = _ref.read(localStorageServiceProvider);
    await storage.clearUserData();
    await MealImageStore.clearAll();

    // Store the account's data first and only then re-create the providers,
    // so nothing (e.g. the router's onboarding check) sees an empty profile
    // in between.
    await storage.saveMealRecords([
      for (final meal in snapshot.records) meal.toJson(),
    ]);
    final remoteProfile = remote?.profile;
    if (remoteProfile != null && remoteProfile.onboardingCompleted) {
      await storage.saveUserProfile(remoteProfile.toJson());
      await storage.setProfileEditedAt(remote?.updatedAt);
    }
    final user = service.currentUser;
    if (user != null) await storage.setLocalDataOwner(user.id);
    await _saveCursor(snapshot.cursor);
    invalidateUserScopedState(_ref);
  }

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  SupabaseBackendService get _service =>
      _ref.read(supabaseBackendServiceProvider);
}
