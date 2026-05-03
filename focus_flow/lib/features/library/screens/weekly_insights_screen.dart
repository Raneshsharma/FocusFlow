import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/providers.dart';
import '../../../providers/energy_insight_provider.dart';
import '../widgets/streak_hero_card.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/adhd_insight_card.dart';

class WeeklyInsightsScreen extends ConsumerWidget {
  const WeeklyInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Text('←', style: TextStyle(fontSize: 28, color: AppColors.navy, fontWeight: FontWeight.bold)),
          onPressed: () => context.go('/library'),
        ),
        title: const Text(
          'Weekly Insights',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statsRepositoryProvider);
          ref.invalidate(todayStatsProvider);
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
                onShare: () => _shareInsights(context),
              ),
              const SizedBox(height: 24),

              // Weekly bar chart
              const Text(
                'This Week',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
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
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 12),
              const AdhdInsightCard(),
              const SizedBox(height: 24),

              // Pro tip card
              const _ProTipCard(),
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

  void _shareInsights(BuildContext context) async {
    // Navigate to library and show share options there
    context.go('/library');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Go to Archive tab to share your streak!'),
        backgroundColor: AppColors.teal,
      ),
    );
  }
}

class _ProTipCard extends StatelessWidget {
  const _ProTipCard();

  static const _proTips = [
    'Break big tasks into 5-minute chunks to match ADHD attention spans.',
    'Use the "Two-Minite Rule" — if it takes less than 2 minutes, do it now.',
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
            AppColors.purple.withOpacity(0.08),
            AppColors.teal.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.purple.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lightbulb icon - perfectly centered
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('💡', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pro Tip',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tip,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}