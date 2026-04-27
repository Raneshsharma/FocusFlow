class AppConstants {
  // Timer durations (in seconds)
  static const int pomodoroWork = 25 * 60;      // 25 minutes
  static const int pomodoroShortBreak = 5 * 60; // 5 minutes
  static const int pomodoroLongBreak = 15 * 60;  // 15 minutes
  static const int deepWork = 50 * 60;          // 50 minutes

  // Pomodoro
  static const int pomodoroRounds = 4;

  // Breathing patterns (in seconds)
  static const int boxBreathDuration = 4;
  static const int breathing478Inhale = 4;
  static const int breathing478Hold = 7;
  static const int breathing478Exhale = 8;

  // Time zone hour ranges
  static const int morningStart = 5;
  static const int morningEnd = 12;
  static const int afternoonStart = 12;
  static const int afternoonEnd = 18;
  static const int eveningStart = 18;
  static const int eveningEnd = 24;

  // UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration toastDuration = Duration(seconds: 3);

  // XP values per action
  static const int xpPerTask = 10;
  static const int xpPerSession = 25;
  static const int xpPerDeepSession = 50;
  static const int xpPerStreakDay = 15;

  // Level thresholds
  static const int xpPerLevel = 100;
}
