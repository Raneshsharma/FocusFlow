import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Logo container - perfectly centered with fixed dimensions
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: AppIcon(
                AppIcons.checkCircle,
                color: AppColors.teal,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // App name
          const Text(
            'FocusFlow',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Version
          const Text(
            'Version 1.0.0',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: 12),
          // Tagline pill - consistent styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Made for ADHD brains',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
