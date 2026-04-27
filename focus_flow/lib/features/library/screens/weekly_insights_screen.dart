import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/utils/date_utils.dart' as utils;
import '../../../providers/providers.dart';
import '../../../providers/energy_insight_provider.dart';
import '../widgets/streak_hero_card.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/adhd_insight_card.dart';

class WeeklyInsightsScreen extends ConsumerWidget {
  const WeeklyInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Weekly Insights'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: AppIcon(AppIcons.share, size: 20),
            onPressed: () => _shareInsights(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statsRepositoryProvider);
          ref.invalidate(energyInsightProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak hero card
              StreakHeroCard(
                onShare: () => _shareInsights(context, ref),
              ),
              const SizedBox(height: 20),

              // Weekly bar chart
              const Text(
                'This Week',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              WeeklyBarChart(
                onBarTap: (day, minutes) {
                  _showDayDetails(context, day, minutes);
                },
              ),
              const SizedBox(height: 24),

              // ADHD insights
              const Text(
                'ADHD Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const AdhdInsightCard(),
              const SizedBox(height: 24),

              // Pro tip card
              _ProTipCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showDayDetails(BuildContext context, String day, int minutes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$day: $minutes focus minutes'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareInsights(BuildContext context, WidgetRef ref) async {
    final buffer = StringBuffer();
    buffer.writeln('FocusFlow Weekly Insights');
    buffer.writeln('======================');
    buffer.writeln('');

    // Add streak info
    buffer.writeln('🔥 Streak: Check the app for your current streak!');
    buffer.writeln('');

    // Copy to clipboard
    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insights copied to clipboard!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

class _ProTipCard extends StatelessWidget {
  static const _proTips = [
    'Break big tasks into 5-minute chunks to match ADHD attention spans.',
    'Use the "Two-Minine Rule" — if it takes less than 2 minutes, do it now.',
    'Time blind? Use a timer to create artificial urgency.',
    'Body doubling: work near someone, even virtually.',
    'The "Just Start" rule: commit to only 5 minutes of a task.',
    'Task fatigue? Switch to a different energy level task.',
    'Write it down to free up working memory.',
    'Schedule "nothing" time to prevent decision fatigue.',
    'Movement breaks help reset dopamine for focus.',
    'Celebrate small wins — your brain needs the reward.',
  ];

  @override
  Widget build(BuildContext context) {
    final tipIndex = DateTime.now().day % _proTips.length;
    final tip = _proTips[tipIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withOpacity(0.1),
            AppColors.teal.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.purple.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('💡', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pro Tip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tip,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
