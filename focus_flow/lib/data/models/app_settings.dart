class AppSettings {
  bool isDarkMode;
  bool soundEnabled;
  String? lastActiveDate;
  bool hasCompletedOnboarding;

  AppSettings({
    this.isDarkMode = false,
    this.soundEnabled = true,
    this.lastActiveDate,
    this.hasCompletedOnboarding = false,
  });

  AppSettings.create({
    this.isDarkMode = false,
    this.soundEnabled = true,
    this.lastActiveDate,
    this.hasCompletedOnboarding = false,
  });

  Map<String, dynamic> toJson() => {
    'isDarkMode': isDarkMode,
    'soundEnabled': soundEnabled,
    'lastActiveDate': lastActiveDate,
    'hasCompletedOnboarding': hasCompletedOnboarding,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    isDarkMode: json['isDarkMode'] ?? false,
    soundEnabled: json['soundEnabled'] ?? true,
    lastActiveDate: json['lastActiveDate'],
    hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
  );
}
