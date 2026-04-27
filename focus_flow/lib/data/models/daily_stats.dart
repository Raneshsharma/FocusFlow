class DailyStats {
  String date;
  int tasksCompleted;
  int sessionsCompleted;
  int focusMinutes;

  DailyStats({
    required this.date,
    this.tasksCompleted = 0,
    this.sessionsCompleted = 0,
    this.focusMinutes = 0,
  });

  factory DailyStats.create({
    required String date,
    int tasksCompleted = 0,
    int sessionsCompleted = 0,
    int focusMinutes = 0,
  }) {
    return DailyStats(
      date: date,
      tasksCompleted: tasksCompleted,
      sessionsCompleted: sessionsCompleted,
      focusMinutes: focusMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'tasksCompleted': tasksCompleted,
    'sessionsCompleted': sessionsCompleted,
    'focusMinutes': focusMinutes,
  };

  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
    date: json['date'],
    tasksCompleted: json['tasksCompleted'] ?? 0,
    sessionsCompleted: json['sessionsCompleted'] ?? 0,
    focusMinutes: json['focusMinutes'] ?? 0,
  );
}
