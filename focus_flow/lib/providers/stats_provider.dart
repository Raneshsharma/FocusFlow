import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/daily_stats.dart';
import '../core/utils/streak_calculator.dart' as calculator;
import '../core/utils/date_helpers.dart';
import '../services/streak_service.dart';
import 'providers.dart';

// Streak service provider
final streakServiceProvider = Provider((ref) => StreakService());

// Enhanced streak provider using StreakService
final enhancedStreakProvider = FutureProvider<StreakResult>((ref) async {
  final service = ref.read(streakServiceProvider);
  return service.checkStreakStatus();
});

// Simple state provider for today's stats
final todayStatsProvider = AsyncNotifierProvider<TodayStatsNotifier, DailyStats?>(() {
  return TodayStatsNotifier();
});

class TodayStatsNotifier extends AsyncNotifier<DailyStats?> {
  @override
  Future<DailyStats?> build() async {
    try {
      final repo = await ref.read(statsRepositoryProvider.future);
      return repo.getByDate(DateTime.now());
    } catch (e, st) {
      debugPrint('TodayStatsNotifier.build: $e\n$st');
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(statsRepositoryProvider.future);
      return repo.getByDate(DateTime.now());
    });
  }

  Future<void> incrementTasks() async {
    final repo = await ref.read(statsRepositoryProvider.future);
    await repo.incrementTasksCompleted(DateTime.now());
    await refresh();
  }

  Future<void> incrementSessions() async {
    final repo = await ref.read(statsRepositoryProvider.future);
    await repo.incrementSessionsCompleted(DateTime.now());
    await refresh();
  }

  Future<void> addFocusMinutes(int minutes) async {
    final repo = await ref.read(statsRepositoryProvider.future);
    await repo.addFocusMinutes(DateTime.now(), minutes);
    await refresh();
  }
}

// Provider to get today's stats
final getTodayStatsProvider = FutureProvider<DailyStats>((ref) async {
  final statsAsync = ref.watch(todayStatsProvider);
  return statsAsync.when(
    data: (stats) => stats ?? DailyStats.create(date: formatDateKey(DateTime.now())),
    loading: () => DailyStats.create(date: formatDateKey(DateTime.now())),
    error: (_, __) => DailyStats.create(date: formatDateKey(DateTime.now())),
  );
});

final streakProvider = FutureProvider<calculator.StreakResult>((ref) async {
  final repoAsync = ref.watch(statsRepositoryProvider);
  return repoAsync.when(
    data: (repo) {
      final dates = repo.getActiveDates();
      return calculator.StreakCalculator.calculate(dates);
    },
    loading: () => calculator.StreakResult(current: 0, longest: 0, totalDays: 0),
    error: (_, __) => calculator.StreakResult(current: 0, longest: 0, totalDays: 0),
  );
});

final totalFocusMinutesProvider = FutureProvider<int>((ref) async {
  final repoAsync = ref.watch(sessionRepositoryProvider);
  return repoAsync.when(
    data: (repo) => repo.getTotalFocusMinutes(),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final completedTasksCountProvider = Provider<int>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.when(
    data: (tasks) => tasks.where((t) => t.completed).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Settings screen specific providers
final settingsStreakProvider = FutureProvider<int>((ref) async {
  final repoAsync = ref.watch(statsRepositoryProvider);
  return repoAsync.when(
    data: (repo) => repo.getCurrentStreak(),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final settingsTotalSessionsProvider = FutureProvider<int>((ref) async {
  final repoAsync = ref.watch(sessionRepositoryProvider);
  return repoAsync.when(
    data: (repo) => repo.getAll().length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final settingsTotalFocusMinutesProvider = FutureProvider<int>((ref) async {
  final repoAsync = ref.watch(sessionRepositoryProvider);
  return repoAsync.when(
    data: (repo) => repo.getTotalFocusMinutes(),
    loading: () => 0,
    error: (_, __) => 0,
  );
});
