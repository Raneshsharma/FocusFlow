import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/daily_stats.dart';

class StatsRepository {
  static const String boxName = 'stats';
  final Box<String> _box;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  StatsRepository(this._box);

  static Future<StatsRepository> create() async {
    final box = await Hive.openBox<String>(boxName);
    return StatsRepository(box);
  }

  DailyStats getByDate(DateTime date) {
    final dateStr = _dateFormat.format(date);
    final json = _box.get(dateStr);
    if (json == null) {
      final stats = DailyStats.create(date: dateStr);
      _box.put(dateStr, jsonEncode(stats.toJson()));
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
        .map((s) => _dateFormat.parse(s.date))
        .toList();
  }

  Future<void> deleteAll() async {
    await _box.clear();
  }
}
