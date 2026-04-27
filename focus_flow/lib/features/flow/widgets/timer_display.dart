import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/enums.dart';

class TimerDisplay extends StatelessWidget {
  final int elapsedSeconds;
  final int totalSeconds;
  final bool isBreak;
  final SessionType sessionType;

  const TimerDisplay({
    super.key,
    required this.elapsedSeconds,
    required this.totalSeconds,
    required this.isBreak,
    required this.sessionType,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final timerSize = (screenWidth * 0.75).clamp(200.0, 280.0);
    final progress = totalSeconds > 0 ? (elapsedSeconds / totalSeconds).clamp(0.0, 1.0) : 0.0;
    final remaining = totalSeconds > 0 ? (totalSeconds - elapsedSeconds).clamp(0, totalSeconds) : 0;

    return SizedBox(
      width: timerSize,
      height: timerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: timerSize,
            height: timerSize,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 12,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation(AppColors.grey200),
            ),
          ),
          // Progress circle
          SizedBox(
            width: timerSize,
            height: timerSize,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                isBreak ? Colors.green : AppColors.teal,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Time display
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(remaining),
                style: TextStyle(
                  fontSize: timerSize * 0.2,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: (isBreak ? Colors.green : AppColors.teal).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusLabel(),
                  style: TextStyle(
                    fontSize: 14,
                    color: isBreak ? Colors.green : AppColors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getStatusLabel() {
    if (isBreak) return 'Break Time';
    switch (sessionType) {
      case SessionType.open:
        return 'Open Session';
      case SessionType.pomodoro:
        return 'Focus Time';
      case SessionType.deep:
        return 'Deep Work';
    }
  }
}