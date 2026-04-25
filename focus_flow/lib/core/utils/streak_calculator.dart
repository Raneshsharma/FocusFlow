class StreakCalculator {
  static StreakData calculate(List<DateTime> activeDates) {
    if (activeDates.isEmpty) {
      return StreakData(current: 0, longest: 0, totalDays: activeDates.length);
    }

    // Sort dates descending
    final sorted = List<DateTime>.from(activeDates)
      ..sort((a, b) => b.compareTo(a));

    final uniqueDays = <String>{};
    for (final date in sorted) {
      uniqueDays.add('${date.year}-${date.month}-${date.day}');
    }

    final sortedUnique = uniqueDays.toList()..sort((a, b) => b.compareTo(a));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Calculate current streak
    if (sortedUnique.isNotEmpty) {
      final mostRecent = sortedUnique.first;
      final parts = mostRecent.split('-');
      final mostRecentDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      if (mostRecentDate == today || mostRecentDate == yesterday) {
        currentStreak = 1;
        for (int i = 1; i < sortedUnique.length; i++) {
          final prev = sortedUnique[i - 1].split('-');
          final curr = sortedUnique[i].split('-');
          final prevDate = DateTime(int.parse(prev[0]), int.parse(prev[1]), int.parse(prev[2]));
          final currDate = DateTime(int.parse(curr[0]), int.parse(curr[1]), int.parse(curr[2]));

          if (prevDate.difference(currDate).inDays == 1) {
            currentStreak++;
          } else {
            break;
          }
        }
      }
    }

    // Calculate longest streak
    for (int i = 1; i < sortedUnique.length; i++) {
      final prev = sortedUnique[i - 1].split('-');
      final curr = sortedUnique[i].split('-');
      final prevDate = DateTime(int.parse(prev[0]), int.parse(prev[1]), int.parse(prev[2]));
      final currDate = DateTime(int.parse(curr[0]), int.parse(curr[1]), int.parse(curr[2]));

      if (prevDate.difference(currDate).inDays == 1) {
        tempStreak++;
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return StreakData(
      current: currentStreak,
      longest: longestStreak > currentStreak ? longestStreak : currentStreak,
      totalDays: uniqueDays.length,
    );
  }
}

class StreakData {
  final int current;
  final int longest;
  final int totalDays;

  StreakData({
    required this.current,
    required this.longest,
    required this.totalDays,
  });
}
