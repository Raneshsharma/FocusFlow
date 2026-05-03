import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/overlay_service.dart';

class TaskCompletionCelebration extends StatefulWidget {
  final int xpEarned;
  final VoidCallback onDismiss;
  final String? taskTitle;

  const TaskCompletionCelebration({
    super.key,
    this.xpEarned = AppConstants.xpPerTask,
    required this.onDismiss,
    this.taskTitle,
  });

  static void show(
    BuildContext context, {
    int xpEarned = AppConstants.xpPerTask,
    String? taskTitle,
    Duration duration = const Duration(seconds: 2),
  }) {
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => TaskCompletionCelebration(
        xpEarned: xpEarned,
        taskTitle: taskTitle,
        onDismiss: () => entry.remove(),
      ),
    );

    Overlay.of(context).insert(entry);

    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  /// New method using OverlayService (recommended)
  static void showOverlay(
    OverlayService service, {
    int xpEarned = AppConstants.xpPerTask,
    String? taskTitle,
    Duration duration = const Duration(seconds: 3),
  }) {
    late VoidCallback dismissCallback;
    dismissCallback = () {
      service.hideOverlay();
    };

    service.showOverlay(
      builder: (context) => TaskCompletionCelebration(
        xpEarned: xpEarned,
        taskTitle: taskTitle,
        onDismiss: dismissCallback,
      ),
      duration: duration,
    );
  }

  @override
  State<TaskCompletionCelebration> createState() => _TaskCompletionCelebrationState();
}

class _TaskCompletionCelebrationState extends State<TaskCompletionCelebration> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1500));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent background
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ),

        // Center content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Confetti from top
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    AppColors.teal,
                    AppColors.amber,
                    AppColors.purple,
                    Colors.green,
                    Colors.orange,
                    Colors.pink,
                  ],
                  numberOfParticles: 30,
                  gravity: 0.2,
                  emissionFrequency: 0.05,
                  maxBlastForce: 20,
                  minBlastForce: 8,
                ),
              ),

              // Checkmark with animation
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Text(
                  '✓',
                  style: TextStyle(
                    fontSize: 56,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1.2, 1.2),
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1.0, 1.0),
                    duration: 200.ms,
                  ),

              const SizedBox(height: 24),

              // XP earned indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '★',
                      style: TextStyle(fontSize: 24, color: AppColors.amber),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.xpEarned} XP',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 300.ms)
                  .slideY(begin: 0.5, end: 0, delay: 300.ms, duration: 400.ms),

              if (widget.taskTitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  '"${widget.taskTitle}" complete!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.grey600,
                    fontStyle: FontStyle.italic,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
              ],

              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }
}