import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/achievements.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/achievement.dart';
import '../../../services/overlay_service.dart';

class AchievementToast extends StatelessWidget {
  final AchievementDefinition definition;

  const AchievementToast({super.key, required this.definition});

  /// Legacy method using BuildContext directly
  static void show(BuildContext context, AchievementDefinition definition) {
    if (!context.mounted) return;

    late OverlayEntry entry;
    final overlay = Overlay.of(context);

    entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        left: 20,
        right: 20,
        child: AchievementToast(definition: definition)
            .animate(
              onComplete: (controller) => entry.remove(),
            )
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.3, end: 0, duration: 300.ms)
            .fadeOut(duration: 400.ms, delay: 3000.ms)
            .slideY(begin: 0, end: -0.3, duration: 400.ms, delay: 3300.ms),
      ),
    );

    overlay.insert(entry);
  }

  /// New method using OverlayService (recommended)
  static void showOverlay(OverlayService service, AchievementDefinition definition) {
    service.showOverlay(
      builder: (context) => Positioned(
        bottom: 80,
        left: 20,
        right: 20,
        child: AchievementToast(definition: definition)
            .animate(
              onComplete: (controller) {},
            )
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.3, end: 0, duration: 300.ms)
            .fadeOut(duration: 400.ms, delay: 3000.ms)
            .slideY(begin: 0, end: -0.3, duration: 400.ms, delay: 3300.ms),
      ),
      duration: 4.seconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = getTierColor(definition.tier);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(definition.icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Achievement Unlocked!',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    definition.title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    definition.description,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
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
