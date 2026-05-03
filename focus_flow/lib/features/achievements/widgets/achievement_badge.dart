import 'package:flutter/material.dart';
import '../../../core/constants/achievements.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final AchievementDefinition definition;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final bool showDetails;
  final double size;

  const AchievementBadge({
    super.key,
    required this.definition,
    this.isUnlocked = false,
    this.unlockedAt,
    this.showDetails = true,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final color = getTierColor(definition.tier);

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? color.withOpacity(0.4) : AppColors.grey200,
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? color.withOpacity(0.15)
                    : AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isUnlocked
                    ? Text(
                        definition.icon,
                        style: const TextStyle(fontSize: 28),
                      )
                    : Text(
                        '🔒',
                        style: TextStyle(fontSize: 24, color: AppColors.grey400),
                      ),
              ),
            ),
            if (showDetails) ...[
              const SizedBox(height: 8),
              Text(
                definition.title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? AppColors.navy : AppColors.grey400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                _tierLabel(definition.tier),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: isUnlocked ? color : AppColors.grey400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? getTierColor(definition.tier).withOpacity(0.15)
                    : AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isUnlocked
                    ? Text(definition.icon, style: const TextStyle(fontSize: 40))
                    : Text('🔒', style: TextStyle(fontSize: 32, color: AppColors.grey400)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              definition.title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? getTierColor(definition.tier).withOpacity(0.15)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _tierLabel(definition.tier),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? getTierColor(definition.tier) : AppColors.grey500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              definition.description,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            if (unlockedAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Unlocked ${_formatDate(unlockedAt!)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.grey400,
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _tierLabel(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return 'Bronze';
      case AchievementTier.silver:
        return 'Silver';
      case AchievementTier.gold:
        return 'Gold';
      case AchievementTier.platinum:
        return 'Platinum';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}