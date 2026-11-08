import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../../data/models/user_profile.dart';
import '../../../data/models/weight_record.dart';
import '../../../data/models/persisted_model_decoder.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/supabase_backend_service.dart';
import '../../../providers/service_providers.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
      final storage = ref.read(localStorageServiceProvider);
      return UserProfileNotifier(
        storage,
        remoteSync: (profile) async {
          final service = ref.read(supabaseBackendServiceProvider);
          if (!service.isConfigured || service.currentUser == null) return;
          // Never send this device's profile to an account that does not own
          // the data (the sign-in merge has not finished); it stays pending.
          final owner = storage.getLocalDataOwner();
          if (owner != null && owner != service.currentUser!.id) {
            throw const SupabaseAuthRequiredException();
          }
          await service.upsertProfile(profile);
        },
      );
    });

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier(
    this._storage, {
    Future<void> Function(UserProfile)? remoteSync,
  }) : _remoteSync = remoteSync,
       super(_loadProfile(_storage));

  final LocalStorageService _storage;
  final Future<void> Function(UserProfile)? _remoteSync;

  static UserProfile _loadProfile(LocalStorageService storage) {
    final data = storage.getUserProfile();
    final profile =
        PersistedModelDecoder.userProfile(data) ?? UserProfile.defaultProfile();
    // Dates from earlier account syncs could be stored in UTC, which shifts
    // a chosen goal date by a day in time zones ahead of UTC.
    return profile.copyWith(
      targetDate: profile.targetDate?.toLocal(),
      onboardedAt: profile.onboardedAt?.toLocal(),
    );
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _commit(profile);
  }

  Future<void> updateWeight(double weight) async {
    await _commit(state.copyWith(currentWeight: weight));
  }

  /// Takes the account's copy without sending it back, remembering the
  /// server time as this device's edit time.
  Future<void> applyRemote(
    UserProfile profile,
    DateTime? remoteUpdatedAt,
  ) async {
    await _commit(profile, editedAt: remoteUpdatedAt, sync: false);
    _setSyncPending(false);
  }

  /// Saves locally first and uploads in the background; a failed upload is
  /// retried later and reconciled newer-wins with the account.
  Future<void> _commit(
    UserProfile nextState, {
    DateTime? editedAt,
    bool sync = true,
  }) async {
    final previousState = state;
    state = nextState;

    try {
      await _storage.saveUserProfile(nextState.toJson());
    } catch (_) {
      state = previousState;
      rethrow;
    }
    try {
      await _storage.setProfileEditedAt(editedAt ?? DateTime.now().toUtc());
    } catch (_) {
      // Only the newer-wins comparison is affected.
    }
    if (sync) unawaited(_tryRemoteSync(nextState));
  }

  Future<void> _tryRemoteSync(UserProfile profile) async {
    final remoteSync = _remoteSync;
    if (remoteSync == null || !profile.onboardingCompleted) return;

    try {
      await remoteSync(profile);
      _setSyncPending(false);
    } catch (_) {
      // Local persistence remains the source of truth when remote sync fails.
      _setSyncPending(true);
    }
  }

  void _setSyncPending(bool value) {
    try {
      unawaited(
        _storage.setProfileSyncPending(value).catchError((Object _) {}),
      );
    } catch (_) {}
  }
}

final weightRecordsProvider =
    StateNotifierProvider<WeightRecordsNotifier, List<WeightRecord>>((ref) {
      final storage = ref.read(localStorageServiceProvider);
      return WeightRecordsNotifier(storage);
    });

class WeightRecordsNotifier extends StateNotifier<List<WeightRecord>> {
  WeightRecordsNotifier(this._storage) : super(_loadRecords(_storage));

  final LocalStorageService _storage;

  static List<WeightRecord> _loadRecords(LocalStorageService storage) {
    final data = storage.getWeightRecords();
    if (data.isNotEmpty) {
      return PersistedModelDecoder.list(
        data,
        PersistedModelDecoder.weightRecord,
      );
    }
    return const [];
  }

  Future<void> addRecord(WeightRecord record) async {
    final next = [...state.where((r) => r.id != record.id), record]
      ..sort((a, b) => a.date.compareTo(b.date));
    await _commit(next);
  }

  Future<void> removeRecord(String id) async {
    await _commit(state.where((r) => r.id != id).toList());
  }

  Future<void> _commit(List<WeightRecord> nextState) async {
    final previousState = state;
    state = nextState;

    try {
      await _storage.saveWeightRecords(
        nextState.map((r) => r.toJson()).toList(),
      );
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }
}

/// Light / dark / follow-the-system appearance.
enum ThemePreference {
  system('system'),
  light('light'),
  dark('dark');

  const ThemePreference(this.storageValue);

  final String storageValue;

  ThemeMode get themeMode => switch (this) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };
}

/// Whether the user agreed that meal, body and chat data may be sent to the
/// AI provider. Every AI request (coach, photo analysis, AI food search)
/// checks it; without it the app uses its offline features only.
final aiDataConsentProvider = StateNotifierProvider<SettingsBoolNotifier, bool>(
  (ref) => SettingsBoolNotifier(
    ref.read(localStorageServiceProvider),
    LocalStorageService.aiDataConsentKey,
    false,
  ),
);

final themePreferenceProvider =
    StateNotifierProvider<ThemePreferenceNotifier, ThemePreference>((ref) {
      final storage = ref.read(localStorageServiceProvider);
      return ThemePreferenceNotifier(storage);
    });

class ThemePreferenceNotifier extends StateNotifier<ThemePreference> {
  ThemePreferenceNotifier(this._storage) : super(_load(_storage));

  static const storageKey = 'theme_preference';
  static const legacyDarkModeKey = 'dark_mode';

  final LocalStorageService _storage;

  static ThemePreference _load(LocalStorageService storage) {
    final stored = storage.getSetting<String>(storageKey);
    for (final preference in ThemePreference.values) {
      if (preference.storageValue == stored) return preference;
    }
    // Earlier versions stored an explicit on/off switch.
    final legacy = storage.getSetting<bool>(legacyDarkModeKey);
    if (legacy == true) return ThemePreference.dark;
    if (legacy == false) return ThemePreference.light;
    return ThemePreference.system;
  }

  Future<void> setPreference(ThemePreference preference) async {
    final previousState = state;
    state = preference;
    try {
      await _storage.saveSetting(storageKey, preference.storageValue);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLocalePreference>((ref) {
      final storage = ref.read(localStorageServiceProvider);
      return LanguageNotifier(storage);
    });

enum AppLocalePreference {
  system('system'),
  korean('ko'),
  english('en');

  const AppLocalePreference(this.storageValue);

  final String storageValue;

  Locale? get locale {
    return switch (this) {
      AppLocalePreference.system => null,
      AppLocalePreference.korean => const Locale('ko'),
      AppLocalePreference.english => const Locale('en'),
    };
  }

  /// Language actually shown in the UI. For [system] this follows the same
  /// resolution as `MaterialApp`: the first preferred device language the app
  /// supports, otherwise English.
  String get languageCode {
    return switch (this) {
      AppLocalePreference.system => resolveSupportedLanguageCode(
        _platformLocales(),
      ),
      AppLocalePreference.korean => 'ko',
      AppLocalePreference.english => 'en',
    };
  }

  static const supportedLanguageCodes = ['ko', 'en'];
  static const fallbackLanguageCode = 'en';

  static String resolveSupportedLanguageCode(Iterable<Locale> preferred) {
    for (final locale in preferred) {
      if (supportedLanguageCodes.contains(locale.languageCode)) {
        return locale.languageCode;
      }
    }
    return fallbackLanguageCode;
  }

  static List<Locale> _platformLocales() {
    try {
      return WidgetsBinding.instance.platformDispatcher.locales;
    } catch (_) {
      return const [];
    }
  }

  static AppLocalePreference fromStorage(String? value) {
    return AppLocalePreference.values.firstWhere(
      (preference) => preference.storageValue == value,
      orElse: () => AppLocalePreference.system,
    );
  }
}

class LanguageNotifier extends StateNotifier<AppLocalePreference> {
  LanguageNotifier(this._storage)
    : super(
        AppLocalePreference.fromStorage(
          _storage.getSetting<String>('app_locale_preference'),
        ),
      );

  final LocalStorageService _storage;

  Future<void> setPreference(AppLocalePreference preference) async {
    final previousState = state;
    state = preference;

    try {
      await _storage.saveSetting(
        'app_locale_preference',
        preference.storageValue,
      );
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }
}

class SettingsBoolNotifier extends StateNotifier<bool> {
  SettingsBoolNotifier(this._storage, this._key, bool defaultValue)
    : super(_storage.getSetting<bool>(_key) ?? defaultValue);

  final LocalStorageService _storage;
  final String _key;

  Future<void> toggle() async {
    await setValue(!state);
  }

  Future<void> setValue(bool value) async {
    final previousState = state;
    state = value;

    try {
      await _storage.saveSetting(_key, value);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }
}

/// Language code the UI is rendered in (`ko` or `en`). Providers that build
/// user-facing text or call the AI server use this so content never mixes
/// languages with the UI.
final resolvedLanguageCodeProvider = Provider<String>((ref) {
  return ref.watch(languageProvider).languageCode;
});

/// Latest logged body weight, falling back to the profile value.
final currentWeightProvider = Provider<double>((ref) {
  final records = ref.watch(weightRecordsProvider);
  if (records.isNotEmpty) return records.last.weight;
  return ref.watch(userProfileProvider).currentWeight;
});
