/// Assignment Model - Represents a single assignment
///
/// Author: [Yvette Uwimpaye] ← PUT YOUR NAME HERE
/// Branch: assignments-feature
class Assignment {
  String id;
  String title;
  DateTime dueDate;
  String courseName;
  String? priority;
  bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    this.priority,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'courseName': courseName,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      dueDate: DateTime.parse(json['dueDate']),
      courseName: json['courseName'],
      priority: json['priority'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Assignment copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    String? courseName,
    String? priority,
    bool? isCompleted,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      courseName: courseName ?? this.courseName,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  bool isDueWithinSevenDays() {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference >= 0 && difference <= 7;
  }

  bool isOverdue() {
    final now = DateTime.now();
    return dueDate.isBefore(now) && !isCompleted;
  }
}
