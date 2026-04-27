import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/achievements.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/achievement.dart';
import '../../../providers/achievement_provider.dart';
import '../widgets/achievement_badge.dart';

class AchievementGalleryScreen extends ConsumerWidget {
  const AchievementGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);
    final definitions = ref.watch(achievementDefinitionsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Achievements',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        centerTitle: true,
      ),
      body: achievementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load achievements')),
        data: (unlockedAchievements) {
          final unlockedIds = unlockedAchievements.map((a) => a.definitionId).toSet();
          final unlockedMap = {for (var a in unlockedAchievements) a.definitionId: a};

          // Group by tier
          final tiers = [AchievementTier.bronze, AchievementTier.silver, AchievementTier.gold, AchievementTier.platinum];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Progress summary
              _buildProgressCard(unlockedIds.length, definitions.length),
              const SizedBox(height: 24),

              // Tiers
              for (final tier in tiers) ...[
                _buildTierSection(
                  context,
                  tier,
                  definitions.where((d) => d.tier == tier).toList(),
                  unlockedMap,
                ),
                const SizedBox(height: 20),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(int unlocked, int total) {
    final progress = total > 0 ? unlocked / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.purple, AppColors.purple.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Journey',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$unlocked of $total unlocked',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierSection(
    BuildContext context,
    AchievementTier tier,
    List<AchievementDefinition> definitions,
    Map<String, Achievement> unlockedMap,
  ) {
    final tierColor = getTierColor(tier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: tierColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _tierIcon(tier),
                  size: 14,
                  color: tierColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${tier.name[0].toUpperCase()}${tier.name.substring(1)}',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: tierColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: tierColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${definitions.where((d) => unlockedMap.containsKey(d.id)).length}/${definitions.length}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tierColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: definitions.map((def) {
            final achievement = unlockedMap[def.id];
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 3,
              child: AchievementBadge(
                definition: def,
                isUnlocked: achievement != null,
                unlockedAt: achievement?.unlockedAt,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _tierIcon(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return Icons.workspace_premium_outlined;
      case AchievementTier.silver:
        return Icons.looks_outlined;
      case AchievementTier.gold:
        return Icons.star_outline;
      case AchievementTier.platinum:
        return Icons.emoji_events_outlined;
    }
  }
}