import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/stats_provider.dart';
import '../../../providers/gamification_provider.dart';

class StatsSection extends ConsumerWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayStats = ref.watch(todayStatsProvider);
    final streakState = ref.watch(enhancedStreakProvider);
    final gamState = ref.watch(gamificationProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Stats',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 16),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  iconEmoji: '⏱',
                  iconColor: AppColors.teal,
                  value: todayStats.when(
                    data: (s) => '${s?.focusMinutes ?? 0}',
                    loading: () => '-',
                    error: (_, __) => '0',
                  ),
                  label: 'Focus Minutes',
                  trend: null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  iconEmoji: '⭘',
                  iconColor: AppColors.success,
                  value: todayStats.when(
                    data: (s) => '${s?.tasksCompleted ?? 0}',
                    loading: () => '-',
                    error: (_, __) => '0',
                  ),
                  label: 'Tasks Done',
                  trend: null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  iconEmoji: '🔥',
                  iconColor: Colors.orange,
                  value: streakState.when(
                    data: (s) => '${s.currentStreak}',
                    loading: () => '-',
                    error: (_, __) => '0',
                  ),
                  label: 'Day Streak',
                  trend: null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  iconEmoji: '🏆',
                  iconColor: AppColors.purple,
                  value: todayStats.when(
                    data: (s) => '${s?.sessionsCompleted ?? 0}',
                    loading: () => '-',
                    error: (_, __) => '0',
                  ),
                  label: 'Sessions',
                  trend: null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Level progress
          gamState.when(
            data: (gam) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.purple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${gam.level}',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Level ${gam.level}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${gam.todayXp} XP today',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: gam.levelProgress,
                      backgroundColor: AppColors.grey300,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.purple),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gam.xpToNextLevel} XP to Level ${gam.level + 1}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String iconEmoji;
  final Color iconColor;
  final String value;
  final String label;
  final String? trend;

  const _StatCard({
    required this.iconEmoji,
    required this.iconColor,
    required this.value,
    required this.label,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(iconEmoji, style: TextStyle(fontSize: 18, color: iconColor)),
              if (trend != null) ...[
                const SizedBox(width: 4),
                Text(
                  trend == 'up' ? '↗' : '↘',
                  style: TextStyle(
                    fontSize: 14,
                    color: trend == 'up' ? AppColors.success : Colors.red,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}