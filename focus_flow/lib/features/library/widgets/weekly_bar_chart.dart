import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/providers.dart';

class WeeklyBarChart extends ConsumerWidget {
  final Function(String day, int minutes)? onBarTap;

  const WeeklyBarChart({super.key, this.onBarTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsRepositoryProvider);

    return statsAsync.when(
      data: (repo) {
        final dailyStats = _getLastSevenDaysStats(repo);
        final maxMinutes = dailyStats.fold<int>(
          0,
          (max, stat) => stat.minutes > max ? stat.minutes : max,
        );

        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxMinutes > 0 ? maxMinutes : 60).toDouble(),
              barTouchData: BarTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  if (event.isInterestedForInteractions &&
                      response != null &&
                      response.spot != null) {
                    final index = response.spot!.touchedBarGroupIndex;
                    if (index >= 0 && index < dailyStats.length) {
                      onBarTap?.call(
                        dailyStats[index].label,
                        dailyStats[index].minutes,
                      );
                    }
                  }
                },
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: AppColors.navy,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${dailyStats[groupIndex].minutes} min',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < dailyStats.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dailyStats[index].label,
                            style: TextStyle(
                              color: dailyStats[index].isToday
                                  ? AppColors.teal
                                  : AppColors.grey600,
                              fontWeight: dailyStats[index].isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: TextStyle(
                          color: AppColors.grey600,
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
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 15,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.grey200,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: dailyStats.asMap().entries.map((entry) {
                final index = entry.key;
                final stat = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: stat.minutes.toDouble(),
                      color: stat.isToday ? AppColors.teal : AppColors.teal.withOpacity(0.6),
                      width: 24,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  List<_DayStat> _getLastSevenDaysStats(dynamic repo) {
    final now = DateTime.now();
    final days = <_DayStat>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final isToday = i == 0;
      final dayLabel = _getDayLabel(date, isToday);

      // Get stats for this day using getByDate
      int minutes = 0;
      try {
        final dailyData = repo.getByDate(date);
        if (dailyData != null) {
          minutes = dailyData.focusMinutes;
        }
      } catch (e) {
        // Use 0 if not available
      }

      days.add(_DayStat(
        date: date,
        label: dayLabel,
        minutes: minutes,
        isToday: isToday,
      ));
    }

    return days;
  }

  String _getDayLabel(DateTime date, bool isToday) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (isToday) return 'Today';
    return weekdays[date.weekday - 1];
  }
}

class _DayStat {
  final DateTime date;
  final String label;
  final int minutes;
  final bool isToday;

  _DayStat({
    required this.date,
    required this.label,
    required this.minutes,
    required this.isToday,
  });
}
