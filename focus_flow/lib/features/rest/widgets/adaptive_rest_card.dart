import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/stats_provider.dart';

class AdaptiveRestCard extends ConsumerWidget {
  const AdaptiveRestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(todayStatsProvider);
    final hour = DateTime.now().hour;

    return statsAsync.when(
      data: (stats) {
        final recommendation = _getRecommendation(
          sessions: stats?.sessionsCompleted ?? 0,
          focusMinutes: stats?.focusMinutes ?? 0,
          currentHour: hour,
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                recommendation.color.withOpacity(0.15),
                recommendation.color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: recommendation.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: recommendation.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(recommendation.emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: recommendation.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        recommendation.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: recommendation.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.title,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recommendation.description,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                recommendation.icon,
                color: recommendation.color,
                size: 24,
              ),
            ],
          ),
        );
      },
      loading: () => _buildSkeleton(),
      error: (_, __) => _buildDefaultCard(),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.teal.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Text('🧘', style: TextStyle(fontSize: 32)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Take a mindful moment',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Start your first session to get personalized recommendations',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.grey500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _BreakRecommendation _getRecommendation({
    required int sessions,
    required int focusMinutes,
    required int currentHour,
  }) {
    // Heavy session day - needs deep recovery
    if (sessions >= 5 || focusMinutes >= 120) {
      if (currentHour >= 18) {
        return _BreakRecommendation(
          emoji: '🌙',
          label: 'WIND DOWN',
          title: 'Time to wind down',
          description: 'You\'ve had a productive day. Prepare for restful sleep.',
          color: Colors.indigo,
          icon: Icons.nightlight_round,
        );
      }
      return _BreakRecommendation(
        emoji: '🛋️',
        label: 'DEEP RECOVERY',
        title: 'You earned a real break',
        description: 'Multiple sessions today. Take it easy.',
        color: AppColors.purple,
        icon: Icons.weekend,
      );
    }

    // Moderate session - suggest engaging break
    if (sessions >= 2 || focusMinutes >= 30) {
      if (currentHour >= 14 && currentHour < 17) {
        return _BreakRecommendation(
          emoji: '🚶',
          label: 'GET MOVING',
          title: 'Take a walk',
          description: 'Break up the afternoon slump with fresh air.',
          color: Colors.green,
          icon: Icons.directions_walk,
        );
      }
      return _BreakRecommendation(
        emoji: '☕',
        label: 'RECHARGE',
        title: 'Coffee break',
        description: 'A short break to recharge between sessions.',
        color: Colors.brown,
        icon: Icons.coffee,
      );
    }

    // Light day - quick recovery
    if (sessions >= 1) {
      return _BreakRecommendation(
        emoji: '👀',
        label: 'REST YOUR EYES',
        title: 'Look away from the screen',
        description: 'Quick eye break to reduce strain.',
        color: Colors.blue,
        icon: Icons.visibility_off,
      );
    }

    // Early in day - energizing break
    if (currentHour < 10) {
      return _BreakRecommendation(
        emoji: '💧',
        label: 'HYDRATE',
        title: 'Start with water',
        description: 'Hydration first thing helps focus.',
        color: Colors.cyan,
        icon: Icons.water_drop,
      );
    }

    // Default
    return _BreakRecommendation(
      emoji: '🧘',
      label: 'MINDFUL MOMENT',
      title: 'Breathe and reset',
      description: 'A quick breathing exercise to center yourself.',
      color: AppColors.teal,
      icon: Icons.self_improvement,
    );
  }
}

class _BreakRecommendation {
  final String emoji;
  final String label;
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  const _BreakRecommendation({
    required this.emoji,
    required this.label,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });
}