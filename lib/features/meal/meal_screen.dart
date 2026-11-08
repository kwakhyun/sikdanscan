import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/meal_record.dart';
import '../../l10n/app_localizations_context.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../dashboard/widgets/daily_intake_overview_card.dart';
import 'report_models.dart';
import 'widgets/meal_entry_sheet.dart';

/// Report tab: day / week / month intake, trend against the daily goal,
/// meal-type breakdown and the full list of records for the period.
class MealScreen extends ConsumerStatefulWidget {
  const MealScreen({super.key});

  @override
  ConsumerState<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends ConsumerState<MealScreen> {
  ReportRange _range = ReportRange.day;

  @override
  Widget build(BuildContext context) {
    final anchor = ref.watch(selectedDateProvider);
    final allMeals = ref.watch(mealRecordsProvider);
    final profile = ref.watch(userProfileProvider);
    final today = ref.watch(todayDateProvider);
    final period = ReportPeriod.from(range: _range, anchorDate: anchor);
    final meals = period.filter(allMeals);
    final summary = ReportSummary.from(
      meals: meals,
      period: period,
      dailyCalorieGoal: profile.dailyCalorieGoal,
      today: today,
    );
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colorBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: SliverList.list(
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.reportTitle,
                      style: AppTextStyles.headline.copyWith(
                        color: context.colorTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ReportRange>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: ReportRange.day,
                          label: Text(l10n.reportDay),
                        ),
                        ButtonSegment(
                          value: ReportRange.week,
                          label: Text(l10n.reportWeek),
                        ),
                        ButtonSegment(
                          value: ReportRange.month,
                          label: Text(l10n.reportMonth),
                        ),
                      ],
                      selected: {_range},
                      onSelectionChanged: (selection) =>
                          setState(() => _range = selection.first),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PeriodNavigator(period: period, today: today),
                  const SizedBox(height: 16),
                  _PeriodSummaryCard(summary: summary),
                  const SizedBox(height: 16),
                  if (_range == ReportRange.day)
                    _MealTypeBarsCard(meals: meals)
                  else
                    _TrendCard(
                      period: period,
                      meals: meals,
                      dailyGoal: profile.dailyCalorieGoal,
                      today: today,
                      onDaySelected: (day) {
                        ref.read(selectedDateProvider.notifier).state = day;
                        setState(() => _range = ReportRange.day);
                      },
                    ),
                  if (_range != ReportRange.day) ...[
                    const SizedBox(height: 16),
                    _MealTypeBreakdownCard(meals: meals),
                  ],
                  const SizedBox(height: 16),
                  _RecordedFoodPanel(
                    meals: meals,
                    period: period,
                    today: today,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodNavigator extends ConsumerWidget {
  const _PeriodNavigator({required this.period, required this.today});

  final ReportPeriod period;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isCurrent = period.isCurrent(today);
    final locale = context.localeTag;

    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: l10n.reportPrevious,
          onPressed: () => _step(ref, -1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final initial = period.start.isAfter(today)
                  ? today
                  : period.start;
              // The arrows can go further back than the picker's default
              // range; never let firstDate pass initialDate.
              final defaultFirst = DateTime(
                today.year - 2,
                today.month,
                today.day,
              );
              final picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: initial.isBefore(defaultFirst)
                    ? initial
                    : defaultFirst,
                lastDate: today,
              );
              if (picked != null) _setAnchor(ref, picked);
            },
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(_title(period, locale, today)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: l10n.reportNext,
          onPressed: isCurrent ? null : () => _step(ref, 1),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
        if (!isCurrent) ...[
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => _setAnchor(ref, today),
            child: Text(l10n.reportToday),
          ),
        ],
      ],
    );
  }

  /// Moves the anchor by one period, keeping the same weekday / day of
  /// month, so going back and forth returns to the same day and switching
  /// to the Day view does not jump to a Monday or the 1st. Landing in the
  /// current period selects today.
  void _step(WidgetRef ref, int direction) {
    final anchor = ref.read(selectedDateProvider).dateOnly;
    final next = switch (period.range) {
      ReportRange.day => DateTime(
        anchor.year,
        anchor.month,
        anchor.day + direction,
      ),
      ReportRange.week => DateTime(
        anchor.year,
        anchor.month,
        anchor.day + 7 * direction,
      ),
      ReportRange.month => () {
        final lastDay = DateTime(anchor.year, anchor.month + direction + 1, 0);
        return DateTime(
          lastDay.year,
          lastDay.month,
          anchor.day > lastDay.day ? lastDay.day : anchor.day,
        );
      }(),
    };
    final target = ReportPeriod.from(range: period.range, anchorDate: next);
    _setAnchor(ref, target.contains(today) ? today : next);
  }

  void _setAnchor(WidgetRef ref, DateTime date) {
    final today = ref.read(todayDateProvider);
    ref.read(selectedDateProvider.notifier).state = date.isAfter(today)
        ? today
        : date;
  }

  /// The year is shown only when the period is not (entirely) in this year.
  static String _title(ReportPeriod period, String locale, DateTime today) {
    final showYear =
        period.start.year != today.year || period.end.year != today.year;
    return switch (period.range) {
      ReportRange.day =>
        showYear
            ? AppFormat.mediumDateWithYear(period.start, locale)
            : AppFormat.mediumDate(period.start, locale),
      ReportRange.week =>
        showYear
            ? '${AppFormat.numericDateWithYear(period.start, locale)} – '
                  '${AppFormat.numericDateWithYear(period.end, locale)}'
            : '${AppFormat.shortDate(period.start)} – '
                  '${AppFormat.shortDate(period.end)}',
      ReportRange.month => AppFormat.monthYear(period.start, locale),
    };
  }
}

class _PeriodSummaryCard extends StatelessWidget {
  const _PeriodSummaryCard({required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeTag;
    final over = summary.calorieGoal > 0 && summary.remainingCalories < 0;
    final statusColor = over
        ? context.colorErrorText
        : context.colorPrimaryText;
    final goalText = AppFormat.integer(summary.calorieGoal, locale);
    final amountText = AppFormat.integer(
      summary.remainingCalories.abs(),
      locale,
    );
    final isDay = summary.period.range == ReportRange.day;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.reportSummaryTitle,
                  style: AppTextStyles.section.copyWith(
                    color: context.colorTextPrimary,
                  ),
                ),
              ),
              if (!isDay)
                Text(
                  l10n.reportLoggedDays(summary.recordedDays, summary.goalDays),
                  style: AppTextStyles.caption.copyWith(
                    color: context.colorTextSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  AppFormat.kcal(summary.calories, locale),
                  style: AppTextStyles.display.copyWith(
                    color: context.colorTextPrimary,
                  ),
                ),
              ),
              if (summary.calorieGoal > 0)
                Text(
                  '${(summary.progress * 100).round()}%',
                  style: AppTextStyles.title.copyWith(color: statusColor),
                ),
            ],
          ),
          if (summary.calorieGoal > 0) ...[
            const SizedBox(height: 8),
            Text(
              over
                  ? l10n.reportGoalOver(goalText, amountText)
                  : l10n.reportGoalLeft(goalText, amountText),
              style: AppTextStyles.label.copyWith(color: statusColor),
            ),
            if (!isDay && summary.goalDays < summary.period.dayCount)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  l10n.reportGoalElapsedNote(summary.goalDays),
                  style: AppTextStyles.micro.copyWith(
                    color: context.colorTextSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 9,
                value: summary.progress.clamp(0.0, 1.0),
                backgroundColor: context.colorSurfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  over ? AppColors.error : AppColors.chartBar,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              if (!isDay)
                Expanded(
                  child: _SummaryMetric(
                    label: l10n.reportDailyAverage,
                    value: AppFormat.kcal(summary.dailyAverageCalories, locale),
                  ),
                ),
              Expanded(
                child: _SummaryMetric(
                  label: l10n.dailyCarbs,
                  value: AppFormat.grams(summary.carbs),
                  color: AppColors.chartCarbs,
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: l10n.dailyProtein,
                  value: AppFormat.grams(summary.protein),
                  color: AppColors.chartProtein,
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: l10n.dailyFat,
                  value: AppFormat.grams(summary.fat),
                  color: AppColors.chartFat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (color != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.micro.copyWith(
                  color: context.colorTextSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.label.copyWith(
            color: context.colorTextPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// Day view: calories per meal type as horizontal bars.
class _MealTypeBarsCard extends StatelessWidget {
  const _MealTypeBarsCard({required this.meals});

  final List<MealRecord> meals;

  static const typeColors = {
    MealType.breakfast: AppColors.info,
    MealType.lunch: AppColors.chartBar,
    MealType.dinner: AppColors.accent,
    MealType.snack: AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeTag;
    final byType = {
      for (final type in MealType.values)
        type: meals
            .where((m) => m.mealType == type)
            .fold(0, (sum, m) => sum + m.calories),
    };
    final max = byType.values.fold(0, (a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reportMealTypeDayTitle,
            style: AppTextStyles.section.copyWith(
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 14),
          for (final type in MealType.values)
            Semantics(
              label:
                  '${type.labelOf(l10n)} ${AppFormat.kcal(byType[type]!, locale)}',
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(
                        type.labelOf(l10n),
                        style: AppTextStyles.label.copyWith(
                          color: context.colorTextPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 12,
                          value: max <= 0 ? 0 : byType[type]! / max,
                          backgroundColor: context.colorSurfaceVariant,
                          valueColor: AlwaysStoppedAnimation(typeColors[type]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 76,
                      child: Text(
                        byType[type]! > 0
                            ? AppFormat.kcal(byType[type]!, locale)
                            : '–',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.caption.copyWith(
                          color: context.colorTextSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Week / month view: one bar per day with the daily goal as a dashed line.
/// Bars above the goal use the warning color; tapping a bar opens that day.
class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.period,
    required this.meals,
    required this.dailyGoal,
    required this.today,
    required this.onDaySelected,
  });

  final ReportPeriod period;
  final List<MealRecord> meals;
  final int dailyGoal;
  final DateTime today;
  final ValueChanged<DateTime> onDaySelected;

  static const _chartHeight = 150.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeTag;
    final buckets = dailyCalories(period, meals);
    final maxCalories = buckets.fold<int>(
      dailyGoal,
      (max, bucket) => bucket.$2 > max ? bucket.$2 : max,
    );
    final isMonth = period.range == ReportRange.month;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.reportDailyTrend,
                  style: AppTextStyles.section.copyWith(
                    color: context.colorTextPrimary,
                  ),
                ),
              ),
              if (dailyGoal > 0)
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 2,
                      color: context.colorTextSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      l10n.reportGoalLine(AppFormat.integer(dailyGoal, locale)),
                      style: AppTextStyles.micro.copyWith(
                        color: context.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.reportTapDayHint,
            style: AppTextStyles.micro.copyWith(
              color: context.colorTextTertiary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: _chartHeight + 22,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final count = buckets.length;
                final slot = constraints.maxWidth / count;
                final barWidth = (slot * (isMonth ? 0.62 : 0.5)).clamp(
                  3.0,
                  26.0,
                );
                final goalY = maxCalories <= 0 || dailyGoal <= 0
                    ? null
                    : _chartHeight * (1 - dailyGoal / maxCalories);

                return Stack(
                  children: [
                    if (goalY != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: goalY,
                        child: CustomPaint(
                          size: Size(constraints.maxWidth, 1),
                          painter: _DashedLinePainter(
                            color: context.colorTextSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < count; i++)
                          _DayBar(
                            width: slot,
                            barWidth: barWidth,
                            chartHeight: _chartHeight,
                            day: buckets[i].$1,
                            calories: buckets[i].$2,
                            maxCalories: maxCalories,
                            overGoal:
                                dailyGoal > 0 && buckets[i].$2 > dailyGoal,
                            isFuture: buckets[i].$1.isAfter(today),
                            label: isMonth
                                ? (_showMonthLabel(buckets[i].$1, period)
                                      ? '${buckets[i].$1.day}'
                                      : '')
                                : AppFormat.weekdayShort(buckets[i].$1, locale),
                            semanticLabel: l10n.reportBarSemantics(
                              AppFormat.mediumDate(buckets[i].$1, locale),
                              AppFormat.kcal(buckets[i].$2, locale),
                            ),
                            onTap: buckets[i].$1.isAfter(today)
                                ? null
                                : () => onDaySelected(buckets[i].$1),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Labels the 1st, every 5th day and the last day, skipping a 5th that
  /// sits right next to the last day (30 / 31 would overlap).
  static bool _showMonthLabel(DateTime day, ReportPeriod period) {
    return day.day == 1 ||
        day.isSameDay(period.end) ||
        (day.day % 5 == 0 && period.end.day - day.day >= 3);
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.width,
    required this.barWidth,
    required this.chartHeight,
    required this.day,
    required this.calories,
    required this.maxCalories,
    required this.overGoal,
    required this.isFuture,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
  });

  final double width;
  final double barWidth;
  final double chartHeight;
  final DateTime day;
  final int calories;
  final int maxCalories;
  final bool overGoal;
  final bool isFuture;
  final String label;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ratio = maxCalories <= 0 ? 0.0 : calories / maxCalories;
    final height = calories > 0
        ? (chartHeight * ratio).clamp(4.0, chartHeight)
        : 3.0;
    final color = calories <= 0
        ? context.colorSurfaceVariant
        : overGoal
        ? AppColors.warning
        : AppColors.chartBar;

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: barWidth,
                height: height,
                decoration: BoxDecoration(
                  color: isFuture ? Colors.transparent : color,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              ),
              SizedBox(
                height: 22,
                // Day slots in the month view are narrower than a label;
                // let the label extend evenly past both sides of its bar.
                child: OverflowBox(
                  maxWidth: double.infinity,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.micro.copyWith(
                      color: context.colorTextSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    const dash = 4.0;
    const gap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset((x + dash).clamp(0, size.width), 0),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MealTypeBreakdownCard extends StatelessWidget {
  const _MealTypeBreakdownCard({required this.meals});

  final List<MealRecord> meals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reportMealTypeTitle,
            style: AppTextStyles.section.copyWith(
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 14),
          if (totalCalories <= 0)
            EmptyStateBox(
              icon: Icons.bar_chart_rounded,
              message: l10n.reportNoRecordsToShow,
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: MealType.values.map((type) {
                    final calories = meals
                        .where((meal) => meal.mealType == type)
                        .fold(0, (sum, meal) => sum + meal.calories);
                    if (calories <= 0) return const SizedBox.shrink();
                    return Expanded(
                      flex: calories,
                      child: Container(
                        color: _MealTypeBarsCard.typeColors[type],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...MealType.values.map((type) {
              final typeMeals = meals
                  .where((meal) => meal.mealType == type)
                  .toList();
              final calories = typeMeals.fold(
                0,
                (sum, meal) => sum + meal.calories,
              );
              return _MealTypeBreakdownRow(
                type: type,
                color: _MealTypeBarsCard.typeColors[type]!,
                calories: calories,
                count: typeMeals.length,
                share: totalCalories <= 0 ? 0 : calories / totalCalories,
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _MealTypeBreakdownRow extends StatelessWidget {
  const _MealTypeBreakdownRow({
    required this.type,
    required this.color,
    required this.calories,
    required this.count,
    required this.share,
  });

  final MealType type;
  final Color color;
  final int calories;
  final int count;
  final double share;

  @override
  Widget build(BuildContext context) {
    final hasRecords = count > 0;
    final l10n = context.l10n;
    final locale = context.localeTag;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: hasRecords ? color : context.colorSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(
              type.labelOf(l10n),
              style: AppTextStyles.label.copyWith(
                color: hasRecords
                    ? context.colorTextPrimary
                    : context.colorTextTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              hasRecords
                  ? '${AppFormat.kcal(calories, locale)} · ${l10n.reportMealTypeRecords(count)}'
                  : '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: context.colorTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            hasRecords ? '${(share * 100).round()}%' : '0%',
            style: AppTextStyles.label.copyWith(
              color: hasRecords
                  ? context.colorTextPrimary
                  : context.colorTextTertiary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// All records of the period, grouped by day. Long periods show the first
/// rows with a "show all" toggle instead of silently truncating.
class _RecordedFoodPanel extends ConsumerStatefulWidget {
  const _RecordedFoodPanel({
    required this.meals,
    required this.period,
    required this.today,
  });

  final List<MealRecord> meals;
  final ReportPeriod period;
  final DateTime today;

  @override
  ConsumerState<_RecordedFoodPanel> createState() => _RecordedFoodPanelState();
}

class _RecordedFoodPanelState extends ConsumerState<_RecordedFoodPanel> {
  static const _collapsedCount = 15;
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant _RecordedFoodPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period.start != widget.period.start ||
        oldWidget.period.range != widget.period.range) {
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeTag;
    final sorted = [...widget.meals]..sort((a, b) => b.date.compareTo(a.date));
    final visible = _expanded ? sorted : sorted.take(_collapsedCount).toList();
    final isDay = widget.period.range == ReportRange.day;
    final canAdd = isDay && !widget.period.start.isAfter(widget.today);

    final children = <Widget>[];
    DateTime? currentDay;
    for (final meal in visible) {
      final day = meal.date.dateOnly;
      if (!isDay && currentDay != day) {
        currentDay = day;
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Text(
              AppFormat.mediumDate(day, locale),
              style: AppTextStyles.micro.copyWith(
                color: context.colorTextSecondary,
              ),
            ),
          ),
        );
      }
      children.add(MealLogRow(meal: meal));
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.reportRecordedFoods,
                  style: AppTextStyles.section.copyWith(
                    color: context.colorTextPrimary,
                  ),
                ),
              ),
              Text(
                l10n.commonItemCount(sorted.length),
                style: AppTextStyles.caption.copyWith(
                  color: context.colorTextSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (sorted.isEmpty)
            EmptyStateBox(
              icon: Icons.no_meals_rounded,
              message: l10n.reportNoRecordsForPeriod,
              actionLabel: canAdd ? l10n.reportAddForDay : null,
              onAction: canAdd
                  ? () => showMealEntrySheet(
                      context,
                      ref,
                      date: widget.period.start,
                    )
                  : null,
            )
          else ...[
            ...children,
            if (sorted.length > _collapsedCount)
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                  label: Text(
                    _expanded
                        ? l10n.reportShowLess
                        : l10n.reportShowAll(sorted.length),
                  ),
                ),
              ),
            if (canAdd) ...[
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: () =>
                    showMealEntrySheet(context, ref, date: widget.period.start),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.reportAddForDay),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
