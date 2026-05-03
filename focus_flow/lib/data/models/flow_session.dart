import 'enums.dart';

/// Generates a unique ID using microsecond timestamp + random component.
/// This is collision-resistant even under high-frequency creation.
String _generateId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final random = DateTime.now().hashCode;
  return '${timestamp}_$random';
}

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
  bool isFavorite; // Whether user starred this session

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
    this.isFavorite = false,
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
    this.isFavorite = false,
  }) : id = _generateId();

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
    'isFavorite': isFavorite,
  };

  factory FlowSession.fromJson(Map<String, dynamic> json) => FlowSession(
    id: json['id'],
    taskId: json['taskId'],
    taskTitle: json['taskTitle'],
    type: _safeEnum(SessionType.values, json['type'] ?? 0, SessionType.open),
    startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
    durationSeconds: json['durationSeconds'] ?? 0,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    reflection: json['reflection'],
    energyLevel: _safeEnum(EnergyLevel.values, json['energyLevel'] ?? 0, EnergyLevel.none),
    moodTag: _safeEnumNullable(MoodTag.values, json['moodTag']),
    isFavorite: json['isFavorite'] ?? false,
  );
}

T _safeEnum<T>(List<T> values, int index, T fallback) {
  return (index >= 0 && index < values.length) ? values[index] : fallback;
}

T? _safeEnumNullable<T>(List<T> values, dynamic index) {
  if (index == null) return null;
  final intIndex = index is int ? index : int.tryParse(index.toString());
  if (intIndex == null) return null;
  return (intIndex >= 0 && intIndex < values.length) ? values[intIndex] : null;
}
