import 'package:hive/hive.dart';

class DailyProgress {
  final String id; // date key YYYY-MM-DD
  int xpEarned;
  int tasksCompleted;
  int sessionsCompleted;
  List<String> achievementsUnlocked;

  DailyProgress({
    required this.id,
    this.xpEarned = 0,
    this.tasksCompleted = 0,
    this.sessionsCompleted = 0,
    this.achievementsUnlocked = const [],
  });

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DailyProgress forToday() {
    return DailyProgress(id: dateKey(DateTime.now()));
  }

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      id: json['id'] ?? '',
      xpEarned: json['xpEarned'] ?? 0,
      tasksCompleted: json['tasksCompleted'] ?? 0,
      sessionsCompleted: json['sessionsCompleted'] ?? 0,
      achievementsUnlocked: List<String>.from(json['achievementsUnlocked'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'xpEarned': xpEarned,
        'tasksCompleted': tasksCompleted,
        'sessionsCompleted': sessionsCompleted,
        'achievementsUnlocked': achievementsUnlocked,
      };

  DailyProgress copyWith({
    String? id,
    int? xpEarned,
    int? tasksCompleted,
    int? sessionsCompleted,
    List<String>? achievementsUnlocked,
  }) {
    return DailyProgress(
      id: id ?? this.id,
      xpEarned: xpEarned ?? this.xpEarned,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
    );
  }
}

class DailyProgressRepository {
  static const String _boxName = 'gamification';
  static const String _progressKey = 'daily_progress';

  Future<Box> get _box async => Hive.openBox(_boxName);

  Future<DailyProgress> getTodayProgress() async {
    final box = await _box;
    final todayKey = DailyProgress.dateKey(DateTime.now());
    final data = box.get(_progressKey);

    if (data != null && data is Map) {
      final progressMap = Map<String, dynamic>.from(data);
      if (progressMap.containsKey(todayKey)) {
        return DailyProgress.fromJson(
          Map<String, dynamic>.from(progressMap[todayKey]),
        );
      }
    }

    return DailyProgress.forToday();
  }

  Future<void> saveProgress(DailyProgress progress) async {
    final box = await _box;
    final data = box.get(_progressKey) ?? <String, dynamic>{};
    final progressMap = Map<String, dynamic>.from(data);

    progressMap[progress.id] = progress.toJson();

    await box.put(_progressKey, progressMap);
  }

  Future<void> addXp(int amount) async {
    final progress = await getTodayProgress();
    progress.xpEarned += amount;
    await saveProgress(progress);
  }

  Future<void> incrementTasks() async {
    final progress = await getTodayProgress();
    progress.tasksCompleted += 1;
    await saveProgress(progress);
  }

  Future<void> incrementSessions() async {
    final progress = await getTodayProgress();
    progress.sessionsCompleted += 1;
    await saveProgress(progress);
  }

  Future<void> addAchievement(String achievementId) async {
    final progress = await getTodayProgress();
    if (!progress.achievementsUnlocked.contains(achievementId)) {
      progress.achievementsUnlocked.add(achievementId);
      await saveProgress(progress);
    }
  }

  Future<List<DailyProgress>> getProgressForRange(DateTime start, DateTime end) async {
    final box = await _box;
    final data = box.get(_progressKey);
    final result = <DailyProgress>[];

    if (data != null && data is Map) {
      final progressMap = Map<String, dynamic>.from(data);
      for (final entry in progressMap.entries) {
        if (entry.key.compareTo(DailyProgress.dateKey(start)) >= 0 &&
            entry.key.compareTo(DailyProgress.dateKey(end)) <= 0) {
          result.add(DailyProgress.fromJson(Map<String, dynamic>.from(entry.value)));
        }
      }
    }

    return result;
  }
}