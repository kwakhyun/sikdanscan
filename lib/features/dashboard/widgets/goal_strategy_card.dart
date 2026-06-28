import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_svg_icon.dart';
import '../../meal/providers/meal_providers.dart';
import '../providers/meal_strategy_providers.dart';

class GoalStrategyCard extends ConsumerWidget {
  const GoalStrategyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategy = ref.watch(mealStrategyProvider);
    final meals = ref.watch(selectedDateMealsProvider);
    final accent = _colorFor(strategy.alertLevel);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final strategyMeta = isEnglish
        ? 'AI Strategy · ${meals.length} records reflected'
        : 'AI 전략 · ${meals.length}개 기록 반영';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AppSvgIcon(
                    strategy.goal.iconAsset,
                    color: accent,
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
                      strategyMeta,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: context.colorTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      strategy.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: context.colorTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (strategy.alertLevel != StrategyAlertLevel.empty)
                _ScoreBadge(score: strategy.score, color: accent),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 16, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strategy.primaryAction,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                      color: context.colorTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (strategy.actions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              strategy.actions.first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: context.colorTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _colorFor(StrategyAlertLevel level) {
    return switch (level) {
      StrategyAlertLevel.empty => AppColors.primary,
      StrategyAlertLevel.good => AppColors.success,
      StrategyAlertLevel.watch => AppColors.warning,
      StrategyAlertLevel.urgent => AppColors.error,
    };
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$score',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }
}
