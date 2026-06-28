import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sikdanscan/data/models/user_profile.dart';
import 'package:sikdanscan/data/services/local_storage_service.dart';
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
    expect(find.text('음식 촬영하기'), findsNothing);
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
