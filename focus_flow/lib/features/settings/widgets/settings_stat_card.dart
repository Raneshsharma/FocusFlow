import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingsStatCard extends StatelessWidget {
  final String iconEmoji;
  final String value;
  final String label;
  final Color iconColor;

  const SettingsStatCard({
    super.key,
    required this.iconEmoji,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: iconColor.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji in fixed-size container for alignment
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(iconEmoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(height: 12),
          // Value - bold, consistent sizing
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: iconColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          // Label - consistent text style
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
}