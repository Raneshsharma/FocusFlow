import 'package:flutter/material.dart';
import 'enums.dart';

class Template {
  String id;
  String name;
  List<String> taskIds;
  TimeZone zone;
  DateTime createdAt;
  int usageCount;
  TimeOfDay? bestTimeOfDay; // Best time of day to use this template
  int streakCount; // Number of times used consecutively
  DateTime? lastUsed;

  Template({
    required this.id,
    required this.name,
    List<String>? taskIds,
    this.zone = TimeZone.anytime,
    DateTime? createdAt,
    this.usageCount = 0,
    this.bestTimeOfDay,
    this.streakCount = 0,
    this.lastUsed,
  }) : taskIds = taskIds ?? [],
       createdAt = createdAt ?? DateTime.now();

  Template.create({
    required this.name,
    List<String>? taskIds,
    this.zone = TimeZone.anytime,
    this.usageCount = 0,
    this.bestTimeOfDay,
    this.streakCount = 0,
    this.lastUsed,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
       taskIds = taskIds ?? [],
       createdAt = DateTime.now();

  // Call when template is used to update streak and last used
  void recordUse() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastUsed != null) {
      final lastUsedDay = DateTime(lastUsed!.year, lastUsed!.month, lastUsed!.day);
      final difference = today.difference(lastUsedDay).inDays;

      if (difference == 1) {
        // Consecutive day - increment streak
        streakCount++;
      } else if (difference > 1) {
        // Streak broken - reset
        streakCount = 1;
      }
      // Same day - don't change streak
    } else {
      // First use
      streakCount = 1;
    }

    lastUsed = now;
    usageCount++;
  }

  // Get time of day category for sorting
  String get timeOfDayCategory {
    if (bestTimeOfDay == null) return 'anytime';
    final hour = bestTimeOfDay!.hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    if (hour < 21) return 'evening';
    return 'night';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'taskIds': taskIds,
    'zone': zone.index,
    'createdAt': createdAt.toIso8601String(),
    'usageCount': usageCount,
    'bestTimeOfDay': bestTimeOfDay != null
        ? {'hour': bestTimeOfDay!.hour, 'minute': bestTimeOfDay!.minute}
        : null,
    'streakCount': streakCount,
    'lastUsed': lastUsed?.toIso8601String(),
  };

  factory Template.fromJson(Map<String, dynamic> json) {
    TimeOfDay? tod;
    if (json['bestTimeOfDay'] is Map) {
      tod = TimeOfDay(
        hour: json['bestTimeOfDay']['hour'] ?? 0,
        minute: json['bestTimeOfDay']['minute'] ?? 0,
      );
    }

    return Template(
      id: json['id'],
      name: json['name'],
      taskIds: List<String>.from(json['taskIds'] ?? []),
      zone: _safeEnum(TimeZone.values, json['zone'] ?? 0, TimeZone.anytime),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      usageCount: json['usageCount'] ?? 0,
      bestTimeOfDay: tod,
      streakCount: json['streakCount'] ?? 0,
      lastUsed: json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
    );
  }

static T _safeEnum<T>(List<T> values, int index, T fallback) {
  return (index >= 0 && index < values.length) ? values[index] : fallback;
}
}
