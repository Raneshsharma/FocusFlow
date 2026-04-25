import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TimeZonesScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const TimeZonesScreen({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final currentZone = _getCurrentZone();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Section title
              const Text(
                'Your energy changes throughout the day',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 6),

              // Section subtitle
              const Text(
                'Schedule tasks for when your brain is ready.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: AppColors.grey500,
                ),
              ),

              const SizedBox(height: 20),

              // Zone rows
              Expanded(
                child: ListView(
                  children: [
                    _ZoneRow(
                      label: 'Morning',
                      timeRange: '5 AM – 12 PM',
                      description: 'Usually your sharpest time. Tackle important tasks here.',
                      color: AppColors.zoneMorning,
                      isCurrentZone: currentZone == 'morning',
                    ),
                    const SizedBox(height: 10),
                    _ZoneRow(
                      label: 'Afternoon',
                      timeRange: '12 PM – 6 PM',
                      description: 'After-lunch dip is real. Save lighter work for here.',
                      color: AppColors.zoneAfternoon,
                      isCurrentZone: currentZone == 'afternoon',
                    ),
                    const SizedBox(height: 10),
                    _ZoneRow(
                      label: 'Evening',
                      timeRange: '6 PM – 12 AM',
                      description: 'Wind down. Easy tasks only — or save for tomorrow.',
                      color: AppColors.zoneEvening,
                      isCurrentZone: currentZone == 'evening',
                    ),
                    const SizedBox(height: 10),
                    const _AnytimeZoneRow(),
                  ],
                ),
              ),

              // Continue button
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrentZone() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 18) return 'afternoon';
    return 'evening';
  }
}

class _ZoneRow extends StatelessWidget {
  final String label;
  final String timeRange;
  final String description;
  final Color color;
  final bool isCurrentZone;

  const _ZoneRow({
    required this.label,
    required this.timeRange,
    required this.description,
    required this.color,
    required this.isCurrentZone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Colored dot
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                      if (isCurrentZone) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.green100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NOW',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    timeRange,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey400,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
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

class _AnytimeZoneRow extends StatelessWidget {
  const _AnytimeZoneRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.teal50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.tealBorder,
          width: 1.5,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anytime',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'No pressure. Works whenever you have a moment.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '✨ Flexible',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}