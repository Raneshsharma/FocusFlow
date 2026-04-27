import 'package:hive/hive.dart';

class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  static const String _boxName = 'streak_data';
  static const String _lastActiveKey = 'last_active_date';
  static const String _currentStreakKey = 'current_streak';
  static const String _longestStreakKey = 'longest_streak';

  Future<Box> get _box async => Hive.openBox(_boxName);

  Future<StreakResult> checkStreakStatus() async {
    final box = await _box;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final todayKey = _dateKey(today);
    final yesterdayKey = _dateKey(yesterday);

    final lastActiveKey = box.get(_lastActiveKey);
    final currentStreak = box.get(_currentStreakKey, defaultValue: 0) as int;
    final longestStreak = box.get(_longestStreakKey, defaultValue: 0) as int;

    // Get active dates from stats to check if today or yesterday has activity
    final statsBox = await Hive.openBox<String>('stats');
    final keys = statsBox.keys.map((k) => k.toString()).toSet();

    bool hasTodayActivity = keys.contains(todayKey);
    bool hasYesterdayActivity = keys.contains(yesterdayKey);

    if (hasTodayActivity) {
      // Streak continues or increments
      final newStreak = currentStreak + 1;
      final newLongest = newStreak > longestStreak ? newStreak : longestStreak;

      await box.put(_lastActiveKey, todayKey);
      await box.put(_currentStreakKey, newStreak);
      await box.put(_longestStreakKey, newLongest);

      return StreakResult(
        currentStreak: newStreak,
        longestStreak: newLongest,
        lastActiveDate: today,
        isGraceDay: false,
        wasBroken: false,
      );
    } else if (hasYesterdayActivity) {
      // Grace day - streak frozen but not lost
      return StreakResult(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastActiveDate: yesterday,
        isGraceDay: true,
        wasBroken: false,
      );
    } else {
      // Streak lost
      return StreakResult(
        currentStreak: 0,
        longestStreak: longestStreak,
        lastActiveDate: lastActiveKey != null ? _parseDate(lastActiveKey) : null,
        isGraceDay: false,
        wasBroken: currentStreak > 0,
      );
    }
  }

  Future<void> recordActivity(DateTime date) async {
    final box = await _box;
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final yesterdayKey = _dateKey(today.subtract(const Duration(days: 1)));
    final activityDateKey = _dateKey(date);

    // Only record if it's today or yesterday
    if (activityDateKey != todayKey && activityDateKey != yesterdayKey) {
      return;
    }

    final lastActiveKey = box.get(_lastActiveKey);
    final currentStreak = box.get(_currentStreakKey, defaultValue: 0) as int;
    final longestStreak = box.get(_longestStreakKey, defaultValue: 0) as int;

    if (activityDateKey == todayKey) {
      // Increment streak
      final newStreak = currentStreak + 1;
      final newLongest = newStreak > longestStreak ? newStreak : longestStreak;

      await box.put(_lastActiveKey, todayKey);
      await box.put(_currentStreakKey, newStreak);
      await box.put(_longestStreakKey, newLongest);
    } else if (activityDateKey == yesterdayKey && lastActiveKey != todayKey) {
      // Grace day - user was active yesterday but not today yet
      // This maintains the streak when starting a new day
      final newStreak = currentStreak + 1;
      final newLongest = newStreak > longestStreak ? newStreak : longestStreak;

      await box.put(_lastActiveKey, yesterdayKey);
      await box.put(_currentStreakKey, newStreak);
      await box.put(_longestStreakKey, newLongest);
    }
  }

  Future<StreakData> getStreakData() async {
    final box = await _box;
    return StreakData(
      current: box.get(_currentStreakKey, defaultValue: 0) as int,
      longest: box.get(_longestStreakKey, defaultValue: 0) as int,
    );
  }

  Future<void> resetStreak() async {
    final box = await _box;
    await box.put(_currentStreakKey, 0);
    await box.put(_lastActiveKey, null);
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String key) {
    try {
      final parts = key.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (e) {
      return null;
    }
  }
}

class StreakResult {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final bool isGraceDay;
  final bool wasBroken;

  StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActiveDate,
    this.isGraceDay = false,
    this.wasBroken = false,
  });

  bool get hasActiveStreak => currentStreak > 0 && !isGraceDay;
  bool get needsEncouragement => wasBroken || isGraceDay;
}

class StreakData {
  final int current;
  final int longest;

  StreakData({
    required this.current,
    required this.longest,
  });

  bool get hasStreak => current > 0;
}