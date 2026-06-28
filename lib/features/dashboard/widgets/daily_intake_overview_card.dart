import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/meal_record.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../providers/app_providers.dart';

class DailyIntakeOverviewCard extends ConsumerWidget {
  const DailyIntakeOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(selectedDateMealsProvider);
    final calories = ref.watch(todayCaloriesProvider);
    final macros = ref.watch(todayMacrosProvider);
    final profile = ref.watch(userProfileProvider);
    final calorieGoal = profile.dailyCalorieGoal <= 0
        ? 1
        : profile.dailyCalorieGoal;
    final progress = calories / calorieGoal;
    final remainingCalories = calorieGoal - calories;
    final status = _IntakeStatus.from(
      progress: progress,
      hasMeals: meals.isNotEmpty,
    );

    final carbs = macros['carbs'] ?? 0;
    final protein = macros['protein'] ?? 0;
    final fat = macros['fat'] ?? 0;
    final macroCalories = (carbs * 4) + (protein * 4) + (fat * 9);

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
          _Header(status: status),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _KcalSummary(
                  calories: calories,
                  calorieGoal: calorieGoal,
                  remainingCalories: remainingCalories,
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
              valueColor: AlwaysStoppedAnimation<Color>(status.color),
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

class _Header extends StatelessWidget {
  const _Header({required this.status});

  final _IntakeStatus status;

  @override
  Widget build(BuildContext context) {
    final today = _formatKoreanDate(DateTime.now());

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.dailyOverviewTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: context.colorTextPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                today,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.colorTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Icon(status.icon, color: status.color, size: 24),
      ],
    );
  }
}

class _KcalSummary extends StatelessWidget {
  const _KcalSummary({
    required this.calories,
    required this.calorieGoal,
    required this.remainingCalories,
  });

  final int calories;
  final int calorieGoal;
  final int remainingCalories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_formatInt(calories)} kcal',
          style: TextStyle(
            fontSize: 34,
            height: 1,
            fontWeight: FontWeight.w900,
            color: context.colorTextPrimary,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          remainingCalories >= 0
              ? '${context.l10n.profileDailyGoal} ${_formatInt(calorieGoal)} kcal · ${_formatInt(remainingCalories)} kcal ${Localizations.localeOf(context).languageCode == 'en' ? 'left' : '남음'}'
              : '${context.l10n.profileDailyGoal} ${_formatInt(calorieGoal)} kcal · ${_formatInt(remainingCalories.abs())} kcal ${Localizations.localeOf(context).languageCode == 'en' ? 'over' : '초과'}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.colorTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _IntakeStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
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
    final carbsRatio = macroCalories <= 0 ? 0.0 : (carbs * 4) / macroCalories;
    final proteinRatio = macroCalories <= 0
        ? 0.0
        : (protein * 4) / macroCalories;
    final fatRatio = macroCalories <= 0 ? 0.0 : (fat * 9) / macroCalories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.dailyNutrition,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: context.colorTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MacroTile(
                label: context.l10n.dailyCarbs,
                grams: carbs,
                ratio: carbsRatio,
                color: AppColors.chartCarbs,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MacroTile(
                label: context.l10n.dailyProtein,
                grams: protein,
                ratio: proteinRatio,
                color: AppColors.chartProtein,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MacroTile(
                label: context.l10n.dailyFat,
                grams: fat,
                ratio: fatRatio,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.colorTextSecondary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${grams.toStringAsFixed(0)}g',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
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
    );
  }
}

class _TodayFoodLog extends StatelessWidget {
  const _TodayFoodLog({required this.meals});

  final List<MealRecord> meals;

  @override
  Widget build(BuildContext context) {
    final visibleMeals = [...meals]..sort((a, b) => b.date.compareTo(a.date));
    final displayedMeals = visibleMeals.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.dailyRecords,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: context.colorTextPrimary,
                ),
              ),
            ),
            Text(
              Localizations.localeOf(context).languageCode == 'en'
                  ? '${meals.length}'
                  : '${meals.length}개',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: context.colorTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (displayedMeals.isEmpty)
          _EmptyFoodLog()
        else ...[
          ...displayedMeals.map((meal) => _FoodLogRow(meal: meal)),
          if (meals.length > displayedMeals.length)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                Localizations.localeOf(context).languageCode == 'en'
                    ? '${meals.length - displayedMeals.length} more records'
                    : '외 ${meals.length - displayedMeals.length}개 기록',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colorTextTertiary,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _FoodLogRow extends StatelessWidget {
  const _FoodLogRow({required this.meal});

  final MealRecord meal;

  @override
  Widget build(BuildContext context) {
    final hasImage = _hasUsableImage(meal.imageUrl);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _MealImageThumb(meal: meal, hasImage: hasImage),
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: context.colorTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _mealMeta(meal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.colorTextTertiary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  Localizations.localeOf(context).languageCode == 'en'
                      ? 'C ${meal.carbs.toStringAsFixed(0)}g · P ${meal.protein.toStringAsFixed(0)}g · F ${meal.fat.toStringAsFixed(0)}g'
                      : '탄 ${meal.carbs.toStringAsFixed(0)}g · 단 ${meal.protein.toStringAsFixed(0)}g · 지 ${meal.fat.toStringAsFixed(0)}g',
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

class _MealImageThumb extends StatelessWidget {
  const _MealImageThumb({required this.meal, required this.hasImage});

  final MealRecord meal;
  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        color: context.colorSurfaceVariant,
        child: hasImage
            ? Image.file(File(meal.imageUrl!), fit: BoxFit.cover)
            : Center(
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
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
    final confidenceText = confidence == null
        ? 'AI'
        : 'AI ${(confidence!.clamp(0.0, 1.0) * 100).round()}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        confidenceText,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _EmptyFoodLog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: context.colorSurfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.no_meals_rounded,
            color: context.colorTextTertiary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.dailyNoRecords,
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

class _IntakeStatus {
  const _IntakeStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  factory _IntakeStatus.from({
    required double progress,
    required bool hasMeals,
  }) {
    if (!hasMeals) {
      return const _IntakeStatus(
        label: '기록 전',
        color: AppColors.textTertiary,
        icon: Icons.camera_alt_outlined,
      );
    }
    if (progress <= 0.8) {
      return const _IntakeStatus(
        label: '여유',
        color: AppColors.info,
        icon: Icons.trending_flat_rounded,
      );
    }
    if (progress <= 1.0) {
      return const _IntakeStatus(
        label: '적정',
        color: AppColors.success,
        icon: Icons.check_circle_rounded,
      );
    }
    if (progress <= 1.15) {
      return const _IntakeStatus(
        label: '주의',
        color: AppColors.warning,
        icon: Icons.error_rounded,
      );
    }
    return const _IntakeStatus(
      label: '초과',
      color: AppColors.error,
      icon: Icons.warning_rounded,
    );
  }
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

String _formatKoreanDate(DateTime date) {
  const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
  return '${date.month}월 ${date.day}일 ${weekdays[date.weekday - 1]}';
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _mealMeta(MealRecord meal) {
  final serving = meal.servingSize?.trim();
  final parts = [
    _formatTime(meal.date),
    if (serving != null && serving.isNotEmpty) serving,
  ];
  return parts.join(' · ');
}

bool _hasUsableImage(String? path) {
  if (path == null || path.trim().isEmpty) return false;
  try {
    return File(path).existsSync();
  } catch (_) {
    return false;
  }
}
