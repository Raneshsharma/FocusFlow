import 'package:intl/intl.dart';

class DateUtils {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _displayDateFormat = DateFormat('EEEE, MMMM d');
  static final DateFormat _displayTimeFormat = DateFormat('h:mm a');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatTime(DateTime time) => _timeFormat.format(time);

  static String formatDisplayDate(DateTime date) => _displayDateFormat.format(date);

  static String formatDisplayTime(DateTime time) => _displayTimeFormat.format(time);

  static String getTodayString() => formatDate(DateTime.now());

  static DateTime parseDate(String date) => _dateFormat.parse(date);

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static String getCurrentTimeZone() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 18) return 'afternoon';
    return 'evening';
  }
}
