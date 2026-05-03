import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/flow_session.dart';
import '../../../data/models/task.dart';
import '../../../data/models/app_settings.dart';
import '../../../providers/flow_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/settings_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/session_complete_sheet.dart';
import '../widgets/dynamic_motivator.dart';

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

  Widget _buildIdleState(BuildContext context, WidgetRef ref, List<Task> tasks) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            _FlowHeader(),
            const SizedBox(height: 20),

            // Flow State Card (empty state)
            const _FlowStateCard(),
            const SizedBox(height: 24),

            // Section Header
            const _SectionHeader(title: 'Start a session'),
            const SizedBox(height: 12),

            // Session Cards Row
            Row(
              children: const [
                Expanded(
                  child: _SessionCard(
                    icon: '⚡',
                    title: 'Quick Win',
                    description: 'Short burst of focus',
                    durationBadge: '5–15 min',
                    sessionType: SessionType.open,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SessionCard(
                    icon: '🍅',
                    title: 'Pomodoro',
                    description: 'Classic focus cycle',
                    durationBadge: '25 min',
                    sessionType: SessionType.pomodoro,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SessionCard(
                    icon: '🧠',
                    title: 'Deep Work',
                    description: 'Long distraction-free',
                    durationBadge: '50 min',
                    sessionType: SessionType.deep,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Custom Timer Section
            const _SectionHeader(title: 'Custom timer'),
            const SizedBox(height: 12),
            const _CustomTimerCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
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
              // Back button to exit timer and return to selection
              GestureDetector(
                onTap: () => _showExitTimerConfirmation(context, ref),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 22,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
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
                      _getSessionSubtitle(sessionState.sessionType, sessionState),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: sessionState.isRunning ? 'Active' : 'Paused',
                color: sessionState.isRunning ? AppColors.success : AppColors.amber,
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
                Consumer(
                  builder: (context, ref, _) {
                    final settings = ref.watch(pomodoroSettingsProvider);
                    final rounds = settings?.roundsBeforeLongBreak ?? 4;
                    return Row(
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
                        Text(
                          ' of $rounds',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 48),

              // Controls
              _buildTimerControls(context, ref, sessionState),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerControls(BuildContext context, WidgetRef ref, FlowSessionState sessionState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reset button (left)
          GestureDetector(
            onTap: () => _showResetConfirmation(context, ref),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🔄', style: TextStyle(fontSize: 26)),
              ),
            ),
          ),

          // Play/Pause button (center - larger)
          GestureDetector(
            onTap: () {
              if (sessionState.isRunning) {
                ref.read(flowSessionProvider.notifier).pause();
              } else {
                ref.read(flowSessionProvider.notifier).resume();
              }
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: sessionState.isRunning ? AppColors.amber : AppColors.teal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (sessionState.isRunning ? AppColors.amber : AppColors.teal)
                        .withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  sessionState.isRunning ? '⏸' : '▶️',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          ),

          // Stop button (right)
          GestureDetector(
            onTap: () async {
              final shouldSave = await _showStopConfirmation(context);
              if (shouldSave == true) {
                final savedSession = await ref.read(flowSessionProvider.notifier).stop();
                if (context.mounted && savedSession != null) {
                  _showSessionComplete(context, ref, savedSession);
                }
              } else if (shouldSave == false) {
                ref.read(flowSessionProvider.notifier).discardSession();
              }
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text('⏹', style: TextStyle(fontSize: 26)),
              ),
            ),
          ),
        ],
      ),
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
      case SessionType.custom:
        return 'Custom Timer';
    }
  }

  String _getSessionSubtitle(SessionType type, FlowSessionState? state) {
    switch (type) {
      case SessionType.open:
        return 'Open session';
      case SessionType.pomodoro:
        if (state != null) {
          return '${state.pomodoroSettings.workMinutes} min work • ${state.pomodoroSettings.shortBreakMinutes} min break';
        }
        return '25 min work • 5 min break';
      case SessionType.deep:
        return '50 min uninterrupted focus';
      case SessionType.custom:
        if (state != null && state.customDurationMinutes > 0) {
          return '${state.customDurationMinutes} min countdown';
        }
        return 'Custom duration';
    }
  }

  int _getTotalSeconds(FlowSessionState state) {
    return state.totalSeconds;
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

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Timer?'),
        content: const Text('This will reset the timer to 00:00. Your session continues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(flowSessionProvider.notifier).resetTimer();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showExitTimerConfirmation(BuildContext context, WidgetRef ref) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit Timer?'),
        content: const Text('Do you want to save this session before leaving?'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(flowSessionProvider.notifier).discardSession();
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
            ),
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    ).then((result) async {
      if (result == true) {
        // User chose to save - wait for stop to complete before navigating
        await ref.read(flowSessionProvider.notifier).stop();
      } else {
        // User discarded or dismissed - ensure session is discarded
        ref.read(flowSessionProvider.notifier).discardSession();
      }
    });
  }

  void _showSessionComplete(BuildContext context, WidgetRef ref, FlowSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SessionCompleteSheet(
        sessionType: session.type,
        durationMinutes: session.durationSeconds ~/ 60,
        taskTitle: session.taskTitle,
        reflection: session.reflection,
      ),
    );
  }
}

// ============== Reusable Components ==============

class _FlowHeader extends StatelessWidget {
  const _FlowHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Flow',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Stay focused, one session at a time',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
        const _StatusPill(
          label: 'Ready',
          color: AppColors.teal,
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowStateCard extends StatelessWidget {
  const _FlowStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.teal.withOpacity(0.08),
            AppColors.amber.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.teal.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('⚡', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'No active session',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'Start a session to begin your focus time',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Motivation line
          const Text(
            'Small steps lead to big wins',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  final String icon;
  final String title;
  final String description;
  final String durationBadge;
  final SessionType sessionType;

  const _SessionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.durationBadge,
    required this.sessionType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color cardColor;
    switch (sessionType) {
      case SessionType.open:
        cardColor = AppColors.amber;
        break;
      case SessionType.pomodoro:
        cardColor = AppColors.sessionPomodoro;
        break;
      case SessionType.deep:
        cardColor = AppColors.sessionDeep;
        break;
      case SessionType.custom:
        cardColor = AppColors.teal;
        break;
    }

    return GestureDetector(
      onTap: () => _startSession(ref),
      child: Container(
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: 8),

            // Duration badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                durationBadge,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: cardColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startSession(WidgetRef ref) {
    ref.read(flowSessionProvider.notifier).startSession(sessionType);
  }
}

class _CustomTimerCard extends ConsumerStatefulWidget {
  const _CustomTimerCard();

  @override
  ConsumerState<_CustomTimerCard> createState() => _CustomTimerCardState();
}

class _CustomTimerCardState extends ConsumerState<_CustomTimerCard> {
  int _customMinutes = 25;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text('⏱️', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'Set your time',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_customMinutes min',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timer controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrease button
              GestureDetector(
                onTap: () {
                  if (_customMinutes > 1) {
                    setState(() => _customMinutes--);
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('−', style: TextStyle(fontSize: 24, color: AppColors.navy)),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Time display
              Container(
                width: 100,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_customMinutes',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const Text(
                      'minutes',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Increase button
              GestureDetector(
                onTap: () {
                  if (_customMinutes < 180) {
                    setState(() => _customMinutes++);
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('+', style: TextStyle(fontSize: 24, color: AppColors.navy)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PresetButton(
                label: '5 min',
                isSelected: _customMinutes == 5,
                onTap: () => setState(() => _customMinutes = 5),
              ),
              _PresetButton(
                label: '15 min',
                isSelected: _customMinutes == 15,
                onTap: () => setState(() => _customMinutes = 15),
              ),
              _PresetButton(
                label: '25 min',
                isSelected: _customMinutes == 25,
                onTap: () => setState(() => _customMinutes = 25),
              ),
              _PresetButton(
                label: '45 min',
                isSelected: _customMinutes == 45,
                onTap: () => setState(() => _customMinutes = 45),
              ),
              _PresetButton(
                label: '1 hr',
                isSelected: _customMinutes == 60,
                onTap: () => setState(() => _customMinutes = 60),
              ),
              _PresetButton(
                label: '2 hr',
                isSelected: _customMinutes == 120,
                onTap: () => setState(() => _customMinutes = 120),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(flowSessionProvider.notifier).startCustomSession(_customMinutes);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Session',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.teal : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.grey600,
          ),
        ),
      ),
    );
  }
}