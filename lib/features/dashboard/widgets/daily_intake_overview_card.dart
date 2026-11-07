import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/meal_record.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/meal_thumbnail.dart';
import '../../meal/widgets/meal_entry_sheet.dart';
import '../../meal/widgets/meal_record_sheet.dart';

class DailyIntakeOverviewCard extends ConsumerWidget {
  const DailyIntakeOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(todayMealsProvider);
    final calories = ref.watch(todayCaloriesProvider);
    final macros = ref.watch(todayMacrosProvider);
    final profile = ref.watch(userProfileProvider);
    final l10n = context.l10n;
    final locale = context.localeTag;
    final calorieGoal = profile.dailyCalorieGoal <= 0
        ? 1
        : profile.dailyCalorieGoal;
    final progress = calories / calorieGoal;
    final remainingCalories = calorieGoal - calories;
    final status = IntakeStatus.from(
      context,
      progress: progress,
      hasMeals: meals.isNotEmpty,
      l10n: l10n,
    );

    final carbs = macros['carbs'] ?? 0;
    final protein = macros['protein'] ?? 0;
    final fat = macros['fat'] ?? 0;
    final macroCalories = (carbs * 4) + (protein * 4) + (fat * 9);
    final goalText = AppFormat.integer(calorieGoal, locale);
    final remainingText = remainingCalories >= 0
        ? l10n.dailyKcalLeft(
            goalText,
            AppFormat.integer(remainingCalories, locale),
          )
        : l10n.dailyKcalOver(
            goalText,
            AppFormat.integer(remainingCalories.abs(), locale),
          );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            container: true,
            label: l10n.dailyIntakeSemantics(
              AppFormat.integer(calories, locale),
              remainingText,
              status.label,
            ),
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppFormat.kcal(calories, locale),
                            style: AppTextStyles.display.copyWith(
                              color: context.colorTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            remainingText,
                            style: AppTextStyles.caption.copyWith(
                              color: context.colorTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: context.colorSurfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(status.fill),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _MacroRow(
            carbs: carbs,
            protein: protein,
            fat: fat,
            macroCalories: macroCalories,
          ),
          const SizedBox(height: 22),
          _TodayFoodLog(meals: meals),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final IntakeStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: status.fill.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 15, color: status.text),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: AppTextStyles.caption.copyWith(
              color: status.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.macroCalories,
  });

  final double carbs;
  final double protein;
  final double fat;
  final double macroCalories;

  @override
  Widget build(BuildContext context) {
    double share(double kcal) =>
        macroCalories <= 0 ? 0.0 : kcal / macroCalories;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dailyNutrition,
          style: AppTextStyles.label.copyWith(color: context.colorTextPrimary),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MacroTile(
                label: l10n.dailyCarbs,
                grams: carbs,
                ratio: share(carbs * 4),
                color: AppColors.chartCarbs,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MacroTile(
                label: l10n.dailyProtein,
                grams: protein,
                ratio: share(protein * 4),
                color: AppColors.chartProtein,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MacroTile(
                label: l10n.dailyFat,
                grams: fat,
                ratio: share(fat * 9),
                color: AppColors.chartFat,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.label,
    required this.grams,
    required this.ratio,
    required this.color,
  });

  final String label;
  final double grams;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = (ratio.clamp(0.0, 1.0) * 100).round();
    return Semantics(
      label: context.l10n.dailyMacroSemantics(
        label,
        grams.toStringAsFixed(0),
        percent,
      ),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.micro.copyWith(
              color: context.colorTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${AppFormat.grams(grams)} · $percent%',
            style: AppTextStyles.metric.copyWith(
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: context.colorSurfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayFoodLog extends ConsumerWidget {
  const _TodayFoodLog({required this.meals});

  final List<MealRecord> meals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sorted = [...meals]..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.dailyRecords,
                style: AppTextStyles.section.copyWith(
                  color: context.colorTextPrimary,
                ),
              ),
            ),
            Text(
              l10n.commonItemCount(meals.length),
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
            message: l10n.dailyNoRecords,
            actionLabel: l10n.dailyLogFirstMeal,
            onAction: () => showMealEntrySheet(context, ref),
          )
        else
          ...sorted.map((meal) => MealLogRow(meal: meal)),
      ],
    );
  }
}

/// Row for a saved meal (thumbnail, name, time/portion, macros, kcal).
/// Tapping opens the edit sheet.
class MealLogRow extends StatelessWidget {
  const MealLogRow({super.key, required this.meal, this.showDate = false});

  final MealRecord meal;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeTag;
    final serving = meal.servingSize?.trim();
    final meta = [
      if (showDate) AppFormat.shortDate(meal.date),
      AppFormat.time(meal.date),
      meal.mealType.labelOf(l10n),
      if (meal.effectivePortion != 1.0) '${meal.effectivePortion}×',
      if (serving != null && serving.isNotEmpty) serving,
    ].join(' · ');
    final macros = l10n.macroShort(
      meal.carbs.toStringAsFixed(0),
      meal.protein.toStringAsFixed(0),
      meal.fat.toStringAsFixed(0),
    );

    return InkWell(
      onTap: () => showMealRecordSheet(context, meal),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            MealThumbnail(
              imageUrl: meal.imageUrl,
              storagePath: meal.imageStoragePath,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (meal.isAiRecognized) ...[
                        _AiBadge(confidence: meal.recognitionConfidence),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          meal.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyStrong.copyWith(
                            color: context.colorTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.micro.copyWith(
                      color: context.colorTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    macros,
                    style: AppTextStyles.micro.copyWith(
                      color: context.colorTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppFormat.kcal(meal.calories, locale),
              style: AppTextStyles.label.copyWith(
                color: context.colorPrimaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.colorTextTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge({required this.confidence});

  final double? confidence;

  @override
  Widget build(BuildContext context) {
    final text = confidence == null
        ? 'AI'
        : 'AI ${(confidence!.clamp(0.0, 1.0) * 100).round()}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colorPrimarySurface,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: AppTextStyles.micro.copyWith(color: context.colorPrimaryText),
      ),
    );
  }
}

/// Calorie status: fill color for bars, text color (contrast-safe) for labels.
class IntakeStatus {
  const IntakeStatus({
    required this.label,
    required this.fill,
    required this.text,
    required this.icon,
  });

  final String label;
  final Color fill;
  final Color text;
  final IconData icon;

  factory IntakeStatus.from(
    BuildContext context, {
    required double progress,
    required bool hasMeals,
    required AppLocalizations l10n,
  }) {
    if (!hasMeals) {
      return IntakeStatus(
        label: l10n.dailyStatusNone,
        fill: context.colorTextTertiary,
        text: context.colorTextSecondary,
        icon: Icons.schedule_rounded,
      );
    }
    if (progress <= 0.8) {
      return IntakeStatus(
        label: l10n.dailyStatusRoom,
        fill: AppColors.info,
        text: context.colorInfoText,
        icon: Icons.trending_flat_rounded,
      );
    }
    if (progress <= 1.0) {
      return IntakeStatus(
        label: l10n.dailyStatusOnTrack,
        fill: AppColors.success,
        text: context.colorSuccessText,
        icon: Icons.check_circle_rounded,
      );
    }
    if (progress <= 1.15) {
      return IntakeStatus(
        label: l10n.dailyStatusCaution,
        fill: AppColors.warning,
        text: context.colorWarningText,
        icon: Icons.error_rounded,
      );
    }
    return IntakeStatus(
      label: l10n.dailyStatusOver,
      fill: AppColors.error,
      text: context.colorErrorText,
      icon: Icons.warning_rounded,
    );
  }
}
