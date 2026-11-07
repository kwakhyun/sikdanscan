import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sikdanscan/data/models/chat_message.dart';
import 'package:sikdanscan/data/models/food_recognition_result.dart';
import 'package:sikdanscan/data/models/meal_record.dart';
import 'package:sikdanscan/data/services/ai_chat_service.dart';
import 'package:sikdanscan/data/services/food_api_service.dart';
import 'package:sikdanscan/data/services/food_image_recognition_service.dart';
import 'package:sikdanscan/data/services/local_storage_service.dart';
import 'package:sikdanscan/data/services/proxy_client_config.dart';
import 'package:sikdanscan/features/meal/report_models.dart';
import 'package:sikdanscan/providers/app_providers.dart';

MealRecord _meal(
  String id,
  DateTime date, {
  int calories = 500,
  DateTime? updatedAt,
  MealType type = MealType.lunch,
}) {
  return MealRecord(
    id: id,
    date: date,
    mealType: type,
    name: 'meal $id',
    calories: calories,
    carbs: 50,
    protein: 20,
    fat: 10,
    updatedAt: updatedAt,
  );
}

/// No proxy configured (tests must not fall back to the debug emulator URL).
final _offline = [
  proxyClientConfigProvider.overrideWithValue(ProxyClientConfig()),
];

void main() {
  setUpAll(() async {
    Hive.init('/tmp/hive_review_test_${DateTime.now().microsecondsSinceEpoch}');
    for (final name in const [
      'user_profile',
      'weight_records',
      'meal_records',
      'daily_health',
      'settings',
    ]) {
      await Hive.openBox<String>(name);
    }
  });

  setUp(() async {
    for (final name in const [
      'user_profile',
      'weight_records',
      'meal_records',
      'daily_health',
      'settings',
    ]) {
      await Hive.box<String>(name).clear();
    }
  });

  tearDownAll(() async => Hive.close());

  group('Meal merge with remote account', () {
    test('keeps local-only records and uploads them', () {
      final local = [_meal('local', DateTime(2026, 3, 1, 8))];
      final remote = [_meal('remote', DateTime(2026, 3, 2, 8))];

      final result = MealRecordsNotifier.mergeRecords(
        local: local,
        remote: remote,
      );

      expect(result.merged.map((m) => m.id), ['local', 'remote']);
      expect(result.toUpload.map((m) => m.id), ['local']);
    });

    test('newer copy wins and pending deletes are not resurrected', () {
      final older = DateTime(2026, 3, 1, 9);
      final newer = DateTime(2026, 3, 1, 10);
      final local = [
        _meal(
          'shared',
          DateTime(2026, 3, 1, 8),
          calories: 700,
          updatedAt: newer,
        ),
        _meal(
          'stale',
          DateTime(2026, 3, 1, 9),
          calories: 100,
          updatedAt: older,
        ),
      ];
      final remote = [
        _meal(
          'shared',
          DateTime(2026, 3, 1, 8),
          calories: 300,
          updatedAt: older,
        ),
        _meal(
          'stale',
          DateTime(2026, 3, 1, 9),
          calories: 900,
          updatedAt: newer,
        ),
        _meal('deleted', DateTime(2026, 3, 1, 12)),
      ];

      final result = MealRecordsNotifier.mergeRecords(
        local: local,
        remote: remote,
        pendingDeleteIds: {'deleted'},
      );
      final byId = {for (final m in result.merged) m.id: m};

      expect(byId['shared']!.calories, 700);
      expect(byId['stale']!.calories, 900);
      expect(byId.containsKey('deleted'), isFalse);
      expect(result.toUpload.map((m) => m.id), ['shared']);
    });

    test('failed uploads are queued and retried', () async {
      var online = false;
      final upserts = <String>[];
      final notifier = MealRecordsNotifier(
        LocalStorageService(),
        remoteUpsert: (meal) async {
          if (!online) throw StateError('offline');
          upserts.add(meal.id);
        },
      );

      await notifier.addMeal(_meal('offline', DateTime(2026, 3, 1, 8)));
      expect(LocalStorageService().getPendingMealSync(), hasLength(1));

      online = true;
      await notifier.flushPendingSync();

      expect(upserts, ['offline']);
      expect(LocalStorageService().getPendingMealSync(), isEmpty);
    });

    test('stamps updatedAt on add and update', () async {
      final clock = DateTime(2026, 4, 1, 9, 30);
      final notifier = MealRecordsNotifier(
        LocalStorageService(),
        clock: () => clock,
      );
      await notifier.addMeal(_meal('a', DateTime(2026, 4, 1, 8)));
      expect(notifier.state.single.updatedAt, clock);
    });
  });

  group('Daily vs report dates', () {
    test('today meals ignore the report date selection', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final now = DateTime.now();
      await container
          .read(mealRecordsProvider.notifier)
          .addMeal(_meal('today', now));
      await container
          .read(mealRecordsProvider.notifier)
          .addMeal(_meal('old', now.subtract(const Duration(days: 3))));

      container.read(selectedDateProvider.notifier).state = now.subtract(
        const Duration(days: 3),
      );

      expect(container.read(todayMealsProvider).map((m) => m.id), ['today']);
      expect(container.read(selectedDateMealsProvider).map((m) => m.id), [
        'old',
      ]);
      expect(container.read(todayCaloriesProvider), 500);
    });

    test('today date refreshes when the day changes', () {
      var now = DateTime(2026, 5, 1, 23, 59);
      final notifier = TodayDateNotifier(clock: () => now);
      addTearDown(notifier.dispose);
      expect(notifier.state, DateTime(2026, 5, 1));

      now = DateTime(2026, 5, 2, 0, 1);
      notifier.refresh();
      expect(notifier.state, DateTime(2026, 5, 2));
    });
  });

  group('Report math', () {
    test('goal counts only started days and average uses logged days', () {
      final today = DateTime(2026, 11, 5);
      final period = ReportPeriod.from(
        range: ReportRange.month,
        anchorDate: today,
      );
      final meals = [
        _meal('1', DateTime(2026, 11, 1, 8), calories: 1800),
        _meal('2', DateTime(2026, 11, 3, 12), calories: 1200),
        _meal('3', DateTime(2026, 11, 3, 19), calories: 600),
        _meal('other', DateTime(2026, 10, 31, 12), calories: 9999),
      ];

      final summary = ReportSummary.from(
        meals: meals,
        period: period,
        dailyCalorieGoal: 2000,
        today: today,
      );

      expect(period.dayCount, 30);
      expect(summary.goalDays, 5);
      expect(summary.calorieGoal, 10000);
      expect(summary.calories, 3600);
      expect(summary.recordedDays, 2);
      expect(summary.dailyAverageCalories, 1800);
    });

    test('past periods count every day and shifting weeks keeps Monday', () {
      final period = ReportPeriod.from(
        range: ReportRange.week,
        anchorDate: DateTime(2026, 11, 5),
      );
      expect(period.start, DateTime(2026, 11, 2));
      expect(period.end, DateTime(2026, 11, 8));
      expect(period.elapsedDays(DateTime(2026, 12, 1)), 7);
      expect(period.shift(-1).start, DateTime(2026, 10, 26));

      final buckets = dailyCalories(period, [
        _meal('a', DateTime(2026, 11, 2, 8), calories: 300),
        _meal('b', DateTime(2026, 11, 2, 12), calories: 400),
      ]);
      expect(buckets, hasLength(7));
      expect(buckets.first.$2, 700);
    });
  });

  group('Portion editing', () {
    test('changing portion rescales from the 1x base without compounding', () {
      final base = _meal('p', DateTime(2026, 1, 1), calories: 600);
      final half = base.withPortion(0.5);
      expect(half.calories, 300);
      expect(half.portion, 0.5);

      final doubled = half.withPortion(2.0);
      expect(doubled.calories, 1200);
      expect(doubled.carbs, 100);
      expect(doubled.withPortion(1.0).calories, 600);
    });
  });

  group('Meal capture flow', () {
    test('manual entry saves edited drafts with portion and time', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(mealCaptureProvider.notifier);
      final date = DateTime(2026, 2, 3);

      controller.startManual(
        foods: [
          FoodItem(name: '김밥', calories: 400, carbs: 60, protein: 12, fat: 10),
        ],
        date: date,
      );
      final key = container.read(mealCaptureProvider).drafts.single.key;
      controller.updateDraft(key, (d) => d.copyWith(portion: 1.5));
      final blank = controller.addBlankDraft();
      controller.setMealType(MealType.dinner);

      expect(container.read(mealCaptureProvider).selectedDrafts, hasLength(1));
      final saved = await controller.save();

      expect(saved, 1);
      final record = container.read(mealRecordsProvider).single;
      expect(record.name, '김밥');
      expect(record.calories, 600);
      expect(record.portion, 1.5);
      expect(record.mealType, MealType.dinner);
      expect(record.date.year, 2026);
      expect(record.date.day, 3);
      expect(blank, isNotEmpty);
      expect(
        container.read(mealCaptureProvider).status,
        MealCaptureStatus.idle,
      );
    });

    test(
      'recognition result is kept for review, not saved automatically',
      () async {
        final fake = _FakeRecognitionService(
          result: const FoodRecognitionResult(
            summary: '비빔밥',
            confidence: 0.5,
            needsReview: true,
            items: [
              RecognizedFoodItem(
                name: '비빔밥',
                calories: 650,
                carbs: 90,
                protein: 20,
                fat: 18,
                confidence: 0.5,
              ),
            ],
          ),
        );
        final container = ProviderContainer(
          overrides: [
            foodImageRecognitionServiceProvider.overrideWithValue(fake),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(mealCaptureProvider.notifier)
            .startFromImage('/tmp/photo.jpg');

        final state = container.read(mealCaptureProvider);
        expect(state.status, MealCaptureStatus.review);
        expect(state.needsReview, isTrue);
        expect(state.drafts.single.isLowConfidence, isTrue);
        expect(container.read(mealRecordsProvider), isEmpty);
      },
    );

    test('cancelling ignores a late recognition result', () async {
      final completer = Completer<FoodRecognitionResult>();
      final fake = _FakeRecognitionService(pending: completer);
      final container = ProviderContainer(
        overrides: [
          foodImageRecognitionServiceProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(mealCaptureProvider.notifier);

      final future = controller.startFromImage('/tmp/photo.jpg');
      expect(
        container.read(mealCaptureProvider).status,
        MealCaptureStatus.analyzing,
      );
      controller.reset();
      completer.complete(
        const FoodRecognitionResult(
          items: [
            RecognizedFoodItem(
              name: 'late',
              calories: 1,
              carbs: 0,
              protein: 0,
              fat: 0,
            ),
          ],
        ),
      );
      await future;

      expect(
        container.read(mealCaptureProvider).status,
        MealCaptureStatus.idle,
      );
      expect(fake.cancelled, isTrue);
    });

    test('reports that the AI server is required for photos', () async {
      final container = ProviderContainer(overrides: _offline);
      addTearDown(container.dispose);
      await container
          .read(mealCaptureProvider.notifier)
          .startFromImage('/tmp/photo.jpg');
      final state = container.read(mealCaptureProvider);
      expect(state.status, MealCaptureStatus.failed);
      expect(state.error, MealCaptureError.proxyRequired);
    });
  });

  group('AI coach conversation', () {
    test('persists messages and labels offline answers', () async {
      final container = ProviderContainer(overrides: _offline);
      addTearDown(container.dispose);

      await container.read(chatMessagesProvider.notifier).send('운동 추천해줘');
      final messages = container.read(chatMessagesProvider);

      expect(messages, hasLength(2));
      expect(messages.first.isUser, isTrue);
      expect(messages.last.type, ChatMessageType.offline);
      expect(LocalStorageService().getChatHistory(), hasLength(2));

      final reloaded = ProviderContainer(overrides: _offline);
      addTearDown(reloaded.dispose);
      expect(reloaded.read(chatMessagesProvider), hasLength(2));
    });

    test('sends prior turns as history and supports retry', () async {
      final service = _ScriptedChatService();
      final container = ProviderContainer(
        overrides: [aiChatServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      final chat = container.read(chatMessagesProvider.notifier);

      await chat.send('첫 질문');
      service.fail = true;
      await chat.send('두번째');
      expect(
        container.read(chatMessagesProvider).last.type,
        ChatMessageType.error,
      );

      service.fail = false;
      await chat.retryLast();

      final messages = container.read(chatMessagesProvider);
      expect(messages.where((m) => m.type == ChatMessageType.error), isEmpty);
      expect(messages.where((m) => m.isUser), hasLength(2));
      expect(service.lastHistory.map((t) => t.content), [
        '첫 질문',
        'answer: 첫 질문',
      ]);
      expect(service.lastContext?['meals'], isA<List<dynamic>>());
    });
  });

  group('Locale resolution', () {
    test('falls back to English for unsupported device languages', () {
      expect(
        AppLocalePreference.resolveSupportedLanguageCode(const [
          Locale('ja'),
          Locale('ko'),
        ]),
        'ko',
      );
      expect(
        AppLocalePreference.resolveSupportedLanguageCode(const [Locale('ja')]),
        'en',
      );
    });
  });
}

class _FakeRecognitionService extends FoodImageRecognitionService {
  _FakeRecognitionService({this.result, this.pending});

  final FoodRecognitionResult? result;
  final Completer<FoodRecognitionResult>? pending;
  bool cancelled = false;

  @override
  bool get isConfigured => true;

  @override
  Future<FoodRecognitionResult> recognizeImageFile(
    String imagePath, {
    String locale = 'ko',
    CancelToken? cancelToken,
  }) async {
    cancelToken?.whenCancel.then((_) => cancelled = true);
    if (pending != null) return pending!.future;
    return result!;
  }
}

class _ScriptedChatService extends AiChatService {
  bool fail = false;
  List<AiChatTurn> lastHistory = const [];
  Map<String, dynamic>? lastContext;

  @override
  bool get isConfigured => true;

  @override
  Future<AiChatReply> reply({
    required String userMessage,
    List<AiChatTurn> history = const [],
    Map<String, dynamic>? context,
    String locale = 'ko',
  }) async {
    if (fail) throw StateError('server down');
    lastHistory = history;
    lastContext = context;
    return AiChatReply(content: 'answer: $userMessage');
  }
}
