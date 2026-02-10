class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String courseName;
  bool isCompleted;
  final DateTime createdDate;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.courseName,
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
      isCompleted: json['isCompleted'] ?? false,
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  /// Create a copy with modified fields
  Assignment copyWith({
    String? title,
    DateTime? dueDate,
    String? courseName,
    bool? isCompleted,
  }) {
    return Assignment(
      id: id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      courseName: courseName ?? this.courseName,
      isCompleted: isCompleted ?? this.isCompleted,
      createdDate: createdDate,
    );
  }
}
