import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/daily_stats.dart';
import '../core/utils/streak_calculator.dart';
import 'providers.dart';
import 'task_provider.dart';

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
    } catch (e) {
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
    data: (stats) => stats ?? DailyStats.create(date: _formatDate(DateTime.now())),
    loading: () => DailyStats.create(date: _formatDate(DateTime.now())),
    error: (_, __) => DailyStats.create(date: _formatDate(DateTime.now())),
  );
});

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

final streakProvider = FutureProvider<StreakData>((ref) async {
  final repoAsync = ref.watch(statsRepositoryProvider);
  return repoAsync.when(
    data: (repo) {
      final dates = repo.getActiveDates();
      return StreakCalculator.calculate(dates);
    },
    loading: () => StreakData(current: 0, longest: 0, totalDays: 0),
    error: (_, __) => StreakData(current: 0, longest: 0, totalDays: 0),
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
  final tasks = ref.watch(tasksProvider);
  return tasks.where((t) => t.completed).length;
});
