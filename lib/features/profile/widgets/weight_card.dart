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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                current > 0 ? '${AppFormat.decimal(current)} kg' : '-',
                style: AppTextStyles.display.copyWith(
                  color: context.colorTextPrimary,
                  fontSize: 28,
                ),
              ),
              const SizedBox(width: 10),
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
  final l10n = context.l10n;
  final current = ref.read(currentWeightProvider);
  final controller = TextEditingController(
    text: current > 0 ? AppFormat.decimal(current) : '',
  );
  String? error;

  final weight = await showDialog<double>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: Text(l10n.weightLogTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            suffixText: 'kg',
            errorText: error,
            labelText: l10n.profileCurrentWeight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value == null || value < 30 || value > 250) {
                setState(() => error = l10n.onboardingValidationWeight);
                return;
              }
              Navigator.pop(dialogContext, value);
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  if (weight == null || !context.mounted) return;
  await logWeight(context, ref, weight);
}

/// Saves a weight record, syncs the profile weight and offers to update the
/// calorie/water targets when the recommendation changes noticeably.
Future<void> logWeight(
  BuildContext context,
  WidgetRef ref,
  double weight,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final locale = context.localeTag;

  await ref
      .read(weightRecordsProvider.notifier)
      .addRecord(
        WeightRecord(
          id: const Uuid().v4(),
          date: DateTime.now(),
          weight: weight,
        ),
      );
  await ref.read(userProfileProvider.notifier).updateWeight(weight);

  final profile = ref.read(userProfileProvider);
  final recommended = profile.recommendedDailyCalorieGoal;
  if (recommended > 0 && (recommended - profile.dailyCalorieGoal).abs() >= 50) {
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
            final latest = ref.read(userProfileProvider);
            ref
                .read(userProfileProvider.notifier)
                .updateProfile(
                  latest.copyWith(
                    dailyCalorieGoal: latest.recommendedDailyCalorieGoal,
                    dailyWaterGoalMl: latest.recommendedWaterGoalMl,
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
    final notifier = ref.read(weightRecordsProvider.notifier);
    await notifier.removeRecord(record.id);
    final remaining = ref.read(weightRecordsProvider);
    if (remaining.isNotEmpty) {
      await ref
          .read(userProfileProvider.notifier)
          .updateWeight(remaining.last.weight);
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.weightDeleted),
        action: SnackBarAction(
          label: l10n.commonUndo,
          onPressed: () => notifier.addRecord(record),
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
