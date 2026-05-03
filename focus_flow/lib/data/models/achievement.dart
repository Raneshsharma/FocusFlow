enum AchievementTier { bronze, silver, gold, platinum }

enum RequirementType {
  totalSessions,
  totalTasks,
  currentStreak,
  totalMinutes,
  deepWorkSessions,
  pomodoroSessions,
  quickWinSessions,
  energyRatings,
  notesCreated,
  templatesSaved,
  achievementsUnlocked,
}

class Achievement {
  final String definitionId;
  final DateTime unlockedAt;

  Achievement({
    required this.definitionId,
    required this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
    'definitionId': definitionId,
    'unlockedAt': unlockedAt.toIso8601String(),
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    definitionId: json['definitionId'],
    unlockedAt: DateTime.parse(json['unlockedAt']),
  );
}

class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementTier tier;
  final RequirementType requirementType;
  final int requirementValue;
  final bool Function(int totalSessions, int totalTasks, int currentStreak, int totalMinutes, int deepSessions, int pomodoroSessions, int quickSessions, Set<String> energyRatings, int notesCount, int templatesCount, int unlockedCount) isUnlocked;
  final int Function(int totalSessions, int totalTasks, int currentStreak, int totalMinutes, int deepSessions, int pomodoroSessions, int quickSessions, Set<String> energyRatings, int notesCount, int templatesCount, int unlockedCount) getProgress;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tier,
    required this.requirementType,
    required this.requirementValue,
    required this.isUnlocked,
    required this.getProgress,
  });
}
