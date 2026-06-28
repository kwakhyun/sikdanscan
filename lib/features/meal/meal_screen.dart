import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/meal_record.dart';
import '../../l10n/app_localizations_context.dart';
import '../../providers/app_providers.dart';

class MealScreen extends ConsumerStatefulWidget {
  const MealScreen({super.key});

  @override
  ConsumerState<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends ConsumerState<MealScreen> {
  _ReportRange _range = _ReportRange.day;

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final allMeals = ref.watch(mealRecordsProvider);
    final profile = ref.watch(userProfileProvider);
    final period = _ReportPeriod.from(range: _range, anchorDate: selectedDate);
    final meals = _filterMealsByPeriod(allMeals, period);
    final summary = _ReportSummary.from(
      meals: meals,
      period: period,
      dailyCalorieGoal: profile.dailyCalorieGoal,
    );

    return Scaffold(
      backgroundColor: context.colorBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: SliverList.list(
                children: [
                  _ReportHeader(period: period),
                  const SizedBox(height: 14),
                  _RangeSelector(
                    selected: _range,
                    onChanged: (range) => setState(() => _range = range),
                  ),
                  const SizedBox(height: 12),
                  _PeriodNavigator(period: period, range: _range),
                  const SizedBox(height: 16),
                  _PeriodSummaryCard(summary: summary),
                  const SizedBox(height: 16),
                  _TrendCard(period: period, meals: meals),
                  const SizedBox(height: 16),
                  _RecordedFoodPanel(meals: meals, period: period),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ReportRange { day, week, month }

extension _ReportRangeText on _ReportRange {
  String labelOf(BuildContext context) {
    return switch (this) {
      _ReportRange.day => context.l10n.reportDay,
      _ReportRange.week => context.l10n.reportWeek,
      _ReportRange.month => context.l10n.reportMonth,
    };
  }
}

class _ReportPeriod {
  const _ReportPeriod({
    required this.range,
    required this.start,
    required this.end,
  });

  final _ReportRange range;
  final DateTime start;
  final DateTime end;

  int get dayCount => end.difference(start).inDays + 1;

  String titleOf(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return switch (range) {
      _ReportRange.day =>
        isEnglish ? _formatEnglishDate(start) : _formatKoreanDate(start),
      _ReportRange.week =>
        '${_formatShortDate(start, isEnglish: isEnglish)} - ${_formatShortDate(end, isEnglish: isEnglish)}',
      _ReportRange.month =>
        isEnglish
            ? '${_monthName(start.month)} ${start.year}'
            : '${start.year}년 ${start.month}월',
    };
  }

  String subtitleOf(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return switch (range) {
      _ReportRange.day => context.l10n.reportDailySubtitle,
      _ReportRange.week => context.l10n.reportWeeklySubtitle,
      _ReportRange.month =>
        isEnglish ? '$dayCount-day cumulative report' : '$dayCount일 누적 리포트',
    };
  }

  static _ReportPeriod from({
    required _ReportRange range,
    required DateTime anchorDate,
  }) {
    final day = DateTime(anchorDate.year, anchorDate.month, anchorDate.day);
    return switch (range) {
      _ReportRange.day => _ReportPeriod(range: range, start: day, end: day),
      _ReportRange.week => () {
        final start = day.subtract(Duration(days: day.weekday - 1));
        return _ReportPeriod(
          range: range,
          start: start,
          end: start.add(const Duration(days: 6)),
        );
      }(),
      _ReportRange.month => _ReportPeriod(
        range: range,
        start: DateTime(day.year, day.month),
        end: DateTime(day.year, day.month + 1, 0),
      ),
    };
  }
}

class _ReportSummary {
  const _ReportSummary({
    required this.meals,
    required this.period,
    required this.calorieGoal,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  final List<MealRecord> meals;
  final _ReportPeriod period;
  final int calorieGoal;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;

  int get dailyAverageCalories =>
      period.dayCount <= 0 ? calories : (calories / period.dayCount).round();
  int get remainingCalories => calorieGoal - calories;
  double get progress => calorieGoal <= 0 ? 0 : calories / calorieGoal;
  int get recordedDays => _groupMealsByDay(meals).length;

  factory _ReportSummary.from({
    required List<MealRecord> meals,
    required _ReportPeriod period,
    required int dailyCalorieGoal,
  }) {
    final calorieGoal = dailyCalorieGoal <= 0
        ? period.dayCount
        : dailyCalorieGoal * period.dayCount;
    return _ReportSummary(
      meals: meals,
      period: period,
      calorieGoal: calorieGoal,
      calories: meals.fold(0, (sum, meal) => sum + meal.calories),
      carbs: meals.fold(0.0, (sum, meal) => sum + meal.carbs),
      protein: meals.fold(0.0, (sum, meal) => sum + meal.protein),
      fat: meals.fold(0.0, (sum, meal) => sum + meal.fat),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.period});

  final _ReportPeriod period;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.reportTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: context.colorTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${period.range.labelOf(context)} · ${period.subtitleOf(context)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colorTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.colorPrimarySurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.insights_rounded, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onChanged});

  final _ReportRange selected;
  final ValueChanged<_ReportRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colorSurfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: _ReportRange.values.map((range) {
          final isSelected = range == selected;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(range),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected ? context.colorSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  range.labelOf(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? AppColors.primary
                        : context.colorTextSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PeriodNavigator extends ConsumerWidget {
  const _PeriodNavigator({required this.period, required this.range});

  final _ReportPeriod period;
  final _ReportRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final currentPeriod = _ReportPeriod.from(range: range, anchorDate: today);
    final isCurrent =
        _isSameDay(period.start, currentPeriod.start) &&
        _isSameDay(period.end, currentPeriod.end);

    return Row(
      children: [
        _PeriodNavButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => _move(ref, -1),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: period.start.isAfter(today) ? today : period.start,
                firstDate: today.subtract(const Duration(days: 365 * 2)),
                lastDate: today,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(
                        context,
                      ).colorScheme.copyWith(primary: AppColors.primary),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).state = picked;
              }
            },
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: Text(period.titleOf(context)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: context.colorBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _PeriodNavButton(
          icon: Icons.chevron_right_rounded,
          onTap: isCurrent ? null : () => _move(ref, 1),
        ),
        if (!isCurrent) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () =>
                ref.read(selectedDateProvider.notifier).state = today,
            child: Text(
              Localizations.localeOf(context).languageCode == 'en'
                  ? 'Today'
                  : '오늘',
            ),
          ),
        ],
      ],
    );
  }

  void _move(WidgetRef ref, int direction) {
    final delta = switch (range) {
      _ReportRange.day => Duration(days: direction),
      _ReportRange.week => Duration(days: 7 * direction),
      _ReportRange.month => null,
    };
    final next = range == _ReportRange.month
        ? DateTime(period.start.year, period.start.month + direction, 1)
        : period.start.add(delta!);
    ref.read(selectedDateProvider.notifier).state = next;
  }
}

class _PeriodNavButton extends StatelessWidget {
  const _PeriodNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: context.colorSurfaceVariant,
        foregroundColor: onTap == null
            ? context.colorTextTertiary
            : context.colorTextPrimary,
      ),
    );
  }
}

class _PeriodSummaryCard extends StatelessWidget {
  const _PeriodSummaryCard({required this.summary});

  final _ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final statusColor = summary.calories <= summary.calorieGoal
        ? AppColors.primary
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${summary.period.range.labelOf(context)} ${Localizations.localeOf(context).languageCode == 'en' ? 'summary' : '요약'}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: context.colorTextPrimary,
                  ),
                ),
              ),
              Text(
                Localizations.localeOf(context).languageCode == 'en'
                    ? '${summary.recordedDays}/${summary.period.dayCount} days logged'
                    : '${summary.recordedDays}/${summary.period.dayCount}일 기록',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: context.colorTextSecondary,
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
                  '${_formatInt(summary.calories)} kcal',
                  style: TextStyle(
                    fontSize: 32,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: context.colorTextPrimary,
                  ),
                ),
              ),
              Text(
                '${(summary.progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary.remainingCalories >= 0
                ? _periodGoalText(context, summary, over: false)
                : _periodGoalText(context, summary, over: true),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: summary.progress.clamp(0.0, 1.0),
              backgroundColor: context.colorSurfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: Localizations.localeOf(context).languageCode == 'en'
                      ? 'Daily avg'
                      : '일평균',
                  value: '${_formatInt(summary.dailyAverageCalories)} kcal',
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: context.l10n.dailyCarbs,
                  value: '${summary.carbs.toStringAsFixed(0)}g',
                  color: AppColors.chartCarbs,
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: context.l10n.dailyProtein,
                  value: '${summary.protein.toStringAsFixed(0)}g',
                  color: AppColors.chartProtein,
                ),
              ),
              Expanded(
                child: _SummaryMetric(
                  label: context.l10n.dailyFat,
                  value: '${summary.fat.toStringAsFixed(0)}g',
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
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.colorTextSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: context.colorTextPrimary,
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.period, required this.meals});

  final _ReportPeriod period;
  final List<MealRecord> meals;

  @override
  Widget build(BuildContext context) {
    final buckets = _buildDailyBuckets(context, period, meals);
    final maxCalories = buckets.fold<int>(
      0,
      (max, bucket) => bucket.calories > max ? bucket.calories : max,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period.range == _ReportRange.day
                ? (Localizations.localeOf(context).languageCode == 'en'
                      ? 'Hourly records'
                      : '시간별 기록')
                : (Localizations.localeOf(context).languageCode == 'en'
                      ? 'Daily trend'
                      : '일별 추이'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 148,
            child: buckets.isEmpty
                ? _EmptyReportState(
                    message:
                        Localizations.localeOf(context).languageCode == 'en'
                        ? 'No records to display'
                        : '표시할 기록이 없습니다',
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: buckets.map((bucket) {
                      final ratio = maxCalories <= 0
                          ? 0.0
                          : bucket.calories / maxCalories;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: _TrendBar(bucket: bucket, ratio: ratio),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DailyBucket {
  const _DailyBucket({
    required this.date,
    required this.label,
    required this.calories,
  });

  final DateTime date;
  final String label;
  final int calories;
}

class _TrendBar extends StatelessWidget {
  const _TrendBar({required this.bucket, required this.ratio});

  final _DailyBucket bucket;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 18,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              bucket.calories > 0
                  ? '${(bucket.calories / 1000).toStringAsFixed(1)}k'
                  : '-',
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: bucket.calories > 0
                    ? context.colorTextSecondary
                    : context.colorTextTertiary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barHeight = bucket.calories > 0
                  ? (18 +
                        ((constraints.maxHeight - 18) * ratio.clamp(0.0, 1.0)))
                  : 18.0;

              return Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: barHeight.clamp(18.0, constraints.maxHeight),
                  decoration: BoxDecoration(
                    color: bucket.calories > 0
                        ? AppColors.primary
                        : context.colorSurfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 18,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              bucket.label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: context.colorTextTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecordedFoodPanel extends StatelessWidget {
  const _RecordedFoodPanel({required this.meals, required this.period});

  final List<MealRecord> meals;
  final _ReportPeriod period;

  @override
  Widget build(BuildContext context) {
    final sorted = [...meals]..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  Localizations.localeOf(context).languageCode == 'en'
                      ? 'Recorded foods'
                      : '기록된 음식',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: context.colorTextPrimary,
                  ),
                ),
              ),
              Text(
                Localizations.localeOf(context).languageCode == 'en'
                    ? '${meals.length} items'
                    : '${meals.length}개',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: context.colorTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sorted.isEmpty)
            _EmptyReportState(
              message: Localizations.localeOf(context).languageCode == 'en'
                  ? 'Record your first food with a photo'
                  : '사진으로 첫 음식을 기록해보세요',
            )
          else
            ...sorted
                .take(12)
                .map(
                  (meal) => _FoodReportRow(
                    meal: meal,
                    showDate: period.range != _ReportRange.day,
                  ),
                ),
          if (sorted.length > 12) ...[
            const SizedBox(height: 8),
            Text(
              Localizations.localeOf(context).languageCode == 'en'
                  ? '+${sorted.length - 12} more records'
                  : '외 ${sorted.length - 12}개 기록',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: context.colorTextTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FoodReportRow extends StatelessWidget {
  const _FoodReportRow({required this.meal, required this.showDate});

  final MealRecord meal;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.colorPrimarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: context.colorTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _recordMeta(context, meal, showDate: showDate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.colorTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${meal.calories} kcal',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReportState extends StatelessWidget {
  const _EmptyReportState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: context.colorSurfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: context.colorTextTertiary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.colorTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

List<MealRecord> _filterMealsByPeriod(
  List<MealRecord> meals,
  _ReportPeriod period,
) {
  return meals.where((meal) {
    final date = DateTime(meal.date.year, meal.date.month, meal.date.day);
    return !date.isBefore(period.start) && !date.isAfter(period.end);
  }).toList();
}

Map<DateTime, List<MealRecord>> _groupMealsByDay(List<MealRecord> meals) {
  final groups = <DateTime, List<MealRecord>>{};
  for (final meal in meals) {
    final day = DateTime(meal.date.year, meal.date.month, meal.date.day);
    groups.putIfAbsent(day, () => []).add(meal);
  }
  return groups;
}

List<_DailyBucket> _buildDailyBuckets(
  BuildContext context,
  _ReportPeriod period,
  List<MealRecord> meals,
) {
  final isEnglish = Localizations.localeOf(context).languageCode == 'en';
  if (period.range == _ReportRange.day) {
    const slots = [0, 6, 12, 18];
    return slots.map((startHour) {
      final endHour = startHour + 6;
      final calories = meals
          .where(
            (meal) => meal.date.hour >= startHour && meal.date.hour < endHour,
          )
          .fold(0, (sum, meal) => sum + meal.calories);
      return _DailyBucket(
        date: period.start,
        label: isEnglish
            ? '${startHour.toString().padLeft(2, '0')}:00'
            : '${startHour.toString().padLeft(2, '0')}시',
        calories: calories,
      );
    }).toList();
  }

  final byDay = _groupMealsByDay(meals);
  return List.generate(period.dayCount, (index) {
    final date = period.start.add(Duration(days: index));
    final dayMeals = byDay[date] ?? const <MealRecord>[];
    final calories = dayMeals.fold(0, (sum, meal) => sum + meal.calories);
    return _DailyBucket(
      date: date,
      label: period.range == _ReportRange.week
          ? _weekdayShort(date, isEnglish: isEnglish)
          : date.day.toString(),
      calories: calories,
    );
  });
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatKoreanDate(DateTime date) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return '${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]})';
}

String _formatEnglishDate(DateTime date) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${_monthName(date.month)} ${date.day} (${weekdays[date.weekday - 1]})';
}

String _formatShortDate(DateTime date, {bool isEnglish = false}) {
  if (isEnglish) return '${date.month}/${date.day}';
  return '${date.month}/${date.day}';
}

String _weekdayShort(DateTime date, {bool isEnglish = false}) {
  if (isEnglish) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return weekdays[date.weekday - 1];
}

String _monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month.clamp(1, 12) - 1];
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _recordMeta(
  BuildContext context,
  MealRecord meal, {
  required bool showDate,
}) {
  final serving = meal.servingSize?.trim();
  final isEnglish = Localizations.localeOf(context).languageCode == 'en';
  final parts = [
    if (showDate) _formatShortDate(meal.date, isEnglish: isEnglish),
    _formatTime(meal.date),
    if (serving != null && serving.isNotEmpty) serving,
    isEnglish
        ? 'C ${meal.carbs.toStringAsFixed(0)}g · P ${meal.protein.toStringAsFixed(0)}g · F ${meal.fat.toStringAsFixed(0)}g'
        : '탄 ${meal.carbs.toStringAsFixed(0)}g · 단 ${meal.protein.toStringAsFixed(0)}g · 지 ${meal.fat.toStringAsFixed(0)}g',
  ];
  return parts.join(' · ');
}

String _periodGoalText(
  BuildContext context,
  _ReportSummary summary, {
  required bool over,
}) {
  final goal = _formatInt(summary.calorieGoal);
  final amount = _formatInt(summary.remainingCalories.abs());
  if (Localizations.localeOf(context).languageCode == 'en') {
    return over
        ? 'Period goal $goal kcal · $amount kcal over'
        : 'Period goal $goal kcal · $amount kcal left';
  }
  return over
      ? '기간 목표 $goal kcal · $amount kcal 초과'
      : '기간 목표 $goal kcal · $amount kcal 남음';
}

String _formatInt(int value) {
  final text = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(text[i]);
  }
  return value < 0 ? '-$buffer' : buffer.toString();
}
