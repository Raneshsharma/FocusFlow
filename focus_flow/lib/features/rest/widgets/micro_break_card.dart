import 'package:flutter/material.dart';
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

  String _getIconPath() {
    switch (icon) {
      case 'coffee':
        return 'rest/micro_coffee';
      case 'walk':
        return 'rest/micro_walk';
      case 'visibility_off':
        return 'rest/micro_look_away';
      case 'accessibility':
        return 'rest/micro_stretch';
      case 'water_drop':
        return 'rest/micro_hydrate';
      case 'spa':
        return 'rest/micro_relax';
      default:
        return 'rest/micro_relax';
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: AppIcon(
                  _getIconPath(),
                  color: color,
                  size: 32,
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
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}