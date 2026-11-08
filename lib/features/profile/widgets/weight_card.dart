import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/weight_record.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/sheet_handle.dart';

/// Body-weight log: latest value, change since start, recent trend and a
/// quick entry. Logging also updates the profile so BMI and the calorie
/// recommendation follow the real weight.
class WeightCard extends ConsumerWidget {
  const WeightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(weightRecordsProvider);
    final profile = ref.watch(userProfileProvider);
    final current = ref.watch(currentWeightProvider);
    final l10n = context.l10n;
    final locale = context.localeTag;
    final start = profile.goalStartWeight;
    final delta = current - start;
    final latest = records.isNotEmpty ? records.last : null;

    return AppCard(
      onTap: records.isEmpty ? null : () => _showHistory(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.weightTitle,
                  style: AppTextStyles.section.copyWith(
                    color: context.colorTextPrimary,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => showWeightEntryDialog(context, ref),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.weightLog),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Wraps under the value at large text sizes instead of overflowing.
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 10,
            runSpacing: 2,
            children: [
              Text(
                current > 0 ? '${AppFormat.decimal(current)} kg' : '-',
                style: AppTextStyles.display.copyWith(
                  color: context.colorTextPrimary,
                  fontSize: 28,
                ),
              ),
              if (current > 0 && start > 0 && delta.abs() >= 0.05)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    l10n.weightDeltaFromStart(
                      '${delta > 0 ? '+' : ''}${AppFormat.decimal(delta)}',
                    ),
                    style: AppTextStyles.label.copyWith(
                      color: context.colorTextSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            latest == null
                ? l10n.weightNoRecords
                : l10n.weightLastLogged(
                    AppFormat.mediumDate(latest.date, locale),
                  ),
            style: AppTextStyles.caption.copyWith(
              color: context.colorTextSecondary,
            ),
          ),
          if (records.length >= 2) ...[
            const SizedBox(height: 14),
            Semantics(
              label: l10n.weightTrendSemantics(records.length),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: CustomPaint(
                  painter: _SparklinePainter(
                    values: records
                        .skip(math.max(0, records.length - 14))
                        .map((r) => r.weight)
                        .toList(),
                    target: profile.targetWeight > 0
                        ? profile.targetWeight
                        : null,
                    lineColor: context.colorPrimaryText,
                    targetColor: context.colorTextTertiary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _WeightHistorySheet(),
    );
  }
}

/// Opens the weight entry dialog and logs the value.
Future<void> showWeightEntryDialog(BuildContext context, WidgetRef ref) async {
  final current = ref.read(currentWeightProvider);
  final weight = await showDialog<double>(
    context: context,
    builder: (_) => _WeightEntryDialog(initialWeight: current),
  );
  if (weight == null || !context.mounted) return;
  await logWeight(context, ref, weight);
}

/// Owns its text controller, so it is disposed only after the dialog's exit
/// animation has finished.
class _WeightEntryDialog extends StatefulWidget {
  const _WeightEntryDialog({required this.initialWeight});

  final double initialWeight;

  @override
  State<_WeightEntryDialog> createState() => _WeightEntryDialogState();
}

class _WeightEntryDialogState extends State<_WeightEntryDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialWeight > 0
        ? AppFormat.decimal(widget.initialWeight)
        : '',
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_controller.text.trim());
    if (value == null || value < 30 || value > 250) {
      setState(() => _error = context.l10n.onboardingValidationWeight);
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.weightLogTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          suffixText: 'kg',
          errorText: _error,
          labelText: l10n.profileCurrentWeight,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.commonSave)),
      ],
    );
  }
}

/// Sets the profile weight (used for BMR, recommendations and protein
/// targets) to the latest logged weight. When the log becomes empty, the
/// weight goes back to what the profile had before this device's first log
/// entry (the account may hold a newer weight than the starting one), or
/// stays as it is when that is unknown. Skips the write when nothing changes.
Future<void> syncProfileWeightFromLog(ProviderContainer container) async {
  final records = container.read(weightRecordsProvider);
  final profile = container.read(userProfileProvider);
  final storage = container.read(localStorageServiceProvider);
  final weight = records.isNotEmpty
      ? records.last.weight
      : (storage.getWeightBaseline() ?? profile.currentWeight);
  if (weight <= 0 || (weight - profile.currentWeight).abs() < 0.001) return;
  await container.read(userProfileProvider.notifier).updateWeight(weight);
}

/// Saves a weight record, syncs the profile weight and, for people who
/// follow the recommended targets, offers to update them when the
/// recommendation changes noticeably. A custom calorie goal is left alone.
///
/// [previousRecommendation] / [previousWaterRecommendation] are the
/// recommendations before the change when the caller already updated the
/// profile (e.g. the edit sheet).
Future<void> logWeight(
  BuildContext context,
  WidgetRef ref,
  double weight, {
  int? previousRecommendation,
  int? previousWaterRecommendation,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final locale = context.localeTag;
  // The snackbar action can outlive the widget (e.g. a closed sheet).
  final container = ProviderScope.containerOf(context, listen: false);
  final before = container.read(userProfileProvider);
  final beforeCalories =
      previousRecommendation ?? before.recommendedDailyCalorieGoal;
  final beforeWater =
      previousWaterRecommendation ?? before.recommendedWaterGoalMl;
  if (container.read(weightRecordsProvider).isEmpty) {
    try {
      await container
          .read(localStorageServiceProvider)
          .setWeightBaseline(before.currentWeight);
    } catch (_) {}
  }

  await container
      .read(weightRecordsProvider.notifier)
      .addRecord(
        WeightRecord(
          id: const Uuid().v4(),
          date: DateTime.now(),
          weight: weight,
        ),
      );
  await syncProfileWeightFromLog(container);

  final profile = container.read(userProfileProvider);
  final recommended = profile.recommendedDailyCalorieGoal;
  final followsRecommendation =
      beforeCalories > 0 &&
      (profile.dailyCalorieGoal - beforeCalories).abs() < 50;
  if (followsRecommendation &&
      recommended > 0 &&
      (recommended - profile.dailyCalorieGoal).abs() >= 50) {
    final followsWater =
        beforeWater > 0 && (profile.dailyWaterGoalMl - beforeWater).abs() < 50;
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 8),
        content: Text(
          l10n.weightRecalculateSuggestion(
            AppFormat.integer(recommended, locale),
          ),
        ),
        action: SnackBarAction(
          label: l10n.weightRecalculateApply,
          onPressed: () {
            final latest = container.read(userProfileProvider);
            container
                .read(userProfileProvider.notifier)
                .updateProfile(
                  latest.copyWith(
                    dailyCalorieGoal: latest.recommendedDailyCalorieGoal,
                    dailyWaterGoalMl: followsWater
                        ? latest.recommendedWaterGoalMl
                        : latest.dailyWaterGoalMl,
                  ),
                );
          },
        ),
      ),
    );
  } else {
    messenger.showSnackBar(SnackBar(content: Text(l10n.weightLogged)));
  }
}

class _WeightHistorySheet extends ConsumerWidget {
  const _WeightHistorySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(weightRecordsProvider).reversed.toList();
    final l10n = context.l10n;
    final locale = context.localeTag;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const SheetHandle(),
          const SizedBox(height: 16),
          Text(
            l10n.weightHistoryTitle,
            style: AppTextStyles.title.copyWith(
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (final record in records)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${AppFormat.decimal(record.weight)} kg',
                style: AppTextStyles.bodyStrong.copyWith(
                  color: context.colorTextPrimary,
                ),
              ),
              subtitle: Text(
                '${AppFormat.mediumDate(record.date, locale)} · ${AppFormat.time(record.date)}',
                style: AppTextStyles.caption.copyWith(
                  color: context.colorTextSecondary,
                ),
              ),
              trailing: IconButton(
                tooltip: l10n.commonDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: context.colorTextTertiary,
                ),
                onPressed: () => _remove(context, ref, record),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    WeightRecord record,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    // The undo action can run after this sheet has closed.
    final container = ProviderScope.containerOf(context, listen: false);
    final notifier = container.read(weightRecordsProvider.notifier);
    await notifier.removeRecord(record.id);
    await syncProfileWeightFromLog(container);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.weightDeleted),
        action: SnackBarAction(
          label: l10n.commonUndo,
          onPressed: () async {
            await notifier.addRecord(record);
            await syncProfileWeightFromLog(container);
          },
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.target,
    required this.lineColor,
    required this.targetColor,
  });

  final List<double> values;
  final double? target;
  final Color lineColor;
  final Color targetColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final all = [...values, if (target != null) target!];
    var minV = all.reduce(math.min);
    var maxV = all.reduce(math.max);
    if ((maxV - minV).abs() < 0.5) {
      minV -= 0.5;
      maxV += 0.5;
    }
    double y(double v) =>
        size.height - 4 - (v - minV) / (maxV - minV) * (size.height - 8);
    final step = size.width / (values.length - 1);

    if (target != null) {
      final targetPaint = Paint()
        ..color = targetColor
        ..strokeWidth = 1;
      final ty = y(target!);
      for (var x = 0.0; x < size.width; x += 7) {
        canvas.drawLine(Offset(x, ty), Offset(x + 4, ty), targetPaint);
      }
    }

    final path = Path()..moveTo(0, y(values.first));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(step * i, y(values[i]));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(
      Offset(size.width, y(values.last)),
      3.5,
      Paint()..color = lineColor,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.target != target ||
        oldDelegate.lineColor != lineColor;
  }
}
