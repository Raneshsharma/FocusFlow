enum AchievementTier { bronze, silver, gold, platinum }

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
  final bool Function(int totalSessions, int totalTasks, int currentStreak) isUnlocked;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tier,
    required this.isUnlocked,
  });
}
