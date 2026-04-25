import 'enums.dart';

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
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
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
    id: json['id'],
    title: json['title'],
    energy: EnergyLevel.values[json['energy'] ?? 0],
    zone: TimeZone.values[json['zone'] ?? 0],
    priority: Priority.values[json['priority'] ?? 1],
    tags: List<String>.from(json['tags'] ?? []),
    estimatedMinutes: json['estimatedMinutes'],
    completed: json['completed'] ?? false,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    isFavorite: json['isFavorite'] ?? false,
    notes: json['notes'],
    scheduledTime: json['scheduledTime'],
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    completionCount: json['completionCount'],
  );
}
