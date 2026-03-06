enum NoteCategory {
  bugFix,
  newFeature,
}

extension NoteCategoryExtension on NoteCategory {
  String get label {
    switch (this) {
      case NoteCategory.bugFix:
        return 'Hata Düzeltme';
      case NoteCategory.newFeature:
        return 'Yeni Özellik';
    }
  }

  String get color {
    switch (this) {
      case NoteCategory.bugFix:
        return 'red';
      case NoteCategory.newFeature:
        return 'green';
    }
  }
}

enum NotePriority {
  low,
  medium,
  high,
}

extension NotePriorityExtension on NotePriority {
  String get label {
    switch (this) {
      case NotePriority.low:
        return 'Düşük';
      case NotePriority.medium:
        return 'Orta';
      case NotePriority.high:
        return 'Yüksek';
    }
  }
}

class Note {
  final String id;
  final String projectId;
  final String content;
  final NoteCategory category;
  final NotePriority priority;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.projectId,
    required this.content,
    required this.category,
    required this.priority,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'content': content,
      'category': category.index,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      projectId: map['projectId'],
      content: map['content'],
      category: NoteCategory.values[map['category']],
      priority: NotePriority.values[map['priority']],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
