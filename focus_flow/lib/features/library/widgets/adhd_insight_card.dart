import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/energy_insight.dart';
import '../../../providers/energy_insight_provider.dart';

class AdhdInsightCard extends ConsumerWidget {
  const AdhdInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(energyInsightProvider);

    return insightsAsync.when(
      data: (insights) {
        if (insights.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: insights.map((insight) => _buildInsightTile(insight)).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => _buildEmptyState(),
    );
  }

  Widget _buildInsightTile(EnergyInsight insight) {
    IconData icon;
    Color color;

    if (insight.type == InsightType.peakTime) {
      icon = Icons.bolt;
      color = AppColors.energyQuick;
    } else if (insight.type == InsightType.energyPattern) {
      icon = Icons.psychology;
      color = AppColors.energyDeep;
    } else if (insight.type == InsightType.tip) {
      icon = Icons.lightbulb;
      color = AppColors.amber;
    } else {
      icon = Icons.info;
      color = AppColors.teal;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.body,
                  style: const TextStyle(
                    fontSize: 13,
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.insights,
            size: 48,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 12),
          Text(
            'Not enough data yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete more sessions to see personalized insights.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.grey500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
