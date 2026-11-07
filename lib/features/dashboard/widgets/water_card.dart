import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_card.dart';

/// One-tap hydration logging against the profile's daily water goal.
class WaterCard extends ConsumerWidget {
  const WaterCard({super.key});

  static const _glassMl = DailyHealthNotifier.glassMl;

  static Future<void> _guard(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.commonError;
    try {
      await action();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(dailyHealthProvider);
    final goal = ref.watch(userProfileProvider).dailyWaterGoalMl;
    final l10n = context.l10n;
    final locale = context.localeTag;
    final progress = goal <= 0 ? 0.0 : health.waterMl / goal;
    final notifier = ref.read(dailyHealthProvider.notifier);
    final amount = AppFormat.integer(health.waterMl, locale);
    final goalText = goal > 0 ? AppFormat.integer(goal, locale) : null;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.chartWater.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.water_drop_rounded,
              color: context.colorInfoText,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              container: true,
              label: goalText == null
                  ? l10n.waterSemanticsNoGoal(amount)
                  : l10n.waterSemantics(amount, goalText),
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.waterTitle,
                    style: AppTextStyles.micro.copyWith(
                      color: context.colorTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    goalText == null ? '$amount ml' : '$amount / $goalText ml',
                    style: AppTextStyles.metric.copyWith(
                      color: context.colorTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: context.colorSurfaceVariant,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.chartWater,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.outlined(
            tooltip: l10n.waterRemoveGlass,
            onPressed: health.waterMl <= 0
                ? null
                : () => _guard(context, () => notifier.removeWater(_glassMl)),
            icon: const Icon(Icons.remove_rounded),
          ),
          const SizedBox(width: 4),
          IconButton.filled(
            tooltip: l10n.waterAddGlass,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.infoText,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _guard(context, () => notifier.addWater(_glassMl)),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
