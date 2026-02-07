class AcademicSession {
  final String id;
  final String title;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final SessionType type;
  bool? isAttended; // null = not yet, true = present, false = absent
  final String? notes;
  final DateTime createdDate;

  AcademicSession({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    this.type = SessionType.classSession,
    this.isAttended,
    this.notes,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'type': type.toString().split('.').last,
      'isAttended': isAttended,
      'notes': notes,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  /// Create from JSON
  factory AcademicSession.fromJson(Map<String, dynamic> json) {
    return AcademicSession(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'],
      type: SessionType.values
          .firstWhere((e) => e.toString().split('.').last == json['type']),
      isAttended: json['isAttended'],
      notes: json['notes'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  /// Create a copy with modified fields
  AcademicSession copyWith({
    String? title,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    SessionType? type,
    bool? isAttended,
    String? notes,
  }) {
    return AcademicSession(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      type: type ?? this.type,
      isAttended: isAttended ?? this.isAttended,
      notes: notes ?? this.notes,
      createdDate: createdDate,
    );
  }
}

enum SessionType { classSession, masterySession, studyGroup, pslMeeting }

extension SessionTypeExtension on SessionType {
  String get label {
    switch (this) {
      case SessionType.classSession:
        return 'Class';
      case SessionType.masterySession:
        return 'Mastery Session';
      case SessionType.studyGroup:
        return 'Study Group';
      case SessionType.pslMeeting:
        return 'PSL Meeting';
    }
  }

  String get icon {
    switch (this) {
      case SessionType.classSession:
        return '📚';
      case SessionType.masterySession:
        return '⭐';
      case SessionType.studyGroup:
        return '👥';
      case SessionType.pslMeeting:
        return '📍';
    }
  }
}
