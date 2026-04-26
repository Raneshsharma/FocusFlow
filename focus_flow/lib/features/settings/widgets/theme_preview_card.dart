import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ThemePreviewCard extends StatelessWidget {
  final bool isDarkMode;
  final double fontScale;

  const ThemePreviewCard({
    super.key,
    required this.isDarkMode,
    this.fontScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDarkMode ? AppColors.charcoal : AppColors.white;
    final surface = isDarkMode ? AppColors.deepSlate : AppColors.surface;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final secondaryText = isDarkMode ? Colors.grey.shade400 : AppColors.textSecondary;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FocusFlow',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: (14 * fontScale).clamp(10, 18),
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '25:00',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: (12 * fontScale).clamp(8, 16),
                        color: AppColors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 8,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 20,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.teal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 40,
                        height: 6,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _swatch(isDarkMode ? AppColors.deepSlate : AppColors.surface),
                _swatch(AppColors.teal),
                _swatch(AppColors.amber),
                _swatch(isDarkMode ? AppColors.charcoal : AppColors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _swatch(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.grey300, width: 0.5),
      ),
    );
  }
}