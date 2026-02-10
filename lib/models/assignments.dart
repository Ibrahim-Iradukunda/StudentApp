class Assignment {
  String id;
  String title;
  DateTime dueDate;
  String courseName;
  String assignmentType;
  String? priority;
  bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    required this.assignmentType,
    this.priority,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'courseName': courseName,
      'assignmentType': assignmentType,
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
      assignmentType: json['assignmentType'] ?? 'Formative',
      priority: json['priority'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Assignment copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    String? courseName,
    String? assignmentType,
    String? priority,
    bool? isCompleted,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      courseName: courseName ?? this.courseName,
      assignmentType: assignmentType ?? this.assignmentType,
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
