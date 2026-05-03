import 'dart:convert';

enum ArchiveItemType { task, session, note, template }

enum ArchiveReason { completed, deleted, manual }

extension ArchiveItemTypeExtension on ArchiveItemType {
  String get displayName {
    switch (this) {
      case ArchiveItemType.task:
        return 'Task';
      case ArchiveItemType.session:
        return 'Session';
      case ArchiveItemType.note:
        return 'Note';
      case ArchiveItemType.template:
        return 'Template';
    }
  }

  String get emoji {
    switch (this) {
      case ArchiveItemType.task:
        return '✅';
      case ArchiveItemType.session:
        return '🎯';
      case ArchiveItemType.note:
        return '📝';
      case ArchiveItemType.template:
        return '🧩';
    }
  }

  String get icon {
    switch (this) {
      case ArchiveItemType.task:
        return 'check';
      case ArchiveItemType.session:
        return 'target';
      case ArchiveItemType.note:
        return 'note';
      case ArchiveItemType.template:
        return 'copy';
    }
  }
}

class ArchiveItem {
  final String id;
  final String originalId;
  final ArchiveItemType originalType;
  final Map<String, dynamic> originalData;
  final DateTime archivedAt;
  final ArchiveReason reason;
  final String? title; // Extracted for display

  ArchiveItem({
    required this.id,
    required this.originalId,
    required this.originalType,
    required this.originalData,
    required this.archivedAt,
    required this.reason,
    this.title,
  });

  ArchiveItem.create({
    required this.originalId,
    required this.originalType,
    required this.originalData,
    required this.reason,
    String? title,
  })  : id = DateTime.now().millisecondsSinceEpoch.toString(),
        archivedAt = DateTime.now(),
        title = title ?? _extractTitle(originalType, originalData);

  static String _extractTitle(ArchiveItemType type, Map<String, dynamic> data) {
    switch (type) {
      case ArchiveItemType.task:
        return data['title'] ?? 'Untitled Task';
      case ArchiveItemType.session:
        return data['taskTitle'] ?? data['type'] ?? 'Session';
      case ArchiveItemType.note:
        return data['content']?.toString().substring(0, 50.clamp(0, data['content'].toString().length)) ?? 'Untitled Note';
      case ArchiveItemType.template:
        return data['name'] ?? 'Untitled Template';
    }
  }

  String get displayTitle => title ?? 'Archived Item';

  String get preview {
    switch (originalType) {
      case ArchiveItemType.task:
        return 'Completed task';
      case ArchiveItemType.session:
        final duration = originalData['durationSeconds'] ?? 0;
        return '${duration ~/ 60} min session';
      case ArchiveItemType.note:
        final content = originalData['content'] ?? '';
        if (content.length > 60) {
          return '${content.substring(0, 60)}...';
        }
        return content;
      case ArchiveItemType.template:
        return 'Template with ${originalData['taskIds']?.length ?? 0} tasks';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'originalId': originalId,
    'originalType': originalType.index,
    'originalData': originalData,
    'archivedAt': archivedAt.toIso8601String(),
    'reason': reason.index,
    'title': title,
  };

  factory ArchiveItem.fromJson(Map<String, dynamic> json) => ArchiveItem(
    id: json['id'],
    originalId: json['originalId'],
    originalType: ArchiveItemType.values[json['originalType'] ?? 0],
    originalData: Map<String, dynamic>.from(json['originalData'] ?? {}),
    archivedAt: json['archivedAt'] != null ? DateTime.parse(json['archivedAt']) : DateTime.now(),
    reason: ArchiveReason.values[json['reason'] ?? 0],
    title: json['title'],
  );
}