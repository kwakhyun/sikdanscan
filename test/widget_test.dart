import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sikdanscan/data/models/meal_record.dart';
import 'package:sikdanscan/data/services/food_api_service.dart';
import 'package:sikdanscan/features/chat/chat_screen.dart';
import 'package:sikdanscan/features/meal/meal_review_screen.dart';
import 'package:sikdanscan/data/models/user_profile.dart';
import 'package:sikdanscan/data/services/local_storage_service.dart';
import 'package:sikdanscan/data/services/proxy_client_config.dart';
import 'package:sikdanscan/features/meal/meal_screen.dart';
import 'package:sikdanscan/features/meal/widgets/meal_record_sheet.dart';
import 'package:sikdanscan/features/chat/widgets/suggestion_chips.dart';
import 'package:sikdanscan/features/dashboard/dashboard_screen.dart';
import 'package:sikdanscan/features/onboarding/onboarding_screen.dart';
import 'package:sikdanscan/features/profile/widgets/settings_section.dart';
import 'package:sikdanscan/l10n/generated/app_localizations.dart';
import 'package:sikdanscan/providers/app_providers.dart';
import 'package:sikdanscan/shared/widgets/main_scaffold.dart';

void main() {
  testWidgets('First launch shows onboarding without unusable social login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _LocalizedMaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('식단스캔 시작하기'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    // Supabase is not configured in tests, so social buttons are hidden.
    expect(find.text('Kakao'), findsNothing);
    expect(find.text('Google'), findsNothing);
  });

  testWidgets('Onboarding offers social login when cloud sync is configured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [supabaseConfiguredProvider.overrideWithValue(true)],
        child: const _LocalizedMaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('간편 가입하고 시작'), findsOneWidget);
    expect(find.text('Kakao'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
  });

  testWidgets('Onboarding shows validation errors inline on the fields', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const ProviderScope(
        child: _LocalizedMaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), '5');
    await tester.enterText(fields.at(2), '170');
    await tester.enterText(fields.at(3), '60');
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('나이를 10~100 사이로 입력해주세요.'), findsOneWidget);
    expect(find.text('이 기준으로 시작합니다'), findsNothing);
  });

  testWidgets(
    'Typing a partial weight with the weight-loss goal does not crash',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        const ProviderScope(
          child: _LocalizedMaterialApp(home: OnboardingScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('시작하기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('체중 감량'));
      await tester.pump();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(1), '31');
      await tester.enterText(fields.at(2), '164');
      // Digit-by-digit entry passes through "6" before "63".
      await tester.enterText(fields.at(3), '6');
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.enterText(fields.at(3), '63');
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('목표 체중'), findsOneWidget);
    },
  );

  testWidgets('Onboarding review step remains scrollable on compact screens', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: _LocalizedMaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(4));

    await tester.enterText(fields.at(0), '토리나나');
    await tester.enterText(fields.at(1), '30');
    await tester.enterText(fields.at(2), '189');
    await tester.enterText(fields.at(3), '70');
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('이 기준으로 시작합니다'), findsOneWidget);
    expect(find.text('일일 목표 칼로리'), findsOneWidget);
    expect(find.byTooltip('목표 칼로리 50 kcal 높이기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SikdanScan app smoke test - dashboard loads after onboarding', (
    WidgetTester tester,
  ) async {
    await _pumpDashboardApp(tester);

    expect(find.text('식사 기록'), findsOneWidget);
    expect(find.text('오늘 섭취 현황'), findsOneWidget);
    expect(find.text('수분'), findsOneWidget);
    expect(find.textContaining('안녕하세요'), findsNothing);
  });

  testWidgets('Bottom navigation has 4 tabs after onboarding', (
    WidgetTester tester,
  ) async {
    await _pumpDashboardApp(tester);

    expect(find.text('데일리'), findsOneWidget);
    expect(find.text('리포트'), findsOneWidget);
    expect(find.text('AI 코치'), findsOneWidget);
    expect(find.text('프로필'), findsOneWidget);
  });

  testWidgets('Bottom navigation uses English labels for English locale', (
    WidgetTester tester,
  ) async {
    await _pumpDashboardApp(tester, locale: const Locale('en'));

    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Report'), findsOneWidget);
    expect(find.text('AI Coach'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Log meal sheet keeps search available without the AI server', (
    WidgetTester tester,
  ) async {
    await _pumpDashboardApp(tester);

    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.text('식사 기록'));
    await tester.pumpAndSettle();

    expect(find.text('식사 기록하기'), findsOneWidget);
    expect(find.text('검색 · 직접 입력'), findsOneWidget);
    expect(find.text('사진 인식은 AI 서버 연결 후 사용할 수 있어요'), findsNWidgets(2));

    await tester.tap(find.text('검색 · 직접 입력'));
    await tester.pumpAndSettle();
    expect(find.text('식단 추가'), findsOneWidget);
  });

  testWidgets('Water card adds a glass', (WidgetTester tester) async {
    await _pumpDashboardApp(tester);

    expect(find.text('0 / 2,000 ml'), findsOneWidget);
    await tester.tap(find.byTooltip('물 한 잔(250ml) 추가'));
    await tester.pump();
    expect(find.text('250 / 2,000 ml'), findsOneWidget);
  });

  testWidgets('SuggestionChips displays all suggestions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _LocalizedMaterialApp(
        home: Scaffold(body: SuggestionChips(onSuggestionTap: (_) {})),
      ),
    );

    expect(find.text('오늘 칼로리 분석'), findsOneWidget);
    expect(find.text('운동 추천해줘'), findsOneWidget);
    expect(find.text('수분 섭취 팁'), findsOneWidget);
    expect(find.text('체중 변화 분석'), findsOneWidget);
    expect(find.text('건강한 간식 추천'), findsOneWidget);
  });

  testWidgets('Meal record sheet edits name, meal type and portion', (
    WidgetTester tester,
  ) async {
    final meal = _sheetTestMeal();
    final notifier = MealRecordsNotifier(_InMemoryMealStorage([meal.toJson()]));

    await _pumpMealSheetHost(tester, notifier: notifier, meal: meal);

    expect(find.text('김치찌개'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, '김치찌개'), '된장찌개');
    await tester.tap(find.text('저녁'));
    await tester.pump();
    await tester.tap(find.text('0.5×'));
    await tester.pump();

    expect(find.text('300'), findsOneWidget);

    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    final updated = notifier.state.single;
    expect(updated.name, '된장찌개');
    expect(updated.mealType, MealType.dinner);
    expect(updated.calories, 300);
    expect(updated.carbs, 20);
    expect(updated.protein, 15);
    expect(updated.fat, 10);
    expect(updated.portion, 0.5);
  });

  testWidgets('Portion edits do not compound across saves', (
    WidgetTester tester,
  ) async {
    final meal = _sheetTestMeal().copyWith(
      portion: 0.5,
      calories: 300,
      carbs: 20,
      protein: 15,
      fat: 10,
    );
    final notifier = MealRecordsNotifier(_InMemoryMealStorage([meal.toJson()]));

    await _pumpMealSheetHost(tester, notifier: notifier, meal: meal);
    await tester.tap(find.text('2×'));
    await tester.pump();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(notifier.state.single.calories, 1200);
    expect(notifier.state.single.portion, 2.0);
  });

  testWidgets('Deleting a record can be undone', (WidgetTester tester) async {
    final meal = _sheetTestMeal();
    final notifier = MealRecordsNotifier(_InMemoryMealStorage([meal.toJson()]));

    await _pumpMealSheetHost(tester, notifier: notifier, meal: meal);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    expect(notifier.state, isEmpty);
    expect(find.text('기록을 삭제했습니다'), findsOneWidget);

    await tester.tap(find.text('되돌리기'));
    await tester.pumpAndSettle();

    expect(notifier.state.single.id, meal.id);
  });

  testWidgets('Review screen saves only after confirmation', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final notifier = MealRecordsNotifier(_InMemoryMealStorage([]));
    final container = ProviderContainer(
      overrides: [mealRecordsProvider.overrideWith((ref) => notifier)],
    );
    addTearDown(container.dispose);
    container
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

    final router = GoRouter(
      initialLocation: '/meal-review',
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const _RouteStub(label: '데일리 화면'),
        ),
        GoRoute(
          path: '/meal-review',
          builder: (context, state) => const MealReviewScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('ko'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('기록 확인'), findsOneWidget);
    expect(notifier.state, isEmpty);

    await tester.tap(find.text('1.5×'));
    await tester.pump();
    await tester.tap(find.textContaining('1개 저장'));
    await tester.pumpAndSettle();

    expect(notifier.state.single.name, '비빔밥');
    expect(notifier.state.single.calories, 975);
    expect(find.text('데일리 화면'), findsOneWidget);
  });

  testWidgets('Weekly report shows meal type breakdown with shares', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final today = DateTime.now();
    final meals = [
      MealRecord(
        id: 'wk_breakfast',
        date: DateTime(today.year, today.month, today.day, 8),
        mealType: MealType.breakfast,
        name: '오트밀',
        calories: 300,
        carbs: 50,
        protein: 10,
        fat: 5,
      ),
      MealRecord(
        id: 'wk_lunch',
        date: DateTime(today.year, today.month, today.day, 12, 30),
        mealType: MealType.lunch,
        name: '비빔밥',
        calories: 700,
        carbs: 90,
        protein: 25,
        fat: 18,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith(
            (ref) => UserProfileNotifier(_ProfileStorage(_onboardedProfile())),
          ),
          mealRecordsProvider.overrideWith(
            (ref) => MealRecordsNotifier(
              _InMemoryMealStorage(meals.map((m) => m.toJson()).toList()),
            ),
          ),
        ],
        child: const _LocalizedMaterialApp(home: MealScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('식사 유형별 비중'), findsNothing);
    expect(find.text('끼니별 섭취'), findsOneWidget);

    await tester.tap(find.text('주간'));
    await tester.pumpAndSettle();

    expect(find.text('식사 유형별 비중'), findsOneWidget);
    expect(find.text('30%'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
    expect(find.textContaining('1건'), findsNWidgets(2));
  });

  testWidgets('Profile language setting opens bottom sheet with selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themePreferenceProvider.overrideWith(
            (ref) => ThemePreferenceNotifier(_SettingsStorage()),
          ),
          languageProvider.overrideWith(
            (ref) => LanguageNotifier(_SettingsStorage(language: 'en')),
          ),
        ],
        child: const _LocalizedMaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: SettingsSection())),
        ),
      ),
    );

    expect(find.text('알림 설정'), findsNothing);
    expect(find.text('화면 테마'), findsOneWidget);

    await tester.tap(find.text('언어'));
    await tester.pumpAndSettle();

    expect(find.text('시스템 언어'), findsOneWidget);
    expect(find.text('한국어'), findsOneWidget);
    expect(find.text('English'), findsWidgets);
    expect(find.byType(RadioListTile<AppLocalePreference>), findsNWidgets(3));
  });

  testWidgets('AI coach shows offline mode and hides chips after asking', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proxyClientConfigProvider.overrideWithValue(ProxyClientConfig()),
        ],
        child: const _LocalizedMaterialApp(home: ChatScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('오프라인 모드'), findsOneWidget);
    expect(find.text('운동 추천해줘'), findsOneWidget);

    await tester.tap(find.text('운동 추천해줘'));
    await tester.pumpAndSettle();

    expect(find.text('오프라인 기본 답변'), findsOneWidget);
    expect(find.text('수분 섭취 팁'), findsNothing);
  });
}

Future<void> _pumpDashboardApp(WidgetTester tester, {Locale? locale}) async {
  await tester.binding.setSurfaceSize(const Size(420, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  StatefulShellBranch branch(String path, Widget child) {
    return StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (context, state) => child)],
    );
  }

  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            MainScaffold(navigationShell: shell),
        branches: [
          branch('/dashboard', const DashboardScreen()),
          branch('/meals', const _RouteStub(label: '리포트 화면')),
          branch('/chat', const _RouteStub(label: 'AI 코치 화면')),
          branch('/profile', const _RouteStub(label: '프로필 화면')),
        ],
      ),
      GoRoute(
        path: '/add-meal',
        builder: (context, state) => const _RouteStub(label: '식단 추가'),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userProfileProvider.overrideWith(
          (ref) => UserProfileNotifier(_ProfileStorage(_onboardedProfile())),
        ),
        mealRecordsProvider.overrideWith(
          (ref) => MealRecordsNotifier(_MealStorage()),
        ),
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(_LanguageStorage(locale)),
        ),
        proxyClientConfigProvider.overrideWithValue(ProxyClientConfig()),
        dailyHealthProvider.overrideWith(
          (ref) => DailyHealthNotifier(_HealthStorage()),
        ),
      ],
      child: MaterialApp.router(
        locale: locale ?? const Locale('ko'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> _pumpMealSheetHost(
  WidgetTester tester, {
  required MealRecordsNotifier notifier,
  required MealRecord meal,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [mealRecordsProvider.overrideWith((ref) => notifier)],
      child: _LocalizedMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showMealRecordSheet(context, meal),
                child: const Text('기록 열기'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('기록 열기'));
  await tester.pumpAndSettle();
}

MealRecord _sheetTestMeal() {
  return MealRecord(
    id: 'sheet_meal',
    date: DateTime(2026, 7, 13, 12, 30),
    mealType: MealType.lunch,
    name: '김치찌개',
    calories: 600,
    carbs: 40,
    protein: 30,
    fat: 20,
  );
}

class _InMemoryMealStorage extends LocalStorageService {
  _InMemoryMealStorage(this._records);

  List<Map<String, dynamic>> _records;

  @override
  List<Map<String, dynamic>> getMealRecords() => _records;

  @override
  Future<void> saveMealRecords(List<Map<String, dynamic>> records) async {
    _records = records;
  }
}

class _LocalizedMaterialApp extends StatelessWidget {
  const _LocalizedMaterialApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ko'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    );
  }
}

class _RouteStub extends StatelessWidget {
  const _RouteStub({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}

UserProfile _onboardedProfile() {
  return UserProfile(
    name: '테스트 사용자',
    age: 30,
    height: 165,
    startingWeight: 68,
    currentWeight: 68,
    targetWeight: 68,
    gender: 'female',
    dailyCalorieGoal: 1800,
    dailyWaterGoalMl: 2000,
    dailyStepGoal: 9000,
    wellnessGoal: WellnessGoal.skinHealth,
    activityLevel: ActivityLevel.moderate,
    onboardingCompleted: true,
    onboardedAt: DateTime(2026, 6, 27),
  );
}

class _ProfileStorage extends LocalStorageService {
  _ProfileStorage(this.profile);

  final UserProfile profile;

  @override
  Map<String, dynamic>? getUserProfile() => profile.toJson();

  @override
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {}
}

class _MealStorage extends LocalStorageService {
  @override
  List<Map<String, dynamic>> getMealRecords() => const [];

  @override
  Future<void> saveMealRecords(List<Map<String, dynamic>> records) async {}
}

class _HealthStorage extends LocalStorageService {
  @override
  Map<String, dynamic>? getDailyHealthFor(DateTime date) => null;

  @override
  Future<void> saveDailyHealth(Map<String, dynamic> health) async {}
}

class _LanguageStorage extends LocalStorageService {
  _LanguageStorage(this.locale);

  final Locale? locale;

  @override
  T? getSetting<T>(String key) {
    if (key != 'app_locale_preference') return null;
    final value = locale?.languageCode == 'en' ? 'en' : 'ko';
    return value as T;
  }

  @override
  Future<void> saveSetting(String key, dynamic value) async {}
}

class _SettingsStorage extends LocalStorageService {
  _SettingsStorage({this.language});

  final String? language;

  @override
  T? getSetting<T>(String key) {
    if (key == 'app_locale_preference') return language as T?;
    return null;
  }

  @override
  Future<void> saveSetting(String key, dynamic value) async {}
}
