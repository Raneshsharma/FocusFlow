import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../providers/stats_provider.dart';

class DailySummary extends ConsumerWidget {
  const DailySummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayStats = ref.watch(todayStatsProvider);

    return Card(
      color: AppColors.teal.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppIcon(
                AppIcons.celebration,
                size: 28,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'You showed up today!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    todayStats.when(
                      data: (stats) => stats != null
                          ? '${stats.tasksCompleted} task${stats.tasksCompleted == 1 ? '' : 's'} completed'
                          : 'Start your day!',
                      loading: () => 'Loading...',
                      error: (_, __) => 'Start your day!',
                    ),
                    style: const TextStyle(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}