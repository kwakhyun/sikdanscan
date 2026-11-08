import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/services/meal_image_store.dart';
import '../../../data/services/supabase_backend_service.dart';
import '../../../providers/service_providers.dart';
import '../../chat/providers/chat_providers.dart';
import '../../dashboard/providers/daily_health_providers.dart';
import '../../meal/providers/meal_capture_providers.dart';
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
        // Retry operations belong to the signed-out account.
        await meals.clearPendingSync();
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

  /// Manual "sync now": retries failed uploads, then merges both ways. The
  /// device's profile is the one being edited, so it is uploaded.
  Future<void> syncLocalToRemote() async {
    await _run(() => _syncWithAccount(preferRemoteProfile: false));
  }

  Future<void> _mergeAfterSignIn() =>
      _syncWithAccount(preferRemoteProfile: true);

  /// Brings the device and the signed-in account together.
  ///
  /// Data that was never tied to an account (or belongs to this account) is
  /// merged by record id and uploaded. Data that belongs to a *different*
  /// account is not uploaded: it is replaced by this account's data, so one
  /// person's meals never end up in someone else's account.
  Future<void> _syncWithAccount({required bool preferRemoteProfile}) async {
    final service = _service;
    final user = service.currentUser;
    if (!service.isConfigured || user == null) return;

    final storage = _ref.read(localStorageServiceProvider);
    final owner = storage.getLocalDataOwner();
    if (owner != null && owner != user.id) {
      await _replaceLocalDataWithAccount();
    } else {
      final localProfile = _ref.read(userProfileProvider);
      final remoteProfile = preferRemoteProfile
          ? await service.fetchProfile()
          : null;
      if (remoteProfile != null && remoteProfile.onboardingCompleted) {
        await _ref
            .read(userProfileProvider.notifier)
            .updateProfile(remoteProfile);
      } else if (localProfile.onboardingCompleted) {
        await service.upsertProfile(localProfile);
      }
      await _mergeMeals();
    }
    await storage.setLocalDataOwner(user.id);
  }

  /// Merges by record id so meals logged before signing in are kept and
  /// uploaded instead of being replaced by the account's records.
  Future<void> _mergeMeals() async {
    final meals = _ref.read(mealRecordsProvider.notifier);
    await meals.flushPendingSync();
    final remoteMeals = await _service.fetchMealRecords();
    final result = await meals.mergeWithRemote(remoteMeals);
    await meals.uploadRecords(result.toUpload);
  }

  Future<void> _replaceLocalDataWithAccount() async {
    final service = _service;
    final remoteProfile = await service.fetchProfile();
    final remoteMeals = await service.fetchMealRecords();

    await _ref.read(mealRecordsProvider.notifier).clearPendingSync();
    await _ref.read(localStorageServiceProvider).clearUserData();
    await MealImageStore.clearAll();
    _ref
      ..invalidate(mealCaptureProvider)
      ..invalidate(mealRecordsProvider)
      ..invalidate(weightRecordsProvider)
      ..invalidate(dailyHealthProvider)
      ..invalidate(chatMessagesProvider)
      ..invalidate(userProfileProvider);

    if (remoteMeals.isNotEmpty) {
      await _ref.read(mealRecordsProvider.notifier).replaceAll(remoteMeals);
    }
    if (remoteProfile != null && remoteProfile.onboardingCompleted) {
      await _ref
          .read(userProfileProvider.notifier)
          .updateProfile(remoteProfile);
    }
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
