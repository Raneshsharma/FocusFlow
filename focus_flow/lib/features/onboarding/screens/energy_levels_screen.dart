import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/enums.dart';

class EnergyLevelsScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const EnergyLevelsScreen({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= ResponsiveBreakpoints.tablet;
            final horizontalPadding = isTablet ? 48.0 : 24.0;
            final maxContentWidth = isTablet ? 600.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isTablet ? 48 : 32),

                      // Section title
                      Text(
                        'Not all tasks need the same brain',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: isTablet ? 26 : 22,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: AppColors.navy,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Section subtitle
                      Text(
                        'Learn to match tasks to your energy type.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isTablet ? 17 : 15,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                          color: AppColors.grey500,
                        ),
                      ),

                      SizedBox(height: isTablet ? 32 : 20),

                      // Energy cards
                      Expanded(
                        child: ListView(
                          children: [
                            _EnergyCard(
                              energy: EnergyLevel.quick,
                              icon: '⚡',
                              label: 'Quick Energy',
                              description: 'Short bursts, fast wins',
                              example: 'Like clearing emails or a 5-min call',
                              borderColor: AppColors.energyQuick,
                              iconSize: isTablet ? 28 : 22,
                            ),
                            SizedBox(height: isTablet ? 16 : 12),
                            _EnergyCard(
                              energy: EnergyLevel.deep,
                              icon: '🧠',
                              label: 'Deep Energy',
                              description: 'Complex thinking, full focus',
                              example: 'Like coding, writing, or planning',
                              borderColor: AppColors.energyDeep,
                              iconSize: isTablet ? 28 : 22,
                            ),
                            SizedBox(height: isTablet ? 16 : 12),
                            _EnergyCard(
                              energy: EnergyLevel.low,
                              icon: '🔋',
                              label: 'Low Energy',
                              description: 'Gentle tasks, minimal brain effort',
                              example: 'Like organizing files or reviewing',
                              borderColor: AppColors.energyLow,
                              iconSize: isTablet ? 28 : 22,
                            ),
                          ],
                        ),
                      ),

                      // Got it button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, isTablet ? 64 : 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Got it'),
                        ),
                      ),

                      SizedBox(height: isTablet ? 48 : 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EnergyCard extends StatelessWidget {
  final EnergyLevel energy;
  final String icon;
  final String label;
  final String description;
  final String example;
  final Color borderColor;
  final double iconSize;

  const _EnergyCard({
    required this.energy,
    required this.icon,
    required this.label,
    required this.description,
    required this.example,
    required this.borderColor,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: TextStyle(fontSize: iconSize)),
              ),
            ),
            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: borderColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    example,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: AppColors.grey500,
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