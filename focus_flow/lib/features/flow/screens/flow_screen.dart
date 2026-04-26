import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../data/models/enums.dart';
import '../../../providers/flow_provider.dart';
import '../../../providers/task_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/session_complete_sheet.dart';

class FlowScreen extends ConsumerWidget {
  const FlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(flowSessionProvider);
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: sessionState.activeSession == null
            ? tasksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _buildIdleState(context, ref, []),
                data: (tasks) {
                  final todayTasks = tasks.where((t) => !t.completed).toList();
                  return _buildIdleState(context, ref, todayTasks);
                },
              )
            : _buildActiveSession(context, ref, sessionState),
      ),
    );
  }

  Widget _buildIdleState(BuildContext context, WidgetRef ref, List tasks) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Flow',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.deepSlate,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    AppIcon(AppIcons.flashOn, color: AppColors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Ready',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Main content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lightning bolt icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.amber.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon(
                      AppIcons.flashOn,
                      color: AppColors.amber,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Headline
                const Text(
                  'No active session',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepSlate,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtext
                Text(
                  tasks.isEmpty
                      ? 'Complete your tasks to start a Flow session'
                      : 'Start a task from Today to begin a Flow session',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 40),

                // Quick start options
                Row(
                  children: [
                    Expanded(
                      child: _QuickStartCard(
                        icon: '⚡',
                        label: 'Quick Win',
                        color: AppColors.amber,
                        onTap: () => _startQuickSession(ref),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickStartCard(
                        icon: '🍅',
                        label: 'Pomodoro',
                        color: const Color(0xFFEF4444),
                        onTap: () => _startPomodoroSession(ref),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickStartCard(
                        icon: '🧠',
                        label: 'Deep Work',
                        color: const Color(0xFFEC4899),
                        onTap: () => _startDeepWorkSession(ref),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSession(BuildContext context, WidgetRef ref, FlowSessionState sessionState) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getSessionTitle(sessionState.sessionType),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    _getSessionSubtitle(sessionState.sessionType),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sessionState.isRunning
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    AppIcon(
                      AppIcons.pause,
                      color: sessionState.isRunning ? AppColors.success : AppColors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sessionState.isRunning ? 'Active' : 'Paused',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: sessionState.isRunning ? AppColors.success : AppColors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Timer
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TimerDisplay(
                elapsedSeconds: sessionState.elapsedSeconds,
                totalSeconds: _getTotalSeconds(sessionState),
                isBreak: sessionState.isBreak,
                sessionType: sessionState.sessionType,
              ),
              const SizedBox(height: 24),

              // Pomodoro rounds
              if (sessionState.sessionType == SessionType.pomodoro)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Round ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                    ),
                    Text(
                      '${sessionState.pomodoroRound}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                    const Text(
                      ' of 4',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 48),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pause/Resume
                  GestureDetector(
                    onTap: () {
                      if (sessionState.isRunning) {
                        ref.read(flowSessionProvider.notifier).pause();
                      } else {
                        ref.read(flowSessionProvider.notifier).resume();
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: sessionState.isRunning
                            ? AppColors.amber
                            : AppColors.teal,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (sessionState.isRunning
                                    ? AppColors.amber
                                    : AppColors.teal)
                                .withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AppIcon(
                        AppIcons.playCircle,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Stop
                  GestureDetector(
                    onTap: () async {
                      final shouldSave = await _showStopConfirmation(context);
                      if (shouldSave == true) {
                        await ref.read(flowSessionProvider.notifier).stop();
                        if (context.mounted) {
                          _showSessionComplete(context, ref, sessionState);
                        }
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.grey300, width: 2),
                      ),
                      child: AppIcon(
                        AppIcons.stop,
                        color: AppColors.navy,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _startQuickSession(WidgetRef ref) {
    ref.read(flowSessionProvider.notifier).startSession(SessionType.open);
  }

  void _startPomodoroSession(WidgetRef ref) {
    ref.read(flowSessionProvider.notifier).startSession(SessionType.pomodoro);
  }

  void _startDeepWorkSession(WidgetRef ref) {
    ref.read(flowSessionProvider.notifier).startSession(SessionType.deep);
  }

  String _getSessionTitle(SessionType type) {
    switch (type) {
      case SessionType.open:
        return 'Quick Win';
      case SessionType.pomodoro:
        return 'Pomodoro';
      case SessionType.deep:
        return 'Deep Work';
    }
  }

  String _getSessionSubtitle(SessionType type) {
    switch (type) {
      case SessionType.open:
        return 'Open session • Track as you go';
      case SessionType.pomodoro:
        return '25 min work • 5 min break';
      case SessionType.deep:
        return '50 min uninterrupted focus';
    }
  }

  int _getTotalSeconds(FlowSessionState state) {
    if (state.sessionType == SessionType.pomodoro) {
      return state.isBreak ? 5 * 60 : 25 * 60;
    } else if (state.sessionType == SessionType.deep) {
      return 50 * 60;
    }
    return 0;
  }

  Future<bool?> _showStopConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('Do you want to save this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSessionComplete(BuildContext context, WidgetRef ref, FlowSessionState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionCompleteSheet(
        sessionType: state.sessionType,
        durationMinutes: state.elapsedSeconds ~/ 60,
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickStartCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}