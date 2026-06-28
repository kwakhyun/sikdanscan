import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';

class CalorieRingCard extends ConsumerWidget {
  const CalorieRingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCalories = ref.watch(todayCaloriesProvider);
    final profile = ref.watch(userProfileProvider);
    final macros = ref.watch(todayMacrosProvider);
    final goal = profile.dailyCalorieGoal;
    final remaining = goal - totalCalories;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '오늘의 칼로리',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  remaining > 0 ? '${remaining}kcal 남음' : '목표 초과!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _CalorieRingPainter(
                progress: (totalCalories / goal).clamp(0.0, 1.0),
                carbsRatio:
                    macros['carbs']! /
                    (macros['carbs']! + macros['protein']! + macros['fat']!)
                        .clamp(1, double.infinity),
                proteinRatio:
                    macros['protein']! /
                    (macros['carbs']! + macros['protein']! + macros['fat']!)
                        .clamp(1, double.infinity),
                fatRatio:
                    macros['fat']! /
                    (macros['carbs']! + macros['protein']! + macros['fat']!)
                        .clamp(1, double.infinity),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalCalories',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/ $goal kcal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MacroChip(
                label: '탄수화물',
                value: '${macros['carbs']!.toStringAsFixed(0)}g',
                color: AppColors.chartCarbs,
              ),
              _MacroChip(
                label: '단백질',
                value: '${macros['protein']!.toStringAsFixed(0)}g',
                color: AppColors.chartProtein,
              ),
              _MacroChip(
                label: '지방',
                value: '${macros['fat']!.toStringAsFixed(0)}g',
                color: AppColors.chartFat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalorieRingPainter extends CustomPainter {
  final double progress;
  final double carbsRatio;
  final double proteinRatio;
  final double fatRatio;

  _CalorieRingPainter({
    required this.progress,
    required this.carbsRatio,
    required this.proteinRatio,
    required this.fatRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    const strokeWidth = 14.0;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    progressPaint.color = AppColors.chartCarbs;
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * carbsRatio,
      false,
      progressPaint,
    );

    progressPaint.color = AppColors.chartProtein;
    canvas.drawArc(
      rect,
      startAngle + sweepAngle * carbsRatio,
      sweepAngle * proteinRatio,
      false,
      progressPaint,
    );

    progressPaint.color = AppColors.chartFat;
    canvas.drawArc(
      rect,
      startAngle + sweepAngle * (carbsRatio + proteinRatio),
      sweepAngle * fatRatio,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
