import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/services/supabase_backend_service.dart';
import '../../../providers/service_providers.dart';
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
      await _syncBothWays();
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
      await _service.signOut();
      // Retry operations belong to the signed-out account.
      await _ref.read(mealRecordsProvider.notifier).clearPendingSync();
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
    await _run(_syncBothWays);
  }

  Future<void> _syncBothWays() async {
    final service = _service;
    if (!service.isConfigured || service.currentUser == null) return;

    final profile = _ref.read(userProfileProvider);
    if (profile.onboardingCompleted) {
      await service.upsertProfile(profile);
    }
    await _mergeMeals();
  }

  Future<void> _mergeAfterSignIn() async {
    final service = _service;
    if (!service.isConfigured || service.currentUser == null) return;

    final remoteProfile = await service.fetchProfile();
    final localProfile = _ref.read(userProfileProvider);
    if (remoteProfile != null && remoteProfile.onboardingCompleted) {
      await _ref
          .read(userProfileProvider.notifier)
          .updateProfile(remoteProfile);
    } else if (localProfile.onboardingCompleted) {
      await service.upsertProfile(localProfile);
    }

    await _mergeMeals();
  }

  /// Merges by record id so meals logged before signing in are kept and
  /// uploaded instead of being replaced by the account's records.
  Future<void> _mergeMeals() async {
    final meals = _ref.read(mealRecordsProvider.notifier);
    await meals.flushPendingSync();
    final remoteMeals = await _service.fetchMealRecords();
    final result = await meals.mergeWithRemote(remoteMeals);
    for (final meal in result.toUpload) {
      await meals.syncRecord(meal);
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
