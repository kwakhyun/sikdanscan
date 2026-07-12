import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/meal_record.dart';
import '../../../l10n/app_localizations_context.dart';
import '../providers/meal_providers.dart';

Future<void> showMealRecordSheet(BuildContext context, MealRecord meal) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MealRecordSheet(meal: meal),
  );
}

class MealRecordSheet extends ConsumerStatefulWidget {
  const MealRecordSheet({super.key, required this.meal});

  final MealRecord meal;

  @override
  ConsumerState<MealRecordSheet> createState() => _MealRecordSheetState();
}

class _MealRecordSheetState extends ConsumerState<MealRecordSheet> {
  static const _portionOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  late MealType _mealType = widget.meal.mealType;
  double _portion = 1.0;
  bool _saving = false;

  bool get _dirty => _mealType != widget.meal.mealType || _portion != 1.0;

  int get _scaledCalories => (widget.meal.calories * _portion).round();
  double get _scaledCarbs => widget.meal.carbs * _portion;
  double get _scaledProtein => widget.meal.protein * _portion;
  double get _scaledFat => widget.meal.fat * _portion;

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return Container(
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MealThumb(imagePath: meal.imageUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: context.colorTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _mealMeta(context, meal),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.colorTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.mealDetailDeleteTitle,
                  onPressed: _saving ? null : _confirmDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _NutritionPreview(
              calories: _scaledCalories,
              carbs: _scaledCarbs,
              protein: _scaledProtein,
              fat: _scaledFat,
              highlighted: _portion != 1.0,
            ),
            const SizedBox(height: 20),
            _SectionLabel(label: context.l10n.mealDetailMealType),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((type) {
                final selected = type == _mealType;
                return ChoiceChip(
                  label: Text(type.labelOf(context.l10n)),
                  selected: selected,
                  onSelected: _saving
                      ? null
                      : (_) => setState(() => _mealType = type),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : context.colorTextSecondary,
                  ),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected ? AppColors.primary : context.colorBorder,
                    ),
                  ),
                  backgroundColor: context.colorSurface,
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _SectionLabel(label: context.l10n.mealDetailPortion),
            const SizedBox(height: 4),
            Text(
              context.l10n.mealDetailPortionHint,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: context.colorTextTertiary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _portionOptions.map((option) {
                final selected = option == _portion;
                return ChoiceChip(
                  label: Text(_portionLabel(option)),
                  selected: selected,
                  onSelected: _saving
                      ? null
                      : (_) => setState(() => _portion = option),
                  selectedColor: AppColors.secondary,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : context.colorTextSecondary,
                  ),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected
                          ? AppColors.secondary
                          : context.colorBorder,
                    ),
                  ),
                  backgroundColor: context.colorSurface,
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving || !_dirty ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.4,
                  ),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        context.l10n.commonSave,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _portionLabel(double option) {
    final text = option == option.roundToDouble()
        ? option.toStringAsFixed(0)
        : option.toString();
    return '$text×';
  }

  Future<void> _save() async {
    final updated = widget.meal.copyWith(
      mealType: _mealType,
      calories: _scaledCalories,
      carbs: _scaledCarbs,
      protein: _scaledProtein,
      fat: _scaledFat,
    );

    setState(() => _saving = true);
    try {
      await ref.read(mealRecordsProvider.notifier).updateMeal(updated);
      if (!mounted) return;
      Navigator.pop(context);
      _showMessage(context.l10n.mealDetailUpdated);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(context.l10n.commonError);
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.mealDetailDeleteTitle),
        content: Text(l10n.mealDetailDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref.read(mealRecordsProvider.notifier).removeMeal(widget.meal.id);
      if (!mounted) return;
      Navigator.pop(context);
      _showMessage(context.l10n.mealDetailDeleted);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(context.l10n.commonError);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

String _mealMeta(BuildContext context, MealRecord meal) {
  final time =
      '${meal.date.hour.toString().padLeft(2, '0')}:${meal.date.minute.toString().padLeft(2, '0')}';
  final serving = meal.servingSize?.trim();
  final parts = [
    meal.mealType.labelOf(context.l10n),
    time,
    if (serving != null && serving.isNotEmpty) serving,
  ];
  return parts.join(' · ');
}

class _MealThumb extends StatelessWidget {
  const _MealThumb({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final hasImage =
        path != null && path.trim().isNotEmpty && File(path).existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 62,
        height: 62,
        color: context.colorSurfaceVariant,
        child: hasImage
            ? Image.file(File(path), fit: BoxFit.cover)
            : const Icon(
                Icons.restaurant_rounded,
                color: AppColors.primary,
                size: 26,
              ),
      ),
    );
  }
}

class _NutritionPreview extends StatelessWidget {
  const _NutritionPreview({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.highlighted,
  });

  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.secondary.withValues(alpha: 0.08)
            : context.colorSurfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? AppColors.secondary.withValues(alpha: 0.4)
              : context.colorBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _NutritionMetric(
              label: 'kcal',
              value: '$calories',
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: _NutritionMetric(
              label: context.l10n.dailyCarbs,
              value: '${carbs.toStringAsFixed(0)}g',
              color: AppColors.chartCarbs,
            ),
          ),
          Expanded(
            child: _NutritionMetric(
              label: context.l10n.dailyProtein,
              value: '${protein.toStringAsFixed(0)}g',
              color: AppColors.chartProtein,
            ),
          ),
          Expanded(
            child: _NutritionMetric(
              label: context.l10n.dailyFat,
              value: '${fat.toStringAsFixed(0)}g',
              color: AppColors.chartFat,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionMetric extends StatelessWidget {
  const _NutritionMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.colorTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: context.colorTextPrimary,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: context.colorTextSecondary,
      ),
    );
  }
}
