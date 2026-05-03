import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/daily_progress.dart';
import '../core/constants/app_constants.dart';

final dailyProgressRepositoryProvider = Provider((ref) => DailyProgressRepository());

final gamificationProvider = AsyncNotifierProvider<GamificationNotifier, GamificationState>(() {
  return GamificationNotifier();
});

class GamificationState {
  final int totalXp;
  final int level;
  final int todayXp;
  final int tasksCompletedToday;
  final int sessionsCompletedToday;
  final int currentStreak;
  final List<String> todayAchievements;
  final int xpToNextLevel;

  GamificationState({
    this.totalXp = 0,
    this.level = 1,
    this.todayXp = 0,
    this.tasksCompletedToday = 0,
    this.sessionsCompletedToday = 0,
    this.currentStreak = 0,
    this.todayAchievements = const [],
    this.xpToNextLevel = 100,
  });

  GamificationState copyWith({
    int? totalXp,
    int? level,
    int? todayXp,
    int? tasksCompletedToday,
    int? sessionsCompletedToday,
    int? currentStreak,
    List<String>? todayAchievements,
    int? xpToNextLevel,
  }) {
    return GamificationState(
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      todayXp: todayXp ?? this.todayXp,
      tasksCompletedToday: tasksCompletedToday ?? this.tasksCompletedToday,
      sessionsCompletedToday: sessionsCompletedToday ?? this.sessionsCompletedToday,
      currentStreak: currentStreak ?? this.currentStreak,
      todayAchievements: todayAchievements ?? this.todayAchievements,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
    );
  }

  double get levelProgress {
    final perLevel = AppConstants.xpPerLevel;
    if (perLevel <= 0) return 0.0;
    return (totalXp % perLevel) / perLevel;
  }

  bool get canLevelUp => totalXp >= level * AppConstants.xpPerLevel;
}

class GamificationNotifier extends AsyncNotifier<GamificationState> {
  DailyProgressRepository? _repository;

  @override
  Future<GamificationState> build() async {
    _repository = ref.read(dailyProgressRepositoryProvider);
    return _loadState();
  }

  Future<GamificationState> _loadState() async {
    if (_repository == null) return GamificationState();

    final progress = await _repository!.getTodayProgress();
    final totalXp = await _getTotalXp();

    return GamificationState(
      totalXp: totalXp,
      level: _calculateLevel(totalXp),
      todayXp: progress.xpEarned,
      tasksCompletedToday: progress.tasksCompleted,
      sessionsCompletedToday: progress.sessionsCompleted,
      todayAchievements: progress.achievementsUnlocked,
      xpToNextLevel: AppConstants.xpPerLevel - (totalXp % AppConstants.xpPerLevel),
    );
  }

  int _calculateLevel(int xp) => (xp / AppConstants.xpPerLevel).floor() + 1;

  Future<int> _getTotalXp() async {
    if (_repository == null) return 0;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final progressList = await _repository!.getProgressForRange(weekAgo, now);

    int total = 0;
    for (final p in progressList) {
      total += p.xpEarned;
    }

    return total;
  }

  Future<void> addXpForTask() async {
    if (_repository == null) return;

    await _repository!.addXp(AppConstants.xpPerTask);
    await _repository!.incrementTasks();
    ref.invalidate(gamificationProvider);
  }

  Future<void> addXpForSession({bool isDeep = false}) async {
    if (_repository == null) return;

    final xp = isDeep ? AppConstants.xpPerDeepSession : AppConstants.xpPerSession;
    await _repository!.addXp(xp);
    await _repository!.incrementSessions();
    ref.invalidate(gamificationProvider);
  }

  Future<void> addXpForStreak() async {
    if (_repository == null) return;

    await _repository!.addXp(AppConstants.xpPerStreakDay);
    ref.invalidateSelf();
    ref.invalidate(gamificationProvider);
  }

  Future<void> addAchievementUnlocked(String achievementId) async {
    if (_repository == null) return;

    await _repository!.addAchievement(achievementId);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// Convenience providers
final currentLevelProvider = Provider<int>((ref) {
  final gamState = ref.watch(gamificationProvider);
  return gamState.when(
    data: (state) => state.level,
    loading: () => 1,
    error: (_, __) => 1,
  );
});

final xpProgressProvider = Provider<double>((ref) {
  final gamState = ref.watch(gamificationProvider);
  return gamState.when(
    data: (state) => state.levelProgress,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

final todayXpProvider = Provider<int>((ref) {
  final gamState = ref.watch(gamificationProvider);
  return gamState.when(
    data: (state) => state.todayXp,
    loading: () => 0,
    error: (_, __) => 0,
  );
});