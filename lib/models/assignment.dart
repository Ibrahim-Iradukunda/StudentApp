class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String courseName;
  final Priority priority;
  bool isCompleted;
  final DateTime createdDate;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    this.priority = Priority.medium,
    this.isCompleted = false,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'courseName': courseName,
      'priority': priority.toString().split('.').last,
      'isCompleted': isCompleted,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      dueDate: DateTime.parse(json['dueDate']),
      courseName: json['courseName'],
      priority:
          Priority.values.firstWhere((e) => e.toString().split('.').last == json['priority']),
      isCompleted: json['isCompleted'] ?? false,
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  /// Create a copy with modified fields
  Assignment copyWith({
    String? title,
    DateTime? dueDate,
    String? courseName,
    Priority? priority,
    bool? isCompleted,
  }) {
    return Assignment(
      id: id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      courseName: courseName ?? this.courseName,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdDate: createdDate,
    );
  }
}

enum Priority { low, medium, high }

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  int get sortValue {
    switch (this) {
      case Priority.high:
        return 1;
      case Priority.medium:
        return 2;
      case Priority.low:
        return 3;
    }
  }
}
