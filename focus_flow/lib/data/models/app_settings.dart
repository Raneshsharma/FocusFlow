class PomodoroTimerSettings {
  int workMinutes;
  int shortBreakMinutes;
  int longBreakMinutes;
  int roundsBeforeLongBreak;
  bool autoStartBreaks;
  bool autoStartWork;

  PomodoroTimerSettings({
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.roundsBeforeLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartWork = false,
  });

  Map<String, dynamic> toJson() => {
    'workMinutes': workMinutes,
    'shortBreakMinutes': shortBreakMinutes,
    'longBreakMinutes': longBreakMinutes,
    'roundsBeforeLongBreak': roundsBeforeLongBreak,
    'autoStartBreaks': autoStartBreaks,
    'autoStartWork': autoStartWork,
  };

  factory PomodoroTimerSettings.fromJson(Map<String, dynamic> json) =>
      PomodoroTimerSettings(
        workMinutes: json['workMinutes'] ?? 25,
        shortBreakMinutes: json['shortBreakMinutes'] ?? 5,
        longBreakMinutes: json['longBreakMinutes'] ?? 15,
        roundsBeforeLongBreak: json['roundsBeforeLongBreak'] ?? 4,
        autoStartBreaks: json['autoStartBreaks'] ?? false,
        autoStartWork: json['autoStartWork'] ?? false,
      );
}

class NotificationSettings {
  bool enabled;
  bool sessionEndNotify;
  bool breakEndNotify;
  bool dailyReminderNotify;
  String? dailyReminderTime;

  NotificationSettings({
    this.enabled = true,
    this.sessionEndNotify = true,
    this.breakEndNotify = true,
    this.dailyReminderNotify = false,
    this.dailyReminderTime,
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'sessionEndNotify': sessionEndNotify,
    'breakEndNotify': breakEndNotify,
    'dailyReminderNotify': dailyReminderNotify,
    'dailyReminderTime': dailyReminderTime,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        enabled: json['enabled'] ?? true,
        sessionEndNotify: json['sessionEndNotify'] ?? true,
        breakEndNotify: json['breakEndNotify'] ?? true,
        dailyReminderNotify: json['dailyReminderNotify'] ?? false,
        dailyReminderTime: json['dailyReminderTime'],
      );
}

class DisplaySettings {
  String fontFamily;
  double fontScale;
  bool reduceMotion;
  bool hapticFeedback;

  DisplaySettings({
    this.fontFamily = 'Inter',
    this.fontScale = 1.0,
    this.reduceMotion = false,
    this.hapticFeedback = true,
  });

  Map<String, dynamic> toJson() => {
    'fontFamily': fontFamily,
    'fontScale': fontScale,
    'reduceMotion': reduceMotion,
    'hapticFeedback': hapticFeedback,
  };

  factory DisplaySettings.fromJson(Map<String, dynamic> json) =>
      DisplaySettings(
        fontFamily: json['fontFamily'] ?? 'Inter',
        fontScale: (json['fontScale'] ?? 1.0).toDouble(),
        reduceMotion: json['reduceMotion'] ?? false,
        hapticFeedback: json['hapticFeedback'] ?? true,
      );
}

class AppSettings {
  bool isDarkMode;
  bool soundEnabled;
  String? lastActiveDate;
  bool hasCompletedOnboarding;
  PomodoroTimerSettings pomodoro;
  NotificationSettings notifications;
  DisplaySettings display;

  AppSettings({
    this.isDarkMode = false,
    this.soundEnabled = true,
    this.lastActiveDate,
    this.hasCompletedOnboarding = false,
    PomodoroTimerSettings? pomodoro,
    NotificationSettings? notifications,
    DisplaySettings? display,
  })  : pomodoro = pomodoro ?? PomodoroTimerSettings(),
        notifications = notifications ?? NotificationSettings(),
        display = display ?? DisplaySettings();

  Map<String, dynamic> toJson() => {
    'isDarkMode': isDarkMode,
    'soundEnabled': soundEnabled,
    'lastActiveDate': lastActiveDate,
    'hasCompletedOnboarding': hasCompletedOnboarding,
    'pomodoro': pomodoro.toJson(),
    'notifications': notifications.toJson(),
    'display': display.toJson(),
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    isDarkMode: json['isDarkMode'] ?? false,
    soundEnabled: json['soundEnabled'] ?? true,
    lastActiveDate: json['lastActiveDate'],
    hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
    pomodoro: json['pomodoro'] != null
        ? PomodoroTimerSettings.fromJson(json['pomodoro'])
        : null,
    notifications: json['notifications'] != null
        ? NotificationSettings.fromJson(json['notifications'])
        : null,
    display: json['display'] != null
        ? DisplaySettings.fromJson(json['display'])
        : null,
  );

  AppSettings copyWith({
    bool? isDarkMode,
    bool? soundEnabled,
    String? lastActiveDate,
    bool? hasCompletedOnboarding,
    PomodoroTimerSettings? pomodoro,
    NotificationSettings? notifications,
    DisplaySettings? display,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      pomodoro: pomodoro ?? this.pomodoro,
      notifications: notifications ?? this.notifications,
      display: display ?? this.display,
    );
  }
}