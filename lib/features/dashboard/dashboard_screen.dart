import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations_context.dart';
import '../../providers/app_providers.dart';
import '../meal/widgets/meal_entry_sheet.dart';
import 'widgets/daily_intake_overview_card.dart';
import 'widgets/goal_strategy_card.dart';
import 'widgets/water_card.dart';

/// Daily tab: today's goal strategy, intake, food log and hydration.
/// Always shows *today* (independent of the date picked in Report).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayDateProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colorBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              sliver: SliverList.list(
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.dailyOverviewTitle,
                      style: AppTextStyles.headline.copyWith(
                        color: context.colorTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppFormat.fullDate(today, context.localeTag),
                    style: AppTextStyles.label.copyWith(
                      color: context.colorTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const GoalStrategyCard(),
                  const SizedBox(height: 14),
                  const DailyIntakeOverviewCard(),
                  const SizedBox(height: 14),
                  const WaterCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'log-meal',
        onPressed: () => showMealEntrySheet(context, ref),
        tooltip: l10n.entrySheetTitle,
        icon: const Icon(Icons.add_a_photo_rounded),
        label: Text(
          l10n.dashboardLogMeal,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
