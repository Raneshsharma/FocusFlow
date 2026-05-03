import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MicroBreakCard extends StatelessWidget {
  final String icon;
  final String title;
  final String duration;
  final Color color;
  final VoidCallback? onTap;

  const MicroBreakCard({
    super.key,
    required this.icon,
    required this.title,
    required this.duration,
    required this.color,
    this.onTap,
  });

  String _getEmoji() {
    switch (icon) {
      case 'coffee':
        return '☕';
      case 'walk':
        return '🚶';
      case 'visibility_off':
        return '👀';
      case 'accessibility':
        return '🧘';
      case 'water_drop':
        return '💧';
      case 'spa':
        return '🌿';
      default:
        return '✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji container - fixed size for alignment
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getEmoji(),
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Title - centered, fixed width
            SizedBox(
              width: 80,
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Duration
            Text(
              duration,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
