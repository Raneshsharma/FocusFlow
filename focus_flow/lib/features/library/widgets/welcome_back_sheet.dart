import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/streak_service.dart';

class WelcomeBackSheet extends StatelessWidget {
  final StreakResult streakResult;
  final VoidCallback? onDismiss;

  const WelcomeBackSheet({
    super.key,
    required this.streakResult,
    this.onDismiss,
  });

  static Future<StreakResult?> show(BuildContext context) async {
    final service = StreakService();
    final result = await service.checkStreakStatus();

    if (result.wasBroken || result.isGraceDay) {
      // ignore
    }

    return showModalBottomSheet<StreakResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => WelcomeBackSheet(streakResult: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
    final streak = streakResult.currentStreak;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Greeting and streak
                Text(
                  '$greeting! 👋',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 8),

                // Streak display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: streak > 0
                          ? [AppColors.amber.withOpacity(0.2), Colors.orange.withOpacity(0.1)]
                          : [AppColors.grey200, AppColors.grey100],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        streak > 0 ? '🔥' : '💤',
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            streak > 0 ? '$streak day${streak > 1 ? 's' : ''} streak' : 'No active streak',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: streak > 0 ? AppColors.grey700 : AppColors.grey600,
                            ),
                          ),
                          if (streakResult.wasBroken)
                            Text(
                              'Streak was reset',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey500,
                              ),
                            ),
                          if (streakResult.isGraceDay)
                            Text(
                              'Grace day - come back today!',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.amber,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 16),

                // Message based on streak state
                if (streakResult.wasBroken) ...[
                  Text(
                    'You were away for a bit — no worries!',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Every day is a fresh start.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (streakResult.isGraceDay) ...[
                  Text(
                    'Welcome back! Your streak is waiting.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete a session to keep your streak alive!',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.amber,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Text(
                    'Ready to continue your focus journey?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),

                // CTAs
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/insights');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.teal.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View Insights',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/focus');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Start Fresh',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, end: 0, duration: 400.ms).fadeIn();
  }
}