import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/flow_session.dart';
import '../data/models/enums.dart';
import '../data/models/app_settings.dart';
import '../core/constants/app_constants.dart';
import '../services/notification_service.dart';
import '../services/overlay_service.dart';
import '../features/achievements/widgets/achievement_toast.dart';
import 'providers.dart';
import 'task_provider.dart';
import 'achievement_provider.dart';
import 'gamification_provider.dart';

class FlowSessionState {
  final FlowSession? activeSession;
  final int elapsedSeconds;
  final int currentPhaseElapsed;
  final bool isRunning;
  final int pomodoroRound;
  final bool isBreak;
  final bool isLongBreak;
  final SessionType sessionType;
  final PomodoroTimerSettings pomodoroSettings;
  final int customDurationMinutes; // For custom timer sessions

  const FlowSessionState({
    this.activeSession,
    this.elapsedSeconds = 0,
    this.currentPhaseElapsed = 0,
    this.isRunning = false,
    this.pomodoroRound = 0,
    this.isBreak = false,
    this.isLongBreak = false,
    this.sessionType = SessionType.open,
    this.pomodoroSettings = const PomodoroTimerSettings(),
    this.customDurationMinutes = 0,
  });

  FlowSessionState copyWith({
    FlowSession? activeSession,
    int? elapsedSeconds,
    int? currentPhaseElapsed,
    bool? isRunning,
    int? pomodoroRound,
    bool? isBreak,
    bool? isLongBreak,
    SessionType? sessionType,
    PomodoroTimerSettings? pomodoroSettings,
    int? customDurationMinutes,
  }) {
    return FlowSessionState(
      activeSession: activeSession ?? this.activeSession,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentPhaseElapsed: currentPhaseElapsed ?? this.currentPhaseElapsed,
      isRunning: isRunning ?? this.isRunning,
      pomodoroRound: pomodoroRound ?? this.pomodoroRound,
      isBreak: isBreak ?? this.isBreak,
      isLongBreak: isLongBreak ?? this.isLongBreak,
      sessionType: sessionType ?? this.sessionType,
      pomodoroSettings: pomodoroSettings ?? this.pomodoroSettings,
      customDurationMinutes: customDurationMinutes ?? this.customDurationMinutes,
    );
  }

  /// Returns total seconds for current phase based on user settings
  int get _currentPhaseTotal {
    if (sessionType == SessionType.pomodoro) {
      if (isLongBreak) {
        return pomodoroSettings.longBreakMinutes * 60;
      } else if (isBreak) {
        return pomodoroSettings.shortBreakMinutes * 60;
      } else {
        return pomodoroSettings.workMinutes * 60;
      }
    } else if (sessionType == SessionType.deep) {
      return AppConstants.deepWork;
    } else if (sessionType == SessionType.custom && customDurationMinutes > 0) {
      // Custom timer session
      return customDurationMinutes * 60;
    } else if (sessionType == SessionType.open && customDurationMinutes > 0) {
      // Legacy custom timer (open session with custom duration)
      return customDurationMinutes * 60;
    }
    return 0;
  }

  double get progress {
    final total = _currentPhaseTotal;
    if (sessionType == SessionType.pomodoro) {
      return total > 0 ? currentPhaseElapsed / total : 0;
    } else if (sessionType == SessionType.deep || sessionType == SessionType.custom) {
      return total > 0 ? elapsedSeconds / total : 0;
    }
    return 0;
  }

  int get remainingSeconds {
    final total = _currentPhaseTotal;
    if (sessionType == SessionType.pomodoro) {
      return (total - currentPhaseElapsed).clamp(0, total);
    } else if (sessionType == SessionType.deep || sessionType == SessionType.custom) {
      return (total - elapsedSeconds).clamp(0, total);
    }
    return 0;
  }

  /// Get total seconds for display purposes
  int get totalSeconds => _currentPhaseTotal;
}

class FlowSessionNotifier extends StateNotifier<FlowSessionState> with WidgetsBindingObserver {
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  final Ref _ref;
  bool _isTransitioning = false;

  // Background handling - save timestamp when app goes to background
  DateTime? _backgroundTimestamp;

  FlowSessionNotifier(this._ref) : super(const FlowSessionState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.paused) {
      // App going to background - save current timestamp
      if (_stopwatch.isRunning) {
        _backgroundTimestamp = DateTime.now();
      }
    } else if (lifecycleState == AppLifecycleState.resumed) {
      // App returning from background - recalculate elapsed time
      if (_backgroundTimestamp != null) {
        // The stopwatch automatically handles background time
        // but we need to ensure notifications are shown if time passed
        _checkBackgroundTimePassed();
      }
      _backgroundTimestamp = null;
    }
  }

  void _checkBackgroundTimePassed() {
    // This is handled by the stopwatch itself - when the app is backgrounded,
    // the stopwatch continues running (for short periods) but eventually may be
    // affected by OS process suspension. The timer periodic will catch up
    // when the app returns and re-sync the elapsed time.

    // If a significant amount of time passed, trigger auto-complete
    final now = DateTime.now();
    if (_backgroundTimestamp != null) {
      final elapsed = now.difference(_backgroundTimestamp!).inSeconds;
      if (elapsed > 0) {
        // Force a timer tick to catch up
        _timer?.cancel();
        _startTimer();
      }
    }
  }

  void startSession(SessionType type, {String? taskId, String? taskTitle}) {
    debugPrint('startSession called: type=$type, taskId=$taskId');
    _stopwatch.reset();

    String? resolvedTaskTitle = taskTitle;
    if (taskId != null && taskTitle == null) {
      final tasksAsync = _ref.read(tasksProvider);
      final taskList = tasksAsync.valueOrNull;
      if (taskList != null) {
        try {
          final task = taskList.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Not found'));
          resolvedTaskTitle = task.title;
        } catch (e) {
          debugPrint('FlowSessionNotifier: Task not found for session, proceeding without title');
        }
      }
    }

    // Load user pomodoro settings
    final pomodoroSettings = _ref.read(pomodoroSettingsProvider);

    final session = FlowSession.create(
      type: type,
      taskId: taskId,
      taskTitle: resolvedTaskTitle,
      startedAt: DateTime.now(),
    );

    state = FlowSessionState(
      activeSession: session,
      isRunning: false, // User taps play to start
      sessionType: type,
      pomodoroRound: type == SessionType.pomodoro ? 1 : 0,
      pomodoroSettings: pomodoroSettings,
    );
  }

  void resume() {
    debugPrint('resume called - starting timer');
    _stopwatch.reset();
    _stopwatch.start();
    state = state.copyWith(isRunning: true);
    _startTimer();
  }

  void _startTimer() {
    debugPrint('_startTimer called');
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      debugPrint('Timer tick: elapsed=${_stopwatch.elapsed.inSeconds}');
      final totalElapsed = _stopwatch.elapsed.inSeconds;
      if (totalElapsed != state.elapsedSeconds) {
        int phaseElapsed = state.currentPhaseElapsed;
        if (state.sessionType == SessionType.pomodoro) {
          final currentPhaseTarget = state.totalSeconds;
          phaseElapsed = totalElapsed % currentPhaseTarget;
        }
        state = state.copyWith(
          elapsedSeconds: totalElapsed,
          currentPhaseElapsed: phaseElapsed,
        );
        _checkAutoComplete();
      }
    });
  }

  void _checkAutoComplete() {
    if (_isTransitioning) return;

    if (state.sessionType == SessionType.deep) {
      if (state.elapsedSeconds >= AppConstants.deepWork) {
        NotificationService().showSessionEndNotification(
          title: 'Deep Work Complete! 🧠',
          body: 'Excellent focus session! Time to take a break.',
        );
        pause();
      }
    } else if (state.sessionType == SessionType.pomodoro) {
      if (state.currentPhaseElapsed >= state.totalSeconds) {
        _handlePomodoroRoundComplete();
      }
    } else if (state.sessionType == SessionType.custom) {
      // For custom sessions, check if elapsed time reaches target duration
      if (state.totalSeconds > 0 && state.elapsedSeconds >= state.totalSeconds) {
        NotificationService().showSessionEndNotification(
          title: 'Session Complete! ⏱️',
          body: 'Great work! Time to take a break.',
        );
        pause();
      }
    }
  }

  void _handlePomodoroRoundComplete() {
    if (_isTransitioning) return;
    _isTransitioning = true;

    try {
      if (!state.isBreak) {
        NotificationService().showSessionEndNotification(
          title: 'Work Block Done! ⚡',
          body: 'Time for a break. You earned it!',
        );

        _stopwatch.reset();
        _stopwatch.start();
        state = state.copyWith(
          isBreak: true,
          elapsedSeconds: 0,
          currentPhaseElapsed: 0,
        );
      } else if (state.isLongBreak) {
        NotificationService().showLongBreakEndNotification();
        pause();
        return;
      } else {
        NotificationService().showBreakEndNotification();

        // Use user's configured rounds from settings
        final roundsBeforeLongBreak = state.pomodoroSettings.roundsBeforeLongBreak;
        if (state.pomodoroRound >= roundsBeforeLongBreak) {
          _stopwatch.reset();
          _stopwatch.start();
          state = state.copyWith(
            isBreak: false,
            isLongBreak: true,
            elapsedSeconds: 0,
            currentPhaseElapsed: 0,
          );
        } else {
          _stopwatch.reset();
          _stopwatch.start();
          state = state.copyWith(
            isBreak: false,
            elapsedSeconds: 0,
            currentPhaseElapsed: 0,
            pomodoroRound: state.pomodoroRound + 1,
          );
        }
      }
    } finally {
      _isTransitioning = false;
    }
  }

  void pause() {
    _stopwatch.stop();
    state = state.copyWith(isRunning: false);
    _timer?.cancel();
  }

  void discardSession() {
    _timer?.cancel();
    _stopwatch.reset();
    state = const FlowSessionState();
  }

  void resetTimer() {
    _stopwatch.reset();
    state = state.copyWith(elapsedSeconds: 0, currentPhaseElapsed: 0);
  }

  void startCustomSession(int minutes) {
    _stopwatch.reset();

    final session = FlowSession.create(
      type: SessionType.custom,
      taskTitle: 'Custom Timer',
      startedAt: DateTime.now(),
    );

    state = FlowSessionState(
      activeSession: session,
      isRunning: false, // User taps play to start
      sessionType: SessionType.custom,
      pomodoroRound: 0,
      pomodoroSettings: const PomodoroTimerSettings(),
      customDurationMinutes: minutes,
    );
  }

  Future<FlowSession?> stop() async {
    _isTransitioning = false;
    _timer?.cancel();
    _stopwatch.stop();

    if (state.activeSession != null) {
      final session = state.activeSession!;
      session.durationSeconds = state.elapsedSeconds;
      session.completedAt = DateTime.now();

      try {
        final repo = await _ref.read(sessionRepositoryProvider.future);
        await repo.save(session);
      } catch (e, st) {
        debugPrint('FlowSessionNotifier.stop: Error saving session: $e\n$st');
      }

      try {
        final statsRepo = await _ref.read(statsRepositoryProvider.future);
        await statsRepo.incrementSessionsCompleted(DateTime.now());
        await statsRepo.addFocusMinutes(DateTime.now(), state.elapsedSeconds ~/ 60);
        // Refresh today stats so weekly chart shows updated data
        _ref.invalidate(todayStatsProvider);

        // Check for new achievements using the full stats provider
        final newAchievement = await _ref.read(achievementsProvider.notifier).checkAndUnlock();
        if (newAchievement != null) {
          final defs = _ref.read(achievementDefinitionsProvider);
          try {
            final def = defs.firstWhere((d) => d.id == newAchievement.definitionId);
            // Use overlay service for showing achievement toast
            if (overlayService.isInitialized) {
              AchievementToast.showOverlay(overlayService, def);
            }
          } catch (e) {
            debugPrint('FlowSessionNotifier.stop: Achievement definition not found: $e');
          }
        }
      } catch (e, st) {
        debugPrint('FlowSessionNotifier.stop: Error updating stats/achievements: $e\n$st');
      }

      // Add XP for completing session
      final isDeep = state.sessionType == SessionType.deep;
      _ref.read(gamificationProvider.notifier).addXpForSession(isDeep: isDeep);

      state = const FlowSessionState();
      return session;
    }

    state = const FlowSessionState();
    return null;
  }

  void setSessionType(SessionType type) {
    if (state.activeSession == null) {
      state = state.copyWith(sessionType: type);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

final flowSessionProvider = StateNotifierProvider<FlowSessionNotifier, FlowSessionState>((ref) {
  return FlowSessionNotifier(ref);
});