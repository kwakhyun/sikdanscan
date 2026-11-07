import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_svg_icon.dart';
import '../../../shared/widgets/sheet_handle.dart';

/// Today's rule-based goal strategy. Tap for the score breakdown, all tips
/// and a shortcut to ask the AI coach.
class GoalStrategyCard extends ConsumerWidget {
  const GoalStrategyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategy = ref.watch(mealStrategyProvider);
    final meals = ref.watch(todayMealsProvider);
    final l10n = context.l10n;
    final colors = StrategyColors.of(context, strategy.alertLevel);
    final hasScore = strategy.alertLevel != StrategyAlertLevel.empty;

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: colors.fill.withValues(alpha: 0.35),
      semanticLabel: l10n.strategyOpenDetail,
      onTap: () => showStrategyDetailSheet(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.fill.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AppSvgIcon(
                    strategy.goal.iconAsset,
                    color: colors.text,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.strategyMetaLabel(meals.length),
                      style: AppTextStyles.micro.copyWith(
                        color: context.colorTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      strategy.title(l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.section.copyWith(
                        color: context.colorTextPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasScore) ...[
                const SizedBox(width: 8),
                ScoreBadge(score: strategy.score, colors: colors),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            strategy.summary(l10n),
            style: AppTextStyles.caption.copyWith(
              color: context.colorTextSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: BoxDecoration(
              color: colors.fill.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.restaurant_menu_rounded,
                  size: 16,
                  color: colors.text,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strategy.primaryAction(l10n),
                    style: AppTextStyles.label.copyWith(
                      color: context.colorTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.strategyOpenDetail,
                  style: AppTextStyles.micro.copyWith(
                    color: context.colorPrimaryText,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: context.colorPrimaryText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StrategyColors {
  const StrategyColors({required this.fill, required this.text});

  final Color fill;
  final Color text;

  static StrategyColors of(BuildContext context, StrategyAlertLevel level) {
    return switch (level) {
      StrategyAlertLevel.empty => StrategyColors(
        fill: AppColors.primary,
        text: context.colorPrimaryText,
      ),
      StrategyAlertLevel.good => StrategyColors(
        fill: AppColors.success,
        text: context.colorSuccessText,
      ),
      StrategyAlertLevel.watch => StrategyColors(
        fill: AppColors.warning,
        text: context.colorWarningText,
      ),
      StrategyAlertLevel.urgent => StrategyColors(
        fill: AppColors.error,
        text: context.colorErrorText,
      ),
    };
  }
}

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.score, required this.colors});

  final int score;
  final StrategyColors colors;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.strategyScoreSemantics(score),
      excludeSemantics: true,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: colors.fill.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$score',
            style: AppTextStyles.metric.copyWith(color: colors.text),
          ),
        ),
      ),
    );
  }
}

Future<void> showStrategyDetailSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => const _StrategyDetailSheet(),
  );
}

class _StrategyDetailSheet extends ConsumerWidget {
  const _StrategyDetailSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategy = ref.watch(mealStrategyProvider);
    final l10n = context.l10n;
    final colors = StrategyColors.of(context, strategy.alertLevel);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const SheetHandle(),
          const SizedBox(height: 16),
          Text(
            l10n.strategyDetailTitle,
            style: AppTextStyles.micro.copyWith(
              color: context.colorTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  strategy.title(l10n),
                  style: AppTextStyles.title.copyWith(
                    color: context.colorTextPrimary,
                  ),
                ),
              ),
              if (strategy.alertLevel != StrategyAlertLevel.empty)
                ScoreBadge(score: strategy.score, colors: colors),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            strategy.summary(l10n),
            style: AppTextStyles.body.copyWith(
              color: context.colorTextSecondary,
            ),
          ),
          const SizedBox(height: 18),
          _Heading(label: l10n.strategyNextMeal),
          const SizedBox(height: 6),
          Text(
            strategy.primaryAction(l10n),
            style: AppTextStyles.bodyStrong.copyWith(
              color: context.colorTextPrimary,
            ),
          ),
          if (strategy.actions.isNotEmpty) ...[
            const SizedBox(height: 18),
            _Heading(label: l10n.strategyTips),
            const SizedBox(height: 6),
            for (final action in strategy.actions)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: context.colorPrimaryText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action(l10n),
                        style: AppTextStyles.body.copyWith(
                          color: context.colorTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (strategy.factors.isNotEmpty) ...[
            const SizedBox(height: 18),
            _Heading(label: l10n.strategyScoreTitle),
            const SizedBox(height: 8),
            for (final factor in strategy.factors)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(
                      factor.isMet
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: factor.isMet
                          ? context.colorSuccessText
                          : context.colorWarningText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        factor.label(l10n),
                        style: AppTextStyles.label.copyWith(
                          color: context.colorTextPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${factor.earned} / ${factor.max}',
                      style: AppTextStyles.label.copyWith(
                        color: context.colorTextSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 14),
          Text(
            l10n.strategyRuleBasedNote,
            style: AppTextStyles.micro.copyWith(
              color: context.colorTextTertiary,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              final prompt = l10n.strategyAskCoachPrompt;
              final router = GoRouter.of(context);
              final chat = ref.read(chatMessagesProvider.notifier);
              Navigator.pop(context);
              chat.send(prompt);
              router.go(AppRoutes.chat);
            },
            icon: const Icon(Icons.smart_toy_rounded),
            label: Text(l10n.strategyAskCoach),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.label.copyWith(color: context.colorTextSecondary),
    );
  }
}
