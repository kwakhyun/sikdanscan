import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/chat_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/meal/add_meal_screen.dart';
import '../../features/meal/meal_review_screen.dart';
import '../../features/meal/meal_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/providers/profile_providers.dart';
import '../../shared/widgets/main_scaffold.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  AppRoutes._();

  static const dashboard = '/dashboard';
  static const meals = '/meals';
  static const chat = '/chat';
  static const profile = '/profile';
  static const onboarding = '/onboarding';
  static const addMeal = '/add-meal';
  static const mealReview = '/meal-review';

  /// Search screen. [date] pre-selects the day the food is logged on and
  /// [append] adds the picked foods to the open review instead of starting a
  /// new one.
  static String addMealLocation({DateTime? date, bool append = false}) {
    final query = <String, String>{
      if (date != null) 'date': _dateParam(date),
      if (append) 'append': '1',
    };
    return Uri(
      path: addMeal,
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }

  static String _dateParam(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static DateTime? parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

/// Builds the app router. Onboarding is enforced with a redirect (instead of
/// navigating from inside `build`), so deep links and restarts land on the
/// right screen without a flash of the dashboard.
GoRouter buildAppRouter({
  required ValueListenable<bool> onboardingCompleted,
  String initialLocation = AppRoutes.dashboard,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey ?? rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: onboardingCompleted,
    redirect: (context, state) {
      final completed = onboardingCompleted.value;
      final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!completed && !atOnboarding) return AppRoutes.onboarding;
      if (completed && atOnboarding) return AppRoutes.dashboard;
      return null;
    },
    // OAuth callbacks (sikdanscan://auth/callback) and unknown links are
    // handled by Supabase; just return to the app home.
    onException: (context, state, router) {
      // OAuth callbacks belong to supabase_flutter; if one still reaches the
      // router, keep the user on the screen they started sign-in from.
      final uri = state.uri;
      final isAuthCallback = uri.host == 'auth' || uri.path == '/callback';
      if (isAuthCallback &&
          router.routerDelegate.currentConfiguration.isNotEmpty) {
        return;
      }
      router.go(AppRoutes.dashboard);
    },
    routes: [
      GoRoute(path: '/', redirect: (_, __) => AppRoutes.dashboard),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.meals,
                builder: (context, state) => const MealScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chat,
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.addMeal,
        builder: (context, state) => AddMealScreen(
          initialDate: AppRoutes.parseDate(state.uri.queryParameters['date']),
          appendToReview: state.uri.queryParameters['append'] == '1',
        ),
      ),
      GoRoute(
        path: AppRoutes.mealReview,
        builder: (context, state) => const MealReviewScreen(),
      ),
    ],
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ValueNotifier<bool>(
    ref.read(userProfileProvider).onboardingCompleted,
  );
  ref.listen<bool>(
    userProfileProvider.select((profile) => profile.onboardingCompleted),
    (_, next) => onboardingCompleted.value = next,
  );
  final router = buildAppRouter(onboardingCompleted: onboardingCompleted);
  ref.onDispose(() {
    router.dispose();
    onboardingCompleted.dispose();
  });
  return router;
});
