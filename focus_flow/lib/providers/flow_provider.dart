import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/flow_session.dart';
import '../data/models/enums.dart';
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

  const FlowSessionState({
    this.activeSession,
    this.elapsedSeconds = 0,
    this.currentPhaseElapsed = 0,
    this.isRunning = false,
    this.pomodoroRound = 0,
    this.isBreak = false,
    this.isLongBreak = false,
    this.sessionType = SessionType.open,
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
    );
  }

  double get progress {
    if (sessionType == SessionType.pomodoro) {
      int total;
      if (isLongBreak) {
        total = AppConstants.pomodoroLongBreak;
      } else if (isBreak) {
        total = AppConstants.pomodoroShortBreak;
      } else {
        total = AppConstants.pomodoroWork;
      }
      return total > 0 ? currentPhaseElapsed / total : 0;
    } else if (sessionType == SessionType.deep) {
      return AppConstants.deepWork > 0 ? elapsedSeconds / AppConstants.deepWork : 0;
    }
    return 0;
  }

  int get remainingSeconds {
    if (sessionType == SessionType.pomodoro) {
      int total;
      if (isLongBreak) {
        total = AppConstants.pomodoroLongBreak;
      } else if (isBreak) {
        total = AppConstants.pomodoroShortBreak;
      } else {
        total = AppConstants.pomodoroWork;
      }
      return (total - currentPhaseElapsed).clamp(0, total);
    } else if (sessionType == SessionType.deep) {
      return (AppConstants.deepWork - elapsedSeconds).clamp(0, AppConstants.deepWork);
    }
    return 0;
  }
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
    _stopwatch.reset();
    _stopwatch.start();

    String? resolvedTaskTitle = taskTitle;
    if (taskId != null && taskTitle == null) {
      final tasksAsync = _ref.read(tasksProvider);
      final taskList = tasksAsync.valueOrNull;
      if (taskList != null) {
        try {
          final task = taskList.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Not found'));
          resolvedTaskTitle = task.title;
        } catch (e) {
          // Proceed without title
        }
      }
    }

    final session = FlowSession.create(
      type: type,
      taskId: taskId,
      taskTitle: resolvedTaskTitle,
      startedAt: DateTime.now(),
    );

    state = FlowSessionState(
      activeSession: session,
      isRunning: true,
      sessionType: type,
      pomodoroRound: type == SessionType.pomodoro ? 1 : 0,
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final totalElapsed = _stopwatch.elapsed.inSeconds;
      if (totalElapsed != state.elapsedSeconds) {
        int phaseElapsed = state.currentPhaseElapsed;
        if (state.sessionType == SessionType.pomodoro) {
          int currentPhaseTarget;
          if (state.isLongBreak) {
            currentPhaseTarget = AppConstants.pomodoroLongBreak;
          } else if (state.isBreak) {
            currentPhaseTarget = AppConstants.pomodoroShortBreak;
          } else {
            currentPhaseTarget = AppConstants.pomodoroWork;
          }
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
      int target;
      if (state.isLongBreak) {
        target = AppConstants.pomodoroLongBreak;
      } else if (state.isBreak) {
        target = AppConstants.pomodoroShortBreak;
      } else {
        target = AppConstants.pomodoroWork;
      }
      if (state.currentPhaseElapsed >= target) {
        _handlePomodoroRoundComplete();
      }
    }
  }

  void _handlePomodoroRoundComplete() {
    if (_isTransitioning) return;
    _isTransitioning = true;

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
      _isTransitioning = false;
      pause();
      return;
    } else {
      NotificationService().showBreakEndNotification();

      if (state.pomodoroRound >= AppConstants.pomodoroRounds) {
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
    _isTransitioning = false;
  }

  void pause() {
    _stopwatch.stop();
    state = state.copyWith(isRunning: false);
    _timer?.cancel();
  }

  void resume() {
    _stopwatch.start();
    state = state.copyWith(isRunning: true);
    _startTimer();
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
        await _ref.read(statsRepositoryProvider.future).then((statsRepo) async {
          await statsRepo.incrementSessionsCompleted(DateTime.now());
          await statsRepo.addFocusMinutes(DateTime.now(), state.elapsedSeconds ~/ 60);

          final stats = await statsRepo.getStats();
          final streak = await statsRepo.getCurrentStreak();
          final newAchievement = await _ref.read(achievementsProvider.notifier).checkAndUnlock(
            totalSessions: stats.totalSessions,
            totalTasks: stats.totalTasksCompleted,
            currentStreak: streak,
          );
          if (newAchievement != null) {
            final defs = _ref.read(achievementDefinitionsProvider);
            try {
              final def = defs.firstWhere((d) => d.id == newAchievement.definitionId);
              // Use overlay service for showing achievement toast
              if (overlayService.isInitialized) {
                AchievementToast.showOverlay(overlayService, def);
              }
            } catch (_) {}
          }
        });
      } catch (e) {
        debugPrint('Error saving session: $e');
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
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}

final flowSessionProvider = StateNotifierProvider<FlowSessionNotifier, FlowSessionState>((ref) {
  return FlowSessionNotifier(ref);
});