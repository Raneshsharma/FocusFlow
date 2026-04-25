import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/flow_session.dart';
import '../data/models/enums.dart';
import '../core/constants/app_constants.dart';
import 'providers.dart';

class FlowSessionState {
  final FlowSession? activeSession;
  final int elapsedSeconds;
  final bool isRunning;
  final int pomodoroRound;
  final bool isBreak;
  final SessionType sessionType;

  const FlowSessionState({
    this.activeSession,
    this.elapsedSeconds = 0,
    this.isRunning = false,
    this.pomodoroRound = 0,
    this.isBreak = false,
    this.sessionType = SessionType.open,
  });

  FlowSessionState copyWith({
    FlowSession? activeSession,
    int? elapsedSeconds,
    bool? isRunning,
    int? pomodoroRound,
    bool? isBreak,
    SessionType? sessionType,
  }) {
    return FlowSessionState(
      activeSession: activeSession ?? this.activeSession,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      pomodoroRound: pomodoroRound ?? this.pomodoroRound,
      isBreak: isBreak ?? this.isBreak,
      sessionType: sessionType ?? this.sessionType,
    );
  }

  double get progress {
    if (sessionType == SessionType.pomodoro) {
      final total = isBreak ? AppConstants.pomodoroShortBreak : AppConstants.pomodoroWork;
      return total > 0 ? elapsedSeconds / total : 0;
    } else if (sessionType == SessionType.deep) {
      return AppConstants.deepWork > 0 ? elapsedSeconds / AppConstants.deepWork : 0;
    }
    return 0;
  }

  int get remainingSeconds {
    if (sessionType == SessionType.pomodoro) {
      final total = isBreak ? AppConstants.pomodoroShortBreak : AppConstants.pomodoroWork;
      return total - elapsedSeconds;
    } else if (sessionType == SessionType.deep) {
      return AppConstants.deepWork - elapsedSeconds;
    }
    return 0;
  }
}

class FlowSessionNotifier extends StateNotifier<FlowSessionState> {
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  final Ref _ref;

  FlowSessionNotifier(this._ref) : super(const FlowSessionState());

  void startSession(SessionType type, {String? taskId}) {
    _stopwatch.reset();
    _stopwatch.start();

    final session = FlowSession.create(
      type: type,
      taskId: taskId,
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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_stopwatch.elapsed.inSeconds != state.elapsedSeconds) {
        state = state.copyWith(elapsedSeconds: _stopwatch.elapsed.inSeconds);
        _checkAutoComplete();
      }
    });
  }

  void _checkAutoComplete() {
    if (state.sessionType == SessionType.deep) {
      if (state.elapsedSeconds >= AppConstants.deepWork) {
        pause();
      }
    } else if (state.sessionType == SessionType.pomodoro) {
      final target = state.isBreak
          ? AppConstants.pomodoroShortBreak
          : AppConstants.pomodoroWork;
      if (state.elapsedSeconds >= target) {
        _handlePomodoroRoundComplete();
      }
    }
  }

  void _handlePomodoroRoundComplete() {
    if (!state.isBreak) {
      _stopwatch.reset();
      state = state.copyWith(isBreak: true, elapsedSeconds: 0);
    } else {
      if (state.pomodoroRound < AppConstants.pomodoroRounds) {
        _stopwatch.reset();
        state = state.copyWith(
          isBreak: false,
          elapsedSeconds: 0,
          pomodoroRound: state.pomodoroRound + 1,
        );
      } else {
        pause();
      }
    }
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

  Future<void> stop() async {
    _timer?.cancel();
    _stopwatch.stop();

    if (state.activeSession != null) {
      final session = state.activeSession!;
      session.durationSeconds = state.elapsedSeconds;
      session.completedAt = DateTime.now();

      final repoAsync = _ref.read(sessionRepositoryProvider);
      await repoAsync.whenData((repo) async {
        await repo.save(session);
        await _ref.read(statsRepositoryProvider).whenData((statsRepo) async {
          await statsRepo.incrementSessionsCompleted(DateTime.now());
          await statsRepo.addFocusMinutes(DateTime.now(), state.elapsedSeconds ~/ 60);
        });
      });
    }

    state = const FlowSessionState();
  }

  void setSessionType(SessionType type) {
    if (state.activeSession == null) {
      state = state.copyWith(sessionType: type);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final flowSessionProvider = StateNotifierProvider<FlowSessionNotifier, FlowSessionState>((ref) {
  return FlowSessionNotifier(ref);
});
