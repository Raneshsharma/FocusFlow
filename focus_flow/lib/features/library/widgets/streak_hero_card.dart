import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/providers.dart';

class StreakHeroCard extends ConsumerWidget {
  final VoidCallback? onShare;

  const StreakHeroCard({super.key, this.onShare});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate streak from sessions
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
                AppColors.amber.withOpacity(0.2),
                AppColors.teal.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Flame icon and streak count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        streak == 1 ? 'day streak' : 'day streak',
                        style: TextStyle(
                          fontSize: 16,
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
                    color: AppColors.amber.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "🔥 You're on fire!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.amber,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Share button
              if (onShare != null)
                TextButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share Streak'),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  int _calculateStreak(List<dynamic> sessions) {
    if (sessions.isEmpty) return 0;

    // Get unique days with completed sessions, sorted descending
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

    // Check if today or yesterday has a session
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);

    if (completedDays.first != todayDate &&
        completedDays.first != yesterdayDate) {
      return 0; // Streak broken
    }

    // Count consecutive days
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
