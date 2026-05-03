class Note {
  String id;
  String content;
  List<String> tags; // ['idea', 'todo', 'remember', 'later', 'reflection']
  String? sessionId; // Linked session if applicable
  String? linkedTaskId; // Linked task if applicable
  bool isVoiceNote;
  bool isArchived;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.content,
    List<String>? tags,
    this.sessionId,
    this.linkedTaskId,
    this.isVoiceNote = false,
    this.isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Note.create({
    required this.content,
    List<String>? tags,
    this.sessionId,
    this.linkedTaskId,
    this.isVoiceNote = false,
    this.isArchived = false,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
       tags = tags ?? [],
       createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  bool hasTag(String tag) => tags.contains(tag);

  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  List<String> get displayTags => tags.isEmpty ? ['note'] : tags;

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'tags': tags,
    'sessionId': sessionId,
    'linkedTaskId': linkedTaskId,
    'isVoiceNote': isVoiceNote,
    'isArchived': isArchived,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    content: json['content'] ?? '',
    tags: List<String>.from(json['tags'] ?? []),
    sessionId: json['sessionId'],
    linkedTaskId: json['linkedTaskId'],
    isVoiceNote: json['isVoiceNote'] ?? false,
    isArchived: json['isArchived'] ?? false,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
  );
}

class NoteTags {
  static const String idea = 'idea';
  static const String todo = 'todo';
  static const String remember = 'remember';
  static const String later = 'later';
  static const String reflection = 'reflection';

  static List<String> get all => [idea, todo, remember, later, reflection];

  static String getLabel(String tag) {
    switch (tag) {
      case idea:
        return 'Idea';
      case todo:
        return 'Todo';
      case remember:
        return 'Remember';
      case later:
        return 'Later';
      case reflection:
        return 'Reflection';
      default:
        return tag;
    }
  }

  static String getEmoji(String tag) {
    switch (tag) {
      case idea:
        return '💡';
      case todo:
        return '✅';
      case remember:
        return '🔔';
      case later:
        return '⏰';
      case reflection:
        return '🧠';
      default:
        return '📝';
    }
  }
}
