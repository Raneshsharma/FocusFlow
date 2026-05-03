import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/achievement.dart';
import '../../data/models/enums.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../core/constants/achievements.dart';
import '../providers/stats_provider.dart';
import '../providers/providers.dart';
import '../../data/models/flow_session.dart';

// Repository provider - sync since AchievementRepository.create() is not async
final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository();
});

// Main achievements provider - returns unlocked achievements
final achievementsProvider = AsyncNotifierProvider<AchievementsNotifier, List<Achievement>>(
  AchievementsNotifier.new,
);

// Achievement stats - computed from all data sources
final achievementStatsProvider = FutureProvider<AchievementStats>((ref) async {
  final statsRepo = await ref.read(statsRepositoryProvider.future);
  final sessionRepo = await ref.read(sessionRepositoryProvider.future);
  final taskRepo = await ref.read(taskRepositoryProvider.future);
  final noteRepo = await ref.read(noteRepositoryProvider.future);
  final templateRepo = await ref.read(templateRepositoryProvider.future);
  final achievementRepo = ref.read(achievementRepositoryProvider);

  // Get stats
  final stats = await statsRepo.getStats();
  final streak = await statsRepo.getCurrentStreak();

  // Get sessions
  final sessions = sessionRepo.getAll();
  final completedSessions = sessions.where((s) => s.completedAt != null).toList();

  // Count by session type
  int deepSessions = 0;
  int pomodoroSessions = 0;
  int quickSessions = 0;
  final Set<String> energyRatings = {};

  for (final session in completedSessions) {
    switch (session.type) {
      case SessionType.deep:
        deepSessions++;
        break;
      case SessionType.pomodoro:
        pomodoroSessions++;
        break;
      case SessionType.open:
        quickSessions++;
        break;
      default:
        break;
    }
    if (session.energyLevel != null && session.energyLevel.index > 0) {
      energyRatings.add(session.energyLevel.name);
    }
  }

  // Get counts
  final tasks = taskRepo.getAll();
  final completedTasks = tasks.where((t) => t.completed).length;
  final notes = noteRepo.getAll();
  final templates = templateRepo.getAll();
  final unlockedAchievements = await achievementRepo.getUnlockedAchievements();

  return AchievementStats(
    totalSessions: completedSessions.length,
    totalTasks: completedTasks,
    currentStreak: streak,
    totalMinutes: stats.totalFocusMinutes,
    deepSessions: deepSessions,
    pomodoroSessions: pomodoroSessions,
    quickSessions: quickSessions,
    energyRatings: energyRatings,
    notesCount: notes.length,
    templatesCount: templates.length,
    unlockedCount: unlockedAchievements.length,
  );
});

// Achievement with progress data
class AchievementWithProgress {
  final AchievementDefinition definition;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;
  final int requirementValue;

  AchievementWithProgress({
    required this.definition,
    required this.isUnlocked,
    this.unlockedAt,
    required this.currentProgress,
    required this.requirementValue,
  });

  double get progress => requirementValue > 0 ? (currentProgress / requirementValue).clamp(0.0, 1.0) : 0.0;
  String get progressText => '$currentProgress / $requirementValue';
}

// All achievements with progress
final achievementsWithProgressProvider = FutureProvider<List<AchievementWithProgress>>((ref) async {
  final stats = await ref.watch(achievementStatsProvider.future);
  final unlockedAchievements = await ref.watch(achievementsProvider.future);
  final unlockedMap = {for (var a in unlockedAchievements) a.definitionId: a};

  return achievementsCatalog.map((def) {
    final unlocked = unlockedMap[def.id];
    final progress = def.getProgress(
      stats.totalSessions,
      stats.totalTasks,
      stats.currentStreak,
      stats.totalMinutes,
      stats.deepSessions,
      stats.pomodoroSessions,
      stats.quickSessions,
      stats.energyRatings,
      stats.notesCount,
      stats.templatesCount,
      stats.unlockedCount,
    );

    return AchievementWithProgress(
      definition: def,
      isUnlocked: unlocked != null,
      unlockedAt: unlocked?.unlockedAt,
      currentProgress: progress,
      requirementValue: def.requirementValue,
    );
  }).toList();
});

// Stats class to hold all computed stats
class AchievementStats {
  final int totalSessions;
  final int totalTasks;
  final int currentStreak;
  final int totalMinutes;
  final int deepSessions;
  final int pomodoroSessions;
  final int quickSessions;
  final Set<String> energyRatings;
  final int notesCount;
  final int templatesCount;
  final int unlockedCount;

  AchievementStats({
    required this.totalSessions,
    required this.totalTasks,
    required this.currentStreak,
    required this.totalMinutes,
    required this.deepSessions,
    required this.pomodoroSessions,
    required this.quickSessions,
    required this.energyRatings,
    required this.notesCount,
    required this.templatesCount,
    required this.unlockedCount,
  });
}

// Session types imported from enums.dart
class AchievementsNotifier extends AsyncNotifier<List<Achievement>> {
  AchievementRepository get _repo => ref.read(achievementRepositoryProvider);
  bool _isChecking = false;

  @override
  Future<List<Achievement>> build() async {
    return _repo.getUnlockedAchievements();
  }

  Future<Achievement?> checkAndUnlock({
    int? totalSessions,
    int? totalTasks,
    int? currentStreak,
    int? totalMinutes,
    int? deepSessions,
    int? pomodoroSessions,
    int? quickSessions,
    Set<String>? energyRatings,
    int? notesCount,
    int? templatesCount,
  }) async {
    // Prevent concurrent calls
    if (_isChecking) return null;
    _isChecking = true;

    try {
      final unlockedIds = (await state.value ?? []).map((a) => a.definitionId).toSet();
      final stats = await ref.read(achievementStatsProvider.future);

      for (final def in achievementsCatalog) {
        if (!unlockedIds.contains(def.id)) {
          final isUnlocked = def.isUnlocked(
            totalSessions ?? stats.totalSessions,
            totalTasks ?? stats.totalTasks,
            currentStreak ?? stats.currentStreak,
            totalMinutes ?? stats.totalMinutes,
            deepSessions ?? stats.deepSessions,
            pomodoroSessions ?? stats.pomodoroSessions,
            quickSessions ?? stats.quickSessions,
            energyRatings ?? stats.energyRatings,
            notesCount ?? stats.notesCount,
            templatesCount ?? stats.templatesCount,
            stats.unlockedCount,
          );

          if (isUnlocked) {
            await _repo.unlockAchievement(def.id);
            final newAchievement = Achievement(
              definitionId: def.id,
              unlockedAt: DateTime.now(),
            );
            final all = await _repo.getUnlockedAchievements();
            state = AsyncValue.data(all);
            // Invalidate stats to update progress
            ref.invalidate(achievementStatsProvider);
            return newAchievement;
          }
        }
      }
      return null;
    } finally {
      _isChecking = false;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    ref.invalidate(achievementStatsProvider);
  }
}

final achievementDefinitionsProvider = Provider<List<AchievementDefinition>>((ref) {
  return achievementsCatalog;
});
