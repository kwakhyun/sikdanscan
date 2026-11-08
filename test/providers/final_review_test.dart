import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sikdanscan/data/models/meal_record.dart';
import 'package:sikdanscan/data/models/user_profile.dart';
import 'package:sikdanscan/data/services/ai_chat_service.dart';
import 'package:sikdanscan/data/services/food_api_service.dart';
import 'package:sikdanscan/data/services/food_image_recognition_service.dart';
import 'package:sikdanscan/data/services/image_metadata.dart';
import 'package:sikdanscan/data/services/local_storage_service.dart';
import 'package:sikdanscan/data/services/meal_image_store.dart';
import 'package:sikdanscan/data/services/proxy_client_config.dart';
import 'package:sikdanscan/data/services/supabase_backend_service.dart';
import 'package:sikdanscan/data/services/supabase_config.dart';
import 'package:sikdanscan/features/meal/report_models.dart';
import 'package:sikdanscan/providers/app_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

MealRecord _meal(
  String id, {
  DateTime? date,
  String? imageUrl,
  String? imageStoragePath,
  MealType type = MealType.lunch,
}) {
  return MealRecord(
    id: id,
    date: date ?? DateTime(2026, 5, 1, 12),
    mealType: type,
    name: 'meal $id',
    calories: 500,
    carbs: 50,
    protein: 20,
    fat: 10,
    imageUrl: imageUrl,
    imageStoragePath: imageStoragePath,
  );
}

/// Records every remote call; uploads can be held open to simulate a slow
/// network.
class _Remote {
  final log = <String>[];
  final upserted = <MealRecord>[];
  Completer<void>? uploadGate;
  bool failUpload = false;

  late final notifierArgs = (
    remoteUpsert: (MealRecord meal) async {
      log.add('upsert ${meal.id}');
      upserted.add(meal);
    },
    remoteDelete: (String id, DateTime _) async => log.add('delete $id'),
    imageUploader: (MealRecord meal) async {
      log.add('upload ${meal.id}');
      final gate = uploadGate;
      if (gate != null) await gate.future;
      if (failUpload) throw StateError('bucket rejected the file');
      return 'uid/${meal.id}.jpg';
    },
    remoteDeleteImage: (String path) async => log.add('deleteImage $path'),
  );

  MealRecordsNotifier notifier() => MealRecordsNotifier(
    LocalStorageService(),
    remoteUpsert: notifierArgs.remoteUpsert,
    remoteDelete: notifierArgs.remoteDelete,
    imageUploader: notifierArgs.imageUploader,
    remoteDeleteImage: notifierArgs.remoteDeleteImage,
  );
}

User _user(String id) => User(
  id: id,
  appMetadata: const {},
  userMetadata: const {},
  aud: 'authenticated',
  createdAt: '2026-01-01T00:00:00Z',
);

class _FakeBackend extends SupabaseBackendService {
  _FakeBackend({
    required this.user,
    this.remoteMeals = const [],
    this.remoteDeleted = const {},
    this.remoteProfile,
  }) : super(config: SupabaseConfig());

  final User? user;
  final List<MealRecord> remoteMeals;
  final Map<String, DateTime> remoteDeleted;
  final RemoteProfile? remoteProfile;
  final upserts = <String>[];
  final deletes = <String>[];
  final profileUpserts = <UserProfile>[];

  @override
  bool get isConfigured => true;

  @override
  User? get currentUser => user;

  @override
  Future<RemoteProfile?> fetchProfileSnapshot() async => remoteProfile;

  @override
  Future<void> upsertProfile(UserProfile profile) async =>
      profileUpserts.add(profile);

  @override
  Future<RemoteMealSnapshot> fetchMealSnapshot({
    DateTime? from,
    DateTime? to,
    DateTime? changedSince,
  }) async => RemoteMealSnapshot(records: remoteMeals, deleted: remoteDeleted);

  @override
  Future<void> upsertMealRecord(MealRecord record) async =>
      upserts.add(record.id);

  @override
  Future<void> deleteMealRecord(String id, {DateTime? deletedAt}) async =>
      deletes.add(id);

  @override
  Future<String> uploadMealImage({
    required String recordId,
    required Uint8List bytes,
    String extension = 'jpg',
    String contentType = 'image/jpeg',
  }) async => 'uid/$recordId.$extension';
}

class _SlowChatService extends AiChatService {
  final pending = Completer<AiChatReply>();

  @override
  bool get isConfigured => true;

  @override
  Future<AiChatReply> reply({
    required String userMessage,
    List<AiChatTurn> history = const [],
    Map<String, dynamic>? context,
    String locale = 'ko',
  }) => pending.future;
}

/// The user agreed to AI data use (required before any AI request).
final _consented = [
  aiDataConsentProvider.overrideWith(
    (ref) =>
        SettingsBoolNotifier(LocalStorageService(), 'ai_data_consent', true),
  ),
];

void main() {
  const boxes = [
    'user_profile',
    'weight_records',
    'meal_records',
    'daily_health',
    'settings',
  ];

  setUpAll(() async {
    Hive.init(
      '/tmp/hive_final_review_${DateTime.now().microsecondsSinceEpoch}',
    );
    for (final name in boxes) {
      await Hive.openBox<String>(name);
    }
  });

  setUp(() async {
    for (final name in boxes) {
      await Hive.box<String>(name).clear();
    }
  });

  tearDownAll(() async => Hive.close());

  group('Background meal sync', () {
    test('saving returns before the network finishes', () async {
      final remote = _Remote()..uploadGate = Completer<void>();
      final notifier = remote.notifier();

      await notifier.addMeal(_meal('a', imageUrl: 'meal_images/a.jpg'));
      // Local state is committed; the upload is still waiting.
      expect(notifier.state.single.id, 'a');
      expect(remote.upserted, isEmpty);

      remote.uploadGate!.complete();
      await notifier.syncIdle;
      expect(remote.log, ['upload a', 'upsert a']);
      expect(notifier.state.single.imageStoragePath, 'uid/a.jpg');
      expect(LocalStorageService().getPendingMealSync(), isEmpty);
    });

    test(
      'a record deleted during its photo upload is not resurrected',
      () async {
        final remote = _Remote()..uploadGate = Completer<void>();
        final notifier = remote.notifier();

        await notifier.addMeal(_meal('b', imageUrl: 'meal_images/b.jpg'));
        await Future<void>.delayed(Duration.zero);
        await notifier.removeMeal('b');
        remote.uploadGate!.complete();
        await notifier.syncIdle;

        expect(remote.log, isNot(contains('upsert b')));
        expect(remote.log, containsAll(['delete b', 'deleteImage uid/b.jpg']));
        expect(notifier.state, isEmpty);
      },
    );

    test('an edit made during the upload is what gets uploaded', () async {
      final remote = _Remote()..uploadGate = Completer<void>();
      final notifier = remote.notifier();

      await notifier.addMeal(_meal('c', imageUrl: 'meal_images/c.jpg'));
      await Future<void>.delayed(Duration.zero);
      await notifier.updateMeal(notifier.state.single.copyWith(name: 'edited'));
      remote.uploadGate!.complete();
      await notifier.syncIdle;

      expect(notifier.state.single.name, 'edited');
      expect(notifier.state.single.imageStoragePath, 'uid/c.jpg');
      expect(remote.upserted.last.name, 'edited');
      expect(remote.upserted.last.imageStoragePath, 'uid/c.jpg');
    });

    test('foods saved from one photo share a single upload', () async {
      final remote = _Remote();
      final notifier = remote.notifier();

      await notifier.addMeals([
        _meal('d1', imageUrl: 'meal_images/shared.jpg'),
        _meal('d2', imageUrl: 'meal_images/shared.jpg'),
        _meal('d3', imageUrl: 'meal_images/shared.jpg'),
      ]);
      await notifier.syncIdle;

      expect(remote.log.where((e) => e.startsWith('upload')), ['upload d1']);
      expect(notifier.state.map((m) => m.imageStoragePath).toSet(), {
        'uid/d1.jpg',
      });
      expect(remote.upserted.map((m) => m.id), ['d1', 'd2', 'd3']);
    });

    test('a rejected photo does not keep the row from syncing', () async {
      final remote = _Remote()..failUpload = true;
      final notifier = remote.notifier();

      await notifier.addMeal(_meal('e', imageUrl: 'meal_images/e.heic'));
      await notifier.syncIdle;

      expect(remote.upserted.single.id, 'e');
      expect(remote.upserted.single.imageStoragePath, isNull);
      expect(LocalStorageService().getPendingMealSync(), isEmpty);
    });

    test('undoing a delete keeps the cloud photo', () async {
      final remote = _Remote();
      final notifier = remote.notifier();
      final meal = _meal('f', imageUrl: 'meal_images/f.jpg');

      await notifier.addMeal(meal);
      await notifier.syncIdle;
      final synced = notifier.state.single;

      await notifier.removeMeal('f');
      await notifier.restoreMeal(synced);
      await notifier.finalizeRemoval(synced); // snackbar closed after undo
      await notifier.syncIdle;

      expect(remote.log, isNot(contains('deleteImage uid/f.jpg')));
      expect(remote.upserted.last.imageStoragePath, 'uid/f.jpg');
    });

    test('the cloud photo is deleted once the undo window closes', () async {
      final remote = _Remote();
      final notifier = remote.notifier();

      await notifier.addMeals([
        _meal('g1', imageUrl: 'meal_images/g.jpg'),
        _meal('g2', imageUrl: 'meal_images/g.jpg'),
      ]);
      await notifier.syncIdle;

      final first = notifier.state.firstWhere((m) => m.id == 'g1');
      await notifier.removeMeal('g1');
      await notifier.finalizeRemoval(first);
      await notifier.syncIdle;
      // Still used by g2.
      expect(remote.log, isNot(contains('deleteImage uid/g1.jpg')));

      final second = notifier.state.single;
      await notifier.removeMeal('g2');
      await notifier.finalizeRemoval(second);
      await notifier.syncIdle;
      expect(remote.log, contains('deleteImage uid/g1.jpg'));
    });
  });

  group('Signing in on a device with data', () {
    test('guest data is moved into the first account', () async {
      final backend = _FakeBackend(user: _user('user-a'));
      final container = ProviderContainer(
        overrides: [supabaseBackendServiceProvider.overrideWithValue(backend)],
      );
      addTearDown(container.dispose);

      await container.read(mealRecordsProvider.notifier).addMeal(_meal('g'));
      await container.read(mealRecordsProvider.notifier).syncIdle;
      backend.upserts.clear();

      await container
          .read(supabaseAuthControllerProvider.notifier)
          .mergeAfterSignIn();

      expect(backend.upserts, contains('g'));
      expect(LocalStorageService().getLocalDataOwner(), 'user-a');
    });

    test('another account\'s data is replaced, never uploaded', () async {
      await LocalStorageService().setLocalDataOwner('user-a');
      final backend = _FakeBackend(
        user: _user('user-b'),
        remoteMeals: [_meal('b-remote')],
      );
      final container = ProviderContainer(
        overrides: [supabaseBackendServiceProvider.overrideWithValue(backend)],
      );
      addTearDown(container.dispose);
      // A's meal on the device (written while A was the owner).
      await LocalStorageService().saveMealRecords([_meal('a-local').toJson()]);
      await LocalStorageService().savePendingMealSync([
        {'op': 'upsert', 'id': 'a-local'},
      ]);

      await container
          .read(supabaseAuthControllerProvider.notifier)
          .mergeAfterSignIn();

      expect(backend.upserts, isNot(contains('a-local')));
      expect(container.read(mealRecordsProvider).map((m) => m.id), [
        'b-remote',
      ]);
      expect(LocalStorageService().getPendingMealSync(), isEmpty);
      expect(LocalStorageService().getLocalDataOwner(), 'user-b');
    });
  });

  group('Deletions across devices', () {
    test('a meal deleted in the account is removed, not re-uploaded', () async {
      await LocalStorageService().setLocalDataOwner('user-a');
      final deletedAt = DateTime.utc(2026, 5, 2);
      final backend = _FakeBackend(
        user: _user('user-a'),
        remoteDeleted: {'gone': deletedAt},
      );
      final container = ProviderContainer(
        overrides: [supabaseBackendServiceProvider.overrideWithValue(backend)],
      );
      addTearDown(container.dispose);
      await LocalStorageService().saveMealRecords([
        _meal('gone').copyWith(updatedAt: DateTime.utc(2026, 5, 1)).toJson(),
        _meal(
          'edited-later',
        ).copyWith(updatedAt: DateTime.utc(2026, 5, 3)).toJson(),
      ]);

      await container
          .read(supabaseAuthControllerProvider.notifier)
          .mergeAfterSignIn();

      final ids = container.read(mealRecordsProvider).map((m) => m.id);
      expect(ids, ['edited-later']);
      expect(backend.upserts, isNot(contains('gone')));
    });

    test('an edit made after the deletion elsewhere wins', () {
      final result = MealRecordsNotifier.mergeRecords(
        local: [
          _meal('kept').copyWith(updatedAt: DateTime.utc(2026, 5, 3)),
          _meal('local-only'),
        ],
        remote: const [],
        remoteDeleted: {'kept': DateTime.utc(2026, 5, 2)},
        uploadLocalOnly: false,
      );
      expect(
        result.merged.map((m) => m.id),
        containsAll(['kept', 'local-only']),
      );
      // A partial (changes-only) pull does not upload untouched local rows.
      expect(result.toUpload.map((m) => m.id), ['kept']);
    });

    test('a delete made while signed out waits for the account', () async {
      await LocalStorageService().setLocalDataOwner('user-a');
      final backend = _FakeBackend(user: null);
      final container = ProviderContainer(
        overrides: [supabaseBackendServiceProvider.overrideWithValue(backend)],
      );
      addTearDown(container.dispose);
      final meals = container.read(mealRecordsProvider.notifier);
      await meals.replaceAll([_meal('old')]);

      await meals.removeMeal('old');
      await meals.syncIdle;

      final pending = LocalStorageService().getPendingMealSync();
      expect(pending.single['op'], 'delete');
      expect(pending.single['at'], isNotNull);
    });
  });

  group('Profile sync', () {
    UserProfile onboarded(String name) => UserProfile.defaultProfile().copyWith(
      name: name,
      onboardingCompleted: true,
    );

    test('a newer edit on this device is uploaded', () async {
      await LocalStorageService().setLocalDataOwner('user-a');
      final backend = _FakeBackend(
        user: _user('user-a'),
        remoteProfile: RemoteProfile(
          profile: onboarded('remote'),
          updatedAt: DateTime.utc(2026, 5, 1),
        ),
      );
      final container = ProviderContainer(
        overrides: [supabaseBackendServiceProvider.overrideWithValue(backend)],
      );
      addTearDown(container.dispose);
      await container
          .read(userProfileProvider.notifier)
          .updateProfile(onboarded('local'));
      await LocalStorageService().setProfileEditedAt(DateTime.utc(2026, 5, 2));

      await container
          .read(supabaseAuthControllerProvider.notifier)
          .mergeAfterSignIn();

      expect(container.read(userProfileProvider).name, 'local');
      expect(backend.profileUpserts.last.name, 'local');
    });

    test('a newer account copy replaces an older device copy', () async {
      await LocalStorageService().setLocalDataOwner('user-a');
      final backend = _FakeBackend(
        user: _user('user-a'),
        remoteProfile: RemoteProfile(
          profile: onboarded('remote'),
          updatedAt: DateTime.utc(2026, 5, 3),
        ),
      );
      final container = ProviderContainer(
        overrides: [supabaseBackendServiceProvider.overrideWithValue(backend)],
      );
      addTearDown(container.dispose);
      await container
          .read(userProfileProvider.notifier)
          .updateProfile(onboarded('local'));
      await LocalStorageService().setProfileEditedAt(DateTime.utc(2026, 5, 2));
      backend.profileUpserts.clear();

      await container
          .read(supabaseAuthControllerProvider.notifier)
          .mergeAfterSignIn();

      expect(container.read(userProfileProvider).name, 'remote');
      expect(backend.profileUpserts, isEmpty);
    });
  });

  group('Interrupted capture', () {
    test('an unfinished review comes back after a restart', () async {
      final first = ProviderContainer();
      first
          .read(mealCaptureProvider.notifier)
          .startManual(
            foods: [
              FoodItem(
                name: '비빔밥',
                calories: 650,
                carbs: 90,
                protein: 20,
                fat: 18,
              ),
            ],
          );
      first.read(mealCaptureProvider.notifier).setMealType(MealType.dinner);
      await Future<void>.delayed(Duration.zero);
      first.dispose();

      final second = ProviderContainer();
      addTearDown(second.dispose);
      final restored = second.read(mealCaptureProvider);
      expect(restored.status, MealCaptureStatus.review);
      expect(restored.drafts.single.name, '비빔밥');
      expect(restored.mealType, MealType.dinner);

      second.read(mealCaptureProvider.notifier).reset();
      await Future<void>.delayed(Duration.zero);
      expect(LocalStorageService().getCaptureDraft(), isNull);
    });

    test('an analysis cut off by the system is offered as a retry', () async {
      await LocalStorageService().saveCaptureDraft({
        'status': 'analyzing',
        'imagePath': 'meal_images/meal_1.jpg',
        'drafts': <Object>[],
        'mealType': 'lunch',
        'dateTime': DateTime.utc(2026, 5, 1, 3).toIso8601String(),
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final restored = container.read(mealCaptureProvider);
      expect(restored.status, MealCaptureStatus.failed);
      expect(restored.error, MealCaptureError.recognitionFailed);
      expect(restored.imagePath, 'meal_images/meal_1.jpg');
    });
  });

  group('Dates', () {
    test('the report date follows today across midnight until changed', () {
      var now = DateTime(2026, 5, 1, 23, 59);
      final container = ProviderContainer(
        overrides: [
          todayDateProvider.overrideWith(
            (ref) => TodayDateNotifier(clock: () => now),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(selectedDateProvider), DateTime(2026, 5, 1));
      now = DateTime(2026, 5, 2, 0, 1);
      container.read(todayDateProvider.notifier).refresh();
      expect(container.read(selectedDateProvider), DateTime(2026, 5, 2));

      container.read(selectedDateProvider.notifier).state = DateTime(
        2026,
        4,
        20,
      );
      now = DateTime(2026, 5, 3, 0, 1);
      container.read(todayDateProvider.notifier).refresh();
      expect(container.read(selectedDateProvider), DateTime(2026, 4, 20));
    });

    test('weeks always start on a Monday at midnight', () {
      for (var i = 0; i < 366; i++) {
        final anchor = DateTime(2026, 1, 1 + i, 15);
        final period = ReportPeriod.from(
          range: ReportRange.week,
          anchorDate: anchor,
        );
        expect(period.start.weekday, DateTime.monday);
        expect(period.start.hour, 0);
        expect(period.contains(anchor), isTrue);
        expect(period.dayCount, 7);
      }
    });
  });

  group('Strategy badge', () {
    final profile = UserProfile.defaultProfile().copyWith(
      wellnessGoal: WellnessGoal.balanced,
      currentWeight: 65,
      dailyCalorieGoal: 2000,
    );
    final balancedLunch = MealRecord(
      id: 'l',
      date: DateTime(2026, 5, 1, 12),
      mealType: MealType.lunch,
      name: 'lunch',
      calories: 600,
      carbs: 70,
      protein: 35,
      fat: 15,
    );

    test('logging consistency is measured, not always awarded', () {
      final noon = MealStrategyBuilder.build(
        profile: profile,
        meals: [balancedLunch],
        now: DateTime(2026, 5, 1, 13),
      );
      final evening = MealStrategyBuilder.build(
        profile: profile,
        meals: [balancedLunch],
        now: DateTime(2026, 5, 1, 20),
      );

      int consistency(MealStrategy s) => s.factors.last.earned;
      expect(consistency(noon), lessThan(23));
      expect(consistency(evening), lessThan(consistency(noon)));
      // A balanced plate with missing logs is not shown as all good.
      expect(evening.alertLevel, StrategyAlertLevel.watch);
    });

    test('a complete, balanced day is good', () {
      final strategy = MealStrategyBuilder.build(
        profile: profile,
        meals: [
          balancedLunch.copyWith(id: 'b', mealType: MealType.breakfast),
          balancedLunch,
          balancedLunch.copyWith(id: 'd', mealType: MealType.dinner),
        ],
        now: DateTime(2026, 5, 1, 21),
      );
      expect(strategy.factors.every((f) => f.isMet), isTrue);
      expect(strategy.alertLevel, StrategyAlertLevel.good);
    });
  });

  group('AI coach', () {
    test('a reply that arrives after clearing is dropped', () async {
      final service = _SlowChatService();
      final container = ProviderContainer(
        overrides: [
          aiChatServiceProvider.overrideWithValue(service),
          ..._consented,
        ],
      );
      addTearDown(container.dispose);
      final chat = container.read(chatMessagesProvider.notifier);

      final sending = chat.send('질문');
      await Future<void>.delayed(Duration.zero);
      expect(container.read(chatLoadingProvider), isTrue);

      await chat.clear();
      expect(container.read(chatLoadingProvider), isFalse);
      service.pending.complete(const AiChatReply(content: 'late answer'));
      await sending;

      expect(container.read(chatMessagesProvider), isEmpty);
      expect(LocalStorageService().getChatHistory(), isEmpty);
    });

    test('the connection status comes from this session only', () async {
      final container = ProviderContainer(
        overrides: [
          aiChatServiceProvider.overrideWithValue(_SlowChatService()),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(chatStatusProvider), CoachConnection.needsConsent);

      await container.read(aiDataConsentProvider.notifier).setValue(true);
      expect(container.read(chatStatusProvider), CoachConnection.online);

      container.read(coachConnectionProvider.notifier).state =
          CoachConnection.limited;
      expect(container.read(chatOnlineProvider), isFalse);
      expect(container.read(chatStatusProvider), CoachConnection.limited);
    });
  });

  group('Built-in foods', () {
    test('English search finds and shows English names', () async {
      final service = FoodApiService(proxyConfig: ProxyClientConfig());
      final results = await service.searchFood('salmon', locale: 'en');
      expect(results.map((f) => f.name), contains('Salmon 100g'));

      final suggestions = await service.searchFood('', locale: 'en');
      expect(suggestions.first.name, isNot(matches(RegExp('[가-힣]'))));

      final korean = await service.searchFood('연어', locale: 'ko');
      expect(korean.map((f) => f.name), contains('연어 100g'));
    });
  });

  group('MealImageStore', () {
    test('detects the real image type from the file header', () {
      expect(
        MealImageStore.sniffContentType([0xFF, 0xD8, 0xFF, 0xE0]),
        'image/jpeg',
      );
      expect(
        MealImageStore.sniffContentType([0x89, 0x50, 0x4E, 0x47, 0, 0, 0, 0]),
        'image/png',
      );
      expect(MealImageStore.extensionForContentType('image/jpeg'), 'jpg');
      expect(MealImageStore.sniffContentType([1, 2, 3]), isNull);
    });

    test('orphan photos are swept, referenced and recent ones kept', () async {
      final dir = await Directory.systemTemp.createTemp('image_sweep');
      addTearDown(() => dir.delete(recursive: true));
      MealImageStore.debugSetDocumentsPath(dir.path);
      addTearDown(() => MealImageStore.debugSetDocumentsPath(null));
      final folder = Directory('${dir.path}/meal_images')..createSync();
      final old = DateTime.now().subtract(const Duration(days: 3));
      final used = File('${folder.path}/used.jpg')
        ..writeAsBytesSync([1])
        ..setLastModifiedSync(old);
      final orphan = File('${folder.path}/orphan.jpg')
        ..writeAsBytesSync([1])
        ..setLastModifiedSync(old);
      final fresh = File('${folder.path}/fresh.jpg')..writeAsBytesSync([1]);

      final removed = await MealImageStore.sweepOrphans({
        'meal_images/used.jpg',
      });

      expect(removed, 1);
      expect(used.existsSync(), isTrue);
      expect(orphan.existsSync(), isFalse);
      expect(fresh.existsSync(), isTrue);
    });

    test('clearAll removes stored photos', () async {
      final dir = await Directory.systemTemp.createTemp('image_store');
      addTearDown(() => dir.delete(recursive: true));
      MealImageStore.debugSetDocumentsPath(dir.path);
      addTearDown(() => MealImageStore.debugSetDocumentsPath(null));
      final source = File('${dir.path}/source.jpg')..writeAsBytesSync([1, 2]);

      final stored = await MealImageStore.persist(source.path);
      expect(MealImageStore.resolveFile(stored), isNotNull);

      await MealImageStore.clearAll();
      expect(MealImageStore.resolveFile(stored), isNull);
      expect(Directory('${dir.path}/meal_images').existsSync(), isFalse);
    });
  });

  group('AI data consent', () {
    test(
      'without consent the coach answers locally and sends nothing',
      () async {
        final service = _CountingChatService();
        final container = ProviderContainer(
          overrides: [aiChatServiceProvider.overrideWithValue(service)],
        );
        addTearDown(container.dispose);

        await container.read(chatMessagesProvider.notifier).send('운동 추천해줘');

        expect(service.calls, 0);
        expect(container.read(chatMessagesProvider).last.content, isNotEmpty);
      },
    );

    test('photo analysis waits for consent', () async {
      final container = ProviderContainer(
        overrides: [
          foodImageRecognitionServiceProvider.overrideWithValue(
            _ConfiguredRecognitionService(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(mealCaptureProvider.notifier)
          .startFromImage('meal_images/x.jpg');

      final state = container.read(mealCaptureProvider);
      expect(state.status, MealCaptureStatus.failed);
      expect(state.error, MealCaptureError.consentRequired);
    });
  });

  group('Photo metadata', () {
    test('GPS is removed and the orientation kept', () {
      final jpeg = _jpegWithExif();
      final cleaned = stripJpegGps(jpeg);

      expect(cleaned.length, jpeg.length);
      final tiff = 12; // SOI(2) + APP1 marker(2) + length(2) + "Exif\0\0"(6)
      final view = ByteData.sublistView(cleaned);
      // IFD0 still has the orientation entry with value 6.
      expect(view.getUint16(tiff + 8 + 2, Endian.little), 0x0112);
      expect(view.getUint16(tiff + 8 + 2 + 8, Endian.little), 6);
      // GPS directory is empty and the latitude values are zeroed.
      expect(view.getUint16(tiff + _gpsIfd, Endian.little), 0);
      expect(
        cleaned.sublist(tiff + _gpsValues, tiff + _gpsValues + 24),
        everyElement(0),
      );
      // Not a JPEG: unchanged.
      final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
      expect(identical(stripJpegGps(png), png), isTrue);
    });
  });
}

class _CountingChatService extends AiChatService {
  int calls = 0;

  @override
  bool get isConfigured => true;

  @override
  Future<AiChatReply> reply({
    required String userMessage,
    List<AiChatTurn> history = const [],
    Map<String, dynamic>? context,
    String locale = 'ko',
  }) async {
    calls++;
    return const AiChatReply(content: 'remote');
  }
}

class _ConfiguredRecognitionService extends FoodImageRecognitionService {
  @override
  bool get isConfigured => true;
}

// TIFF-relative offsets used by [_jpegWithExif].
const _gpsIfd = 38;
const _gpsValues = 56;

/// Minimal little-endian EXIF block: IFD0 with Orientation=6 and a GPS
/// pointer; the GPS IFD has GPSLatitude (3 rationals stored out of line).
Uint8List _jpegWithExif() {
  final tiff = BytesBuilder();
  final b = ByteData(80);
  b.setUint8(0, 0x49);
  b.setUint8(1, 0x49);
  b.setUint16(2, 42, Endian.little);
  b.setUint32(4, 8, Endian.little); // IFD0 at 8
  b.setUint16(8, 2, Endian.little); // 2 entries
  // Orientation (SHORT, 1) = 6
  b.setUint16(10, 0x0112, Endian.little);
  b.setUint16(12, 3, Endian.little);
  b.setUint32(14, 1, Endian.little);
  b.setUint16(18, 6, Endian.little);
  // GPS IFD pointer (LONG, 1) = 38
  b.setUint16(22, 0x8825, Endian.little);
  b.setUint16(24, 4, Endian.little);
  b.setUint32(26, 1, Endian.little);
  b.setUint32(30, _gpsIfd, Endian.little);
  b.setUint32(34, 0, Endian.little); // no next IFD
  // GPS IFD: 1 entry, GPSLatitude (RATIONAL, 3) at 56
  b.setUint16(_gpsIfd, 1, Endian.little);
  b.setUint16(40, 0x0002, Endian.little);
  b.setUint16(42, 5, Endian.little);
  b.setUint32(44, 3, Endian.little);
  b.setUint32(48, _gpsValues, Endian.little);
  b.setUint32(52, 0, Endian.little);
  for (var i = 0; i < 6; i++) {
    b.setUint32(_gpsValues + i * 4, 37 + i, Endian.little);
  }
  tiff.add(b.buffer.asUint8List());

  final exif = [0x45, 0x78, 0x69, 0x66, 0, 0, ...tiff.toBytes()];
  final length = exif.length + 2;
  return Uint8List.fromList([
    0xFF, 0xD8, // SOI
    0xFF, 0xE1, length >> 8, length & 0xFF, ...exif,
    0xFF, 0xDA, 0, 2, // SOS
    0xFF, 0xD9, // EOI
  ]);
}
