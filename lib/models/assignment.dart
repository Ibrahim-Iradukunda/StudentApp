import 'dart:convert';

/// Model class representing an academic assignment.
/// Stores all details needed for assignment tracking including
/// title, due date, course, priority, and completion status.
class Assignment {
  String id;
  String title;
  DateTime dueDate;
  String course;
  String priority; // 'High', 'Medium', 'Low'
  bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.course,
    this.priority = 'Medium',
    this.isCompleted = false,
  });

  /// Converts the Assignment object to a JSON-compatible Map.
  /// Used for serialization when saving to shared_preferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'course': course,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  /// Creates an Assignment object from a JSON Map.
  /// Used for deserialization when loading from shared_preferences.
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      course: json['course'] as String,
      priority: json['priority'] as String? ?? 'Medium',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Helper to check if assignment is due within the next N days
  bool isDueWithinDays(int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = deadline.difference(today).inDays;
    return difference >= 0 && difference <= days;
  }

  /// Checks if the assignment is overdue
  bool get isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return deadline.isBefore(today) && !isCompleted;
  }
}
