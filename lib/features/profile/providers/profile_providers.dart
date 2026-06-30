import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import '../../../data/models/user_profile.dart';
import '../../../data/models/weight_record.dart';
import '../../../data/models/persisted_model_decoder.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../providers/service_providers.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
      final storage = ref.read(localStorageServiceProvider);
      return UserProfileNotifier(
        storage,
        remoteSync: (profile) async {
          final service = ref.read(supabaseBackendServiceProvider);
          if (!service.isConfigured || service.currentUser == null) return;
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
    return PersistedModelDecoder.userProfile(data) ??
        UserProfile.defaultProfile();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _commit(profile);
  }

  Future<void> updateWeight(double weight) async {
    await _commit(state.copyWith(currentWeight: weight));
  }

  Future<void> _commit(UserProfile nextState) async {
    final previousState = state;
    state = nextState;

    try {
      await _storage.saveUserProfile(nextState.toJson());
      await _tryRemoteSync(nextState);
    } catch (_) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> _tryRemoteSync(UserProfile profile) async {
    final remoteSync = _remoteSync;
    if (remoteSync == null || !profile.onboardingCompleted) return;

    try {
      await remoteSync(profile);
    } catch (_) {
      // Local persistence remains the source of truth when remote sync fails.
    }
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
    await _commit([...state, record]);
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

final notificationsEnabledProvider =
    StateNotifierProvider<SettingsBoolNotifier, bool>((ref) {
      final storage = ref.read(localStorageServiceProvider);
      return SettingsBoolNotifier(storage, 'notifications_enabled', true);
    });

final darkModeProvider = StateNotifierProvider<SettingsBoolNotifier, bool>((
  ref,
) {
  final storage = ref.read(localStorageServiceProvider);
  return SettingsBoolNotifier(storage, 'dark_mode', false);
});

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

  String get languageCode {
    return switch (this) {
      AppLocalePreference.system =>
        WidgetsBinding.instance.platformDispatcher.locale.languageCode,
      AppLocalePreference.korean => 'ko',
      AppLocalePreference.english => 'en',
    };
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
