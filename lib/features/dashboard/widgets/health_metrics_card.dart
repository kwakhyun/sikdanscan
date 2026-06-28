import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';

class HealthMetricsCard extends ConsumerWidget {
  const HealthMetricsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(dailyHealthProvider);
    final profile = ref.watch(userProfileProvider);

    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            icon: Icons.water_drop_rounded,
            label: '수분 섭취',
            value: '${health.waterLiters.toStringAsFixed(1)}L',
            subValue:
                '/ ${(profile.dailyWaterGoalMl / 1000).toStringAsFixed(1)}L',
            progress: health.waterMl / profile.dailyWaterGoalMl,
            color: AppColors.chartWater,
            onTap: () => ref.read(dailyHealthProvider.notifier).addWater(250),
            onLongPress: () =>
                ref.read(dailyHealthProvider.notifier).removeWater(250),
            actionLabel: '+1잔',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricTile(
            icon: Icons.directions_walk_rounded,
            label: '걸음 수',
            value: _formatNumber(health.steps),
            subValue: '/ ${_formatNumber(profile.dailyStepGoal)}',
            progress: health.steps / profile.dailyStepGoal,
            color: AppColors.secondary,
            onTap: () => _showStepsDialog(context, ref),
            actionLabel: '입력',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricTile(
            icon: Icons.bedtime_rounded,
            label: '수면',
            value: '${health.sleepHours.toStringAsFixed(1)}h',
            subValue: '/ 8h',
            progress: health.sleepHours / 8,
            color: AppColors.accent,
            onTap: () => _showSleepDialog(context, ref),
            actionLabel: '입력',
          ),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  void _showStepsDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.directions_walk_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('걸음 수 입력'),
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '걸음 수를 입력하세요',
            suffixText: '걸음',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final steps = int.tryParse(controller.text);
              if (steps == null || steps < 0) return;
              ref.read(dailyHealthProvider.notifier).updateSteps(steps);
              Navigator.pop(ctx);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showSleepDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bedtime_rounded,
                color: AppColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('수면 시간 입력'),
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            hintText: '수면 시간을 입력하세요',
            suffixText: '시간',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final hours = double.tryParse(controller.text);
              if (hours == null || hours < 0 || hours > 24) return;
              ref.read(dailyHealthProvider.notifier).updateSleep(hours);
              Navigator.pop(ctx);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subValue;
  final double progress;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String actionLabel;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.subValue,
    required this.progress,
    required this.color,
    this.onTap,
    this.onLongPress,
    this.actionLabel = '+1잔',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colorBorder),
        ),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 32,
              lineWidth: 5,
              percent: progress.clamp(0, 1),
              center: Icon(icon, size: 20, color: color),
              progressColor: color,
              backgroundColor: color.withValues(alpha: 0.15),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1000,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.colorTextPrimary,
              ),
            ),
            Text(
              subValue,
              style: TextStyle(fontSize: 10, color: context.colorTextTertiary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: context.colorTextSecondary,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
