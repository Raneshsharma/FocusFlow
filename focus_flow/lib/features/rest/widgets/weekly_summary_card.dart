import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/gamification_provider.dart';
import '../../../providers/stats_provider.dart';
import '../../../providers/achievement_provider.dart';

class WeeklySummaryCard extends ConsumerWidget {
  const WeeklySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamState = ref.watch(gamificationProvider);
    final statsAsync = ref.watch(todayStatsProvider);
    final streakState = ref.watch(enhancedStreakProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Summary',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => _shareSummary(context, ref),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('📤', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  emoji: '🎯',
                  value: statsAsync.when(
                    data: (s) => '${s?.tasksCompleted ?? 0}',
                    loading: () => '-',
                    error: (_, __) => '0',
                  ),
                  label: 'Tasks Done',
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  emoji: '⏱️',
                  value: statsAsync.when(
                    data: (s) => '${s?.focusMinutes ?? 0}',
                    loading: () => '-',
                    error: (_, __) => '0',
                  ),
                  label: 'Focus Min',
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  emoji: '🔥',
                  value: streakState.when(
                    data: (s) => '${s.currentStreak}',
                    loading: () => '-',
                    error: (_, __) => '0',
                  ),
                  label: 'Streak',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  emoji: '⭐',
                  value: gamState.when(
                    data: (g) => 'Lv ${g.level}',
                    loading: () => '-',
                    error: (_, __) => '1',
                  ),
                  label: 'Level',
                  color: AppColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Achievements this week
          gamState.when(
            data: (gam) {
              final achievements = gam.todayAchievements;
              if (achievements.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 10),
                      Text(
                        'No achievements this week yet',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 10),
                    Text(
                      '${achievements.length} achievement${achievements.length > 1 ? 's' : ''} this week',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String emoji,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareSummary(BuildContext context, WidgetRef ref) async {
    final gamState = ref.read(gamificationProvider);
    final statsAsync = ref.read(todayStatsProvider);
    final streakState = ref.read(enhancedStreakProvider);

    final gamData = gamState.value;
    final stats = statsAsync.value;
    final streak = streakState.value;

    final buffer = StringBuffer();
    buffer.writeln('FocusFlow Weekly Summary');
    buffer.writeln('========================');
    buffer.writeln();
    buffer.writeln('Tasks: ${stats?.tasksCompleted ?? 0}');
    buffer.writeln('Focus: ${stats?.focusMinutes ?? 0} min');
    buffer.writeln('Streak: ${streak?.currentStreak ?? 0} days');
    buffer.writeln('Level: ${gamData?.level ?? 1}');

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Summary copied!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
