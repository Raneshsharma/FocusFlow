enum ResourceCategory {
  article, // Blog posts, tutorials, guides
  tool,    // Apps, extensions, software
  video,   // YouTube, courses, recordings
  course,  // Paid courses, bootcamps
}

extension ResourceCategoryExtension on ResourceCategory {
  String get label {
    switch (this) {
      case ResourceCategory.article:
        return 'Article';
      case ResourceCategory.tool:
        return 'Tool';
      case ResourceCategory.video:
        return 'Video';
      case ResourceCategory.course:
        return 'Course';
    }
  }

  String get icon {
    switch (this) {
      case ResourceCategory.article:
        return '📄';
      case ResourceCategory.tool:
        return '🛠️';
      case ResourceCategory.video:
        return '🎥';
      case ResourceCategory.course:
        return '📚';
    }
  }
}

class Resource {
  String id;
  String title;
  String url;
  DateTime createdAt;
  ResourceCategory category; // Article, Tool, Video, Course
  String? notes; // Personal notes about this resource
  bool readLaterQueue; // Queue for low-energy consumption

  Resource({
    required this.id,
    required this.title,
    required this.url,
    DateTime? createdAt,
    this.category = ResourceCategory.article,
    this.notes,
    this.readLaterQueue = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Resource.create({
    required this.title,
    required this.url,
    this.category = ResourceCategory.article,
    this.notes,
    this.readLaterQueue = false,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'createdAt': createdAt.toIso8601String(),
    'category': category.index,
    'notes': notes,
    'readLaterQueue': readLaterQueue,
  };

  factory Resource.fromJson(Map<String, dynamic> json) => Resource(
    id: json['id'],
    title: json['title'],
    url: json['url'],
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    category: ResourceCategory.values[json['category'] ?? 0],
    notes: json['notes'],
    readLaterQueue: json['readLaterQueue'] ?? false,
  );
}
