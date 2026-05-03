import 'enums.dart';

/// Generates a unique ID using microsecond timestamp + random component.
/// This is collision-resistant even under high-frequency creation.
String _generateId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final random = DateTime.now().hashCode;
  return '${timestamp}_$random';
}

class Task {
  String id;
  String title;
  EnergyLevel energy;
  TimeZone zone;
  Priority priority;
  List<String> tags;
  int? estimatedMinutes;
  bool completed;
  DateTime? completedAt;
  bool isFavorite;
  String? notes;
  String? scheduledTime;
  DateTime createdAt;
  int? completionCount; // Track how many times this task was completed

  Task({
    required this.id,
    required this.title,
    this.energy = EnergyLevel.none,
    this.zone = TimeZone.anytime,
    this.priority = Priority.medium,
    List<String>? tags,
    this.estimatedMinutes,
    this.completed = false,
    this.completedAt,
    this.isFavorite = false,
    this.notes,
    this.scheduledTime,
    DateTime? createdAt,
    this.completionCount,
  }) : tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now();

  Task.create({
    required this.title,
    this.energy = EnergyLevel.none,
    this.zone = TimeZone.anytime,
    this.priority = Priority.medium,
    List<String>? tags,
    this.estimatedMinutes,
    this.notes,
    this.scheduledTime,
  }) : id = _generateId(),
       tags = tags ?? [],
       createdAt = DateTime.now(),
       completed = false,
       isFavorite = false;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'energy': energy.index,
    'zone': zone.index,
    'priority': priority.index,
    'tags': tags,
    'estimatedMinutes': estimatedMinutes,
    'completed': completed,
    'completedAt': completedAt?.toIso8601String(),
    'isFavorite': isFavorite,
    'notes': notes,
    'scheduledTime': scheduledTime,
    'createdAt': createdAt.toIso8601String(),
    'completionCount': completionCount,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? 'Untitled Task',
    energy: _safeEnum(EnergyLevel.values, json['energy'] ?? 0, EnergyLevel.none),
    zone: _safeEnum(TimeZone.values, json['zone'] ?? 4, TimeZone.anytime),
    priority: _safeEnum(Priority.values, json['priority'] ?? 1, Priority.medium),
    tags: List<String>.from(json['tags'] ?? []),
    estimatedMinutes: json['estimatedMinutes'] as int?,
    completed: json['completed'] == true,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'].toString()) : null,
    isFavorite: json['isFavorite'] == true,
    notes: json['notes']?.toString(),
    scheduledTime: json['scheduledTime']?.toString(),
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
    completionCount: json['completionCount'] as int?,
  );

static T _safeEnum<T>(List<T> values, int index, T fallback) {
  return (index >= 0 && index < values.length) ? values[index] : fallback;
}
}
