import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../providers/providers.dart';

class WeeklyBarChart extends ConsumerWidget {
  final Function(String day, int minutes)? onBarTap;

  const WeeklyBarChart({super.key, this.onBarTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use todayStatsProvider which provides today's stats via TodayStatsNotifier
    // This ensures the stats are properly initialized and tracked
    final todayStatsAsync = ref.watch(todayStatsProvider);

    return todayStatsAsync.when(
      data: (todayStats) {
        // Get today's minutes from todayStats if available
        final todayMinutes = todayStats?.focusMinutes ?? 0;
        final todayCompleted = todayStats?.tasksCompleted ?? 0;
        final todaySessions = todayStats?.sessionsCompleted ?? 0;

        // Get last 7 days stats from the stats repository
        final statsAsync = ref.watch(statsRepositoryProvider);

        return statsAsync.when(
          data: (repo) {
            // Build stats for last 7 days - today uses the tracked stats
            final dailyStats = _getLastSevenDaysStats(repo, todayMinutes, todayCompleted, todaySessions);
            final maxMinutes = dailyStats.fold<int>(
              0,
              (max, stat) => stat.minutes > max ? stat.minutes : max,
            );

            return Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: dailyStats.every((s) => s.minutes == 0)
                  ? _buildEmptyState()
                  : BarChart(
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
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
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
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      dailyStats[index].label,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: dailyStats[index].isToday
                                            ? AppColors.teal
                                            : AppColors.grey600,
                                        fontWeight: dailyStats[index].isToday
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        fontSize: 11,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              reservedSize: 32,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 20,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: AppColors.grey500,
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
                          horizontalInterval: 20,
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
                                toY: stat.minutes > 0 ? stat.minutes.toDouble() : 4,
                                color: stat.isToday
                                    ? AppColors.teal
                                    : AppColors.teal.withOpacity(0.5),
                                width: 20,
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
          loading: () => Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => Container(
        height: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            '📊',
            style: TextStyle(fontSize: 40),
          ),
          SizedBox(height: 12),
          Text(
            'No activity this week',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Complete focus sessions to see your chart',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  List<_DayStat> _getLastSevenDaysStats(dynamic repo, int todayMinutes, int todayCompleted, int todaySessions) {
    final now = DateTime.now();
    final days = <_DayStat>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final isToday = i == 0;
      final dayLabel = _getDayLabel(date, isToday);

      int minutes = 0;
      try {
        final dailyData = repo.getByDate(date);
        if (dailyData != null) {
          // For today, use the tracked stats (todayMinutes) which are updated in real-time
          // For other days, use the stored data from the repository
          minutes = isToday ? todayMinutes : dailyData.focusMinutes;
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