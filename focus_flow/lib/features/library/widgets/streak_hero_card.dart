import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/providers.dart';

class StreakHeroCard extends ConsumerWidget {
  final VoidCallback? onShare;

  const StreakHeroCard({super.key, this.onShare});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionRepositoryProvider);

    return sessionsAsync.when(
      data: (repo) {
        final sessions = repo.getAll();
        final streak = _calculateStreak(sessions);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.amber.withOpacity(0.15),
                AppColors.teal.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Flame icon and streak count - tight grouping
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Fire emoji in fixed-size container for alignment
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    child: const Text('🔥', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(width: 12),
                  // Streak number and label - tight unit
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$streak',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'day streak',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (streak >= 3) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "🔥 You're on fire!",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amber,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Share button - properly aligned
              if (onShare != null)
                GestureDetector(
                  onTap: onShare,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('📤', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text(
                          'Share Streak',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  int _calculateStreak(List<dynamic> sessions) {
    if (sessions.isEmpty) return 0;

    final completedDays = sessions
        .where((s) => s.completedAt != null)
        .map((s) {
          final dt = s.completedAt!;
          return DateTime(dt.year, dt.month, dt.day);
        })
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (completedDays.isEmpty) return 0;

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);

    if (completedDays.first != todayDate &&
        completedDays.first != yesterdayDate) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < completedDays.length - 1; i++) {
      final diff = completedDays[i].difference(completedDays[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}