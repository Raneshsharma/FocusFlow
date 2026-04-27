import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getEmoji(),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}