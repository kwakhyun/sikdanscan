import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sikdanscan/data/models/meal_record.dart';
import 'package:sikdanscan/data/models/user_profile.dart';
import 'package:sikdanscan/data/services/local_storage_service.dart';
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
  testWidgets('First launch shows quick onboarding before dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _LocalizedMaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('식단스캔 시작하기'), findsOneWidget);
    expect(find.text('간편 가입하고 시작'), findsOneWidget);
    expect(find.text('Kakao'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('음식 촬영하기'), findsNothing);
  });

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

    await tester.tap(find.text('간편 가입하고 시작'));
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
    expect(tester.takeException(), isNull);
  });

  testWidgets('SikdanScan app smoke test - dashboard loads after onboarding', (
    WidgetTester tester,
  ) async {
    await _pumpDashboardApp(tester);

    expect(find.text('촬영'), findsOneWidget);
    expect(find.text('오늘 섭취 현황'), findsOneWidget);
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

  testWidgets('Dashboard prioritizes camera capture over calorie chart', (
    WidgetTester tester,
  ) async {
    await _pumpDashboardApp(tester);

    expect(find.text('촬영'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('오늘의 칼로리'), findsNothing);
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

  testWidgets('Meal record sheet updates meal type and portion', (
    WidgetTester tester,
  ) async {
    final meal = _sheetTestMeal();
    final notifier = MealRecordsNotifier(_InMemoryMealStorage([meal.toJson()]));

    await _pumpMealSheetHost(tester, notifier: notifier, meal: meal);

    expect(find.text('김치찌개'), findsOneWidget);

    await tester.tap(find.text('저녁'));
    await tester.pump();
    await tester.tap(find.text('0.5×'));
    await tester.pump();

    expect(find.text('300'), findsOneWidget);

    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    final updated = notifier.state.single;
    expect(updated.mealType, MealType.dinner);
    expect(updated.calories, 300);
    expect(updated.carbs, 20);
    expect(updated.protein, 15);
    expect(updated.fat, 10);
  });

  testWidgets('Meal record sheet deletes a record after confirmation', (
    WidgetTester tester,
  ) async {
    final meal = _sheetTestMeal();
    final notifier = MealRecordsNotifier(_InMemoryMealStorage([meal.toJson()]));

    await _pumpMealSheetHost(tester, notifier: notifier, meal: meal);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('기록 삭제'), findsOneWidget);

    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(notifier.state, isEmpty);
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
          notificationsEnabledProvider.overrideWith(
            (ref) => SettingsBoolNotifier(
              _SettingsStorage(),
              'notifications_enabled',
              true,
            ),
          ),
          darkModeProvider.overrideWith(
            (ref) =>
                SettingsBoolNotifier(_SettingsStorage(), 'dark_mode', false),
          ),
          languageProvider.overrideWith(
            (ref) => LanguageNotifier(_SettingsStorage(language: 'en')),
          ),
        ],
        child: const _LocalizedMaterialApp(
          home: Scaffold(body: SettingsSection()),
        ),
      ),
    );

    await tester.tap(find.text('언어'));
    await tester.pumpAndSettle();

    expect(find.text('시스템 언어'), findsOneWidget);
    expect(find.text('한국어'), findsOneWidget);
    expect(find.text('English'), findsWidgets);
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
  });
}

Future<void> _pumpDashboardApp(WidgetTester tester, {Locale? locale}) async {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/meals',
            builder: (context, state) => const _RouteStub(label: '리포트 화면'),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const _RouteStub(label: 'AI 코치 화면'),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const _RouteStub(label: '프로필 화면'),
          ),
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
    if (key == 'notifications_enabled') return true as T;
    if (key == 'dark_mode') return false as T;
    return null;
  }

  @override
  Future<void> saveSetting(String key, dynamic value) async {}
}
