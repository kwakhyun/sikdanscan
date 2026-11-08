import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/meal_record.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/meal_thumbnail.dart';
import '../../../shared/widgets/sheet_handle.dart';
import '../meal_review_screen.dart';
import '../providers/meal_providers.dart';

Future<void> showMealRecordSheet(BuildContext context, MealRecord meal) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MealRecordSheet(meal: meal),
  );
}

/// View and edit a saved record: name, nutrition, portion, meal type and
/// time. Deleting offers undo instead of a confirmation dialog.
class MealRecordSheet extends ConsumerStatefulWidget {
  const MealRecordSheet({super.key, required this.meal});

  final MealRecord meal;

  @override
  ConsumerState<MealRecordSheet> createState() => _MealRecordSheetState();
}

class _MealRecordSheetState extends ConsumerState<MealRecordSheet> {
  static const _portionOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  late final MealRecord _base = widget.meal.withPortion(1.0);
  late MealType _mealType = widget.meal.mealType;
  late DateTime _dateTime = widget.meal.date;
  late double _portion = widget.meal.effectivePortion;

  // Base (1×) nutrition, edited through the fields below.
  late double _baseCalories = _base.calories.toDouble();
  late double _baseCarbs = _base.carbs;
  late double _baseProtein = _base.protein;
  late double _baseFat = _base.fat;

  late final _name = TextEditingController(text: widget.meal.name);
  late final _kcal = TextEditingController();
  late final _carbs = TextEditingController();
  late final _protein = TextEditingController();
  late final _fat = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _syncFields();
  }

  @override
  void dispose() {
    _name.dispose();
    _kcal.dispose();
    _carbs.dispose();
    _protein.dispose();
    _fat.dispose();
    super.dispose();
  }

  int get _calories => (_baseCalories * _portion).round();

  void _syncFields() {
    _kcal.text = _calories.toString();
    _carbs.text = _format(_baseCarbs * _portion);
    _protein.text = _format(_baseProtein * _portion);
    _fat.text = _format(_baseFat * _portion);
  }

  static String _format(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  bool get _dirty {
    final meal = widget.meal;
    return _name.text.trim() != meal.name ||
        _mealType != meal.mealType ||
        _dateTime != meal.date ||
        _portion != meal.effectivePortion ||
        _calories != meal.calories ||
        (_baseCarbs * _portion - meal.carbs).abs() > 0.05 ||
        (_baseProtein * _portion - meal.protein).abs() > 0.05 ||
        (_baseFat * _portion - meal.fat).abs() > 0.05;
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final l10n = context.l10n;
    final locale = context.localeTag;

    return Container(
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MealThumbnail(
                  imageUrl: meal.imageUrl,
                  storagePath: meal.imageStoragePath,
                  size: 62,
                  radius: 14,
                  semanticLabel: meal.name,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _name,
                    style: AppTextStyles.title.copyWith(
                      color: context.colorTextPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.reviewNameHint,
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                IconButton(
                  tooltip: l10n.mealDetailDeleteTitle,
                  onPressed: _saving ? null : _delete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: context.colorErrorText,
                  ),
                ),
              ],
            ),
            if (meal.isAiRecognized || meal.servingSize?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  [
                    if (meal.isAiRecognized)
                      meal.recognitionConfidence == null
                          ? l10n.mealDetailAiRecognized
                          : l10n.reviewConfidence(
                              (meal.recognitionConfidence!.clamp(0.0, 1.0) *
                                      100)
                                  .round(),
                            ),
                    if (meal.servingSize?.isNotEmpty == true)
                      l10n.mealDetailServing(meal.servingSize!),
                  ].join(' · '),
                  style: AppTextStyles.caption.copyWith(
                    color: context.colorTextSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _NutritionField(
                    controller: _kcal,
                    label: 'kcal',
                    integer: true,
                    onChanged: (v) {
                      _baseCalories = v / _portion;
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _NutritionField(
                    controller: _carbs,
                    label: l10n.reviewCarbsLabel,
                    onChanged: (v) {
                      _baseCarbs = v / _portion;
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _NutritionField(
                    controller: _protein,
                    label: l10n.reviewProteinLabel,
                    onChanged: (v) {
                      _baseProtein = v / _portion;
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _NutritionField(
                    controller: _fat,
                    label: l10n.reviewFatLabel,
                    onChanged: (v) {
                      _baseFat = v / _portion;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel(label: l10n.mealDetailPortion),
            const SizedBox(height: 4),
            Text(
              l10n.mealDetailPortionHint,
              style: AppTextStyles.caption.copyWith(
                color: context.colorTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _portionOptions.map((option) {
                return ChoiceChip(
                  label: Text(portionLabel(option)),
                  selected: option == _portion,
                  onSelected: _saving
                      ? null
                      : (_) => setState(() {
                          _portion = option;
                          _syncFields();
                        }),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _SectionLabel(label: l10n.mealDetailMealType),
            const SizedBox(height: 8),
            MealTypeChips(
              selected: _mealType,
              enabled: !_saving,
              onSelected: (type) => setState(() => _mealType = type),
            ),
            const SizedBox(height: 18),
            _SectionLabel(label: l10n.reviewDateTime),
            const SizedBox(height: 8),
            DateTimeRow(
              value: _dateTime,
              locale: locale,
              enabled: !_saving,
              onChanged: (value) => setState(() => _dateTime = value),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _logAgain,
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: Text(l10n.mealDetailLogAgain),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving || !_dirty || _name.text.trim().isEmpty
                        ? null
                        : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                        : Text(l10n.commonSave),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  MealRecord _edited() {
    return widget.meal.copyWith(
      name: _name.text.trim(),
      mealType: _mealType,
      date: _dateTime,
      portion: _portion,
      calories: _calories,
      carbs: _baseCarbs * _portion,
      protein: _baseProtein * _portion,
      fat: _baseFat * _portion,
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _saving = true);
    try {
      await ref.read(mealRecordsProvider.notifier).updateMeal(_edited());
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(l10n.mealDetailUpdated)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonError)));
    }
  }

  /// Logs the same food again now (e.g. the same breakfast as yesterday).
  Future<void> _logAgain() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final now = DateTime.now();
    setState(() => _saving = true);
    try {
      await ref
          .read(mealRecordsProvider.notifier)
          .addMeal(
            _edited().copyWith(
              id: const Uuid().v4(),
              date: now,
              mealType: MealType.fromTime(now),
              imageStoragePath: null,
            ),
          );
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.mealDetailLoggedAgain)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonError)));
    }
  }

  Future<void> _delete() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final notifier = ref.read(mealRecordsProvider.notifier);
    final meal = widget.meal;
    setState(() => _saving = true);
    try {
      await notifier.removeMeal(meal.id);
      if (!mounted) return;
      Navigator.pop(context);
      messenger.hideCurrentSnackBar();
      final controller = messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.mealDetailDeleted),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.commonUndo,
            onPressed: () => notifier.restoreMeal(meal),
          ),
        ),
      );
      controller.closed.then((reason) {
        if (reason != SnackBarClosedReason.action) {
          notifier.finalizeRemoval(meal);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonError)));
    }
  }
}

class _NutritionField extends StatelessWidget {
  const _NutritionField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.integer = false,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<double> onChanged;
  final bool integer;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !integer),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          integer ? RegExp(r'[0-9]') : RegExp(r'[0-9.]'),
        ),
      ],
      textAlign: TextAlign.center,
      style: AppTextStyles.metric.copyWith(color: context.colorTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.fromLTRB(6, 14, 6, 10),
      ),
      onChanged: (value) => onChanged(double.tryParse(value) ?? 0),
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
      style: AppTextStyles.label.copyWith(color: context.colorTextSecondary),
    );
  }
}
