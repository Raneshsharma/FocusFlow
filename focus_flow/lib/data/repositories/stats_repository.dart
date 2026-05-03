import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/daily_stats.dart';
import '../../core/utils/date_helpers.dart';

class StatsRepository {
  static const String boxName = 'stats';
  final Box<String> _box;

  StatsRepository(this._box);

  static Future<StatsRepository> create() async {
    final box = await Hive.openBox<String>(boxName);
    return StatsRepository(box);
  }

  DailyStats getByDate(DateTime date) {
    final dateKey = formatDateKey(date);
    final json = _box.get(dateKey);
    if (json == null) {
      final stats = DailyStats.create(date: dateKey);
      _box.put(dateKey, jsonEncode(stats.toJson()));
      return stats;
    }
    return DailyStats.fromJson(jsonDecode(json));
  }

  List<DailyStats> getAll() {
    return _box.values.map((json) => DailyStats.fromJson(jsonDecode(json))).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Stream<BoxEvent> watchAll() {
    return _box.watch();
  }

  Future<void> incrementTasksCompleted(DateTime date) async {
    final stats = getByDate(date);
    stats.tasksCompleted++;
    await _box.put(stats.date, jsonEncode(stats.toJson()));
  }

  Future<void> incrementSessionsCompleted(DateTime date) async {
    final stats = getByDate(date);
    stats.sessionsCompleted++;
    await _box.put(stats.date, jsonEncode(stats.toJson()));
  }

  Future<void> addFocusMinutes(DateTime date, int minutes) async {
    final stats = getByDate(date);
    stats.focusMinutes += minutes;
    await _box.put(stats.date, jsonEncode(stats.toJson()));
  }

  Future<void> addStat(DailyStats stat) async {
    await _box.put(stat.date, jsonEncode(stat.toJson()));
  }

  List<DateTime> getActiveDates() {
    return getAll()
        .where((s) => s.tasksCompleted > 0 || s.sessionsCompleted > 0)
        .map((s) => parseDateKey(s.date) ?? DateTime.now())
        .toList();
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }

  /// Returns aggregated stats across all days
  Future<AggregatedStats> getStats() async {
    final allStats = getAll();
    int totalSessions = 0;
    int totalTasks = 0;
    int totalMinutes = 0;

    for (final stat in allStats) {
      totalSessions += stat.sessionsCompleted;
      totalTasks += stat.tasksCompleted;
      totalMinutes += stat.focusMinutes;
    }

    return AggregatedStats(
      totalSessions: totalSessions,
      totalTasksCompleted: totalTasks,
      totalFocusMinutes: totalMinutes,
    );
  }

  /// Calculates current streak based on active dates
  Future<int> getCurrentStreak() async {
    final dates = getActiveDates();
    if (dates.isEmpty) return 0;

    // Sort dates descending (most recent first)
    dates.sort((a, b) => b.compareTo(a));

    final today = getTodayStart();
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if streak is active (today or yesterday had activity)
    final mostRecent = dates.first;
    final mostRecentDate = getDateStart(mostRecent);

    if (mostRecentDate.isBefore(yesterday)) {
      return 0; // Streak broken
    }

    // Count consecutive days
    int streak = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      final current = getDateStart(dates[i]);
      final next = getDateStart(dates[i + 1]);

      final diff = current.difference(next).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Returns total focus minutes across all sessions
  int getTotalFocusMinutes() {
    final allStats = getAll();
    return allStats.fold<int>(0, (sum, stat) => sum + stat.focusMinutes);
  }
}

class AggregatedStats {
  final int totalSessions;
  final int totalTasksCompleted;
  final int totalFocusMinutes;

  AggregatedStats({
    required this.totalSessions,
    required this.totalTasksCompleted,
    required this.totalFocusMinutes,
  });
}
