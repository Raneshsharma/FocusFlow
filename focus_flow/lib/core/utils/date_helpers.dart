/// Centralized date formatting helpers to ensure consistency across the app.
/// All date-to-string conversions should use these functions.

/// Format a DateTime to a storage key string (yyyy-MM-dd).
/// Used as Hive box keys and for consistent date lookups.
String formatDateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Parse a date key string back to DateTime.
/// Returns null if the string is invalid.
DateTime? parseDateKey(String key) {
  try {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  } catch (e) {
    return null;
  }
}

/// Get today's date key string.
String getTodayKey() => formatDateKey(DateTime.now());

/// Get yesterday's date key string.
String getYesterdayKey() => formatDateKey(
  DateTime.now().subtract(const Duration(days: 1)),
);

/// Check if a DateTime is today.
bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
         date.month == now.month &&
         date.day == now.day;
}

/// Get start of today (midnight).
DateTime getTodayStart() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Get start of a given date (midnight).
DateTime getDateStart(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
