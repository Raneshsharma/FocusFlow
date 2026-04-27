import 'enums.dart';

enum MoodTag {
  great,    // '🔥' — Flow state, everything clicked
  good,     // '😊' — Productive session
  okay,     // '😐' — Decent session
  struggled // '😓' — Hard to focus, still showed up
}

extension MoodTagExtension on MoodTag {
  String get emoji {
    switch (this) {
      case MoodTag.great:
        return '🔥';
      case MoodTag.good:
        return '😊';
      case MoodTag.okay:
        return '😐';
      case MoodTag.struggled:
        return '😓';
    }
  }

  String get label {
    switch (this) {
      case MoodTag.great:
        return 'Great focus';
      case MoodTag.good:
        return 'Good session';
      case MoodTag.okay:
        return 'Okay';
      case MoodTag.struggled:
        return 'Struggled';
    }
  }
}

class FlowSession {
  String id;
  String? taskId;
  String? taskTitle; // Denormalized task title for display after session
  SessionType type;
  DateTime? startedAt;
  int durationSeconds;
  DateTime? completedAt;
  String? reflection;
  EnergyLevel energyLevel;
  MoodTag? moodTag; // Optional mood after session

  FlowSession({
    required this.id,
    this.taskId,
    this.taskTitle,
    this.type = SessionType.open,
    this.startedAt,
    this.durationSeconds = 0,
    this.completedAt,
    this.reflection,
    this.energyLevel = EnergyLevel.none,
    this.moodTag,
  });

  FlowSession.create({
    this.taskId,
    this.taskTitle,
    this.type = SessionType.open,
    this.startedAt,
    this.durationSeconds = 0,
    this.completedAt,
    this.reflection,
    this.energyLevel = EnergyLevel.none,
    this.moodTag,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'taskId': taskId,
    'taskTitle': taskTitle,
    'type': type.index,
    'startedAt': startedAt?.toIso8601String(),
    'durationSeconds': durationSeconds,
    'completedAt': completedAt?.toIso8601String(),
    'reflection': reflection,
    'energyLevel': energyLevel.index,
    'moodTag': moodTag?.index,
  };

  factory FlowSession.fromJson(Map<String, dynamic> json) => FlowSession(
    id: json['id'],
    taskId: json['taskId'],
    taskTitle: json['taskTitle'],
    type: SessionType.values[json['type'] ?? 0],
    startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
    durationSeconds: json['durationSeconds'] ?? 0,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    reflection: json['reflection'],
    energyLevel: EnergyLevel.values[json['energyLevel'] ?? 0],
    moodTag: json['moodTag'] != null ? MoodTag.values[json['moodTag']] : null,
  );
}
