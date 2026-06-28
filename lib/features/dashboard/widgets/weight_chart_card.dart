import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';

class WeightChartCard extends ConsumerWidget {
  const WeightChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(weightRecordsProvider);
    final recent = records.length > 30
        ? records.sublist(records.length - 30)
        : records;
    final profile = ref.watch(userProfileProvider);

    if (recent.isEmpty) return const SizedBox.shrink();

    final minWeight =
        recent.map((r) => r.weight).reduce((a, b) => a < b ? a : b) - 2;
    final maxWeight =
        recent.map((r) => r.weight).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colorPrimarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '체중 변화 추이',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.colorTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '목표 ${profile.targetWeight}kg',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${recent.last.weight}kg',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: context.colorTextPrimary,
                ),
              ),
              const SizedBox(width: 8),
              _buildTrend(recent),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: context.colorBorder, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: TextStyle(
                          color: context.colorTextTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (recent.length / 5).ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= recent.length) {
                          return const SizedBox();
                        }
                        return Text(
                          DateFormat('M/d').format(recent[idx].date),
                          style: TextStyle(
                            color: context.colorTextTertiary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (recent.length - 1).toDouble(),
                minY: minWeight,
                maxY: maxWeight,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, profile.targetWeight),
                      FlSpot(
                        (recent.length - 1).toDouble(),
                        profile.targetWeight,
                      ),
                    ],
                    isCurved: false,
                    color: AppColors.success.withValues(alpha: 0.5),
                    barWidth: 1,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                  LineChartBarData(
                    spots: List.generate(
                      recent.length,
                      (i) => FlSpot(i.toDouble(), recent[i].weight),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    gradient: AppColors.primaryGradient,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (index == recent.length - 1) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                          strokeColor: Colors.transparent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        if (spot.barIndex == 0) return null;
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}kg',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrend(List records) {
    if (records.length < 2) return const SizedBox();
    final diff = records.last.weight - records[records.length - 2].weight;
    final isDown = diff < 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDown
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDown ? Icons.trending_down_rounded : Icons.trending_up_rounded,
            size: 14,
            color: isDown ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 4),
          Text(
            '${diff.abs().toStringAsFixed(1)}kg',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDown ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
