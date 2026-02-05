import 'dart:convert';

/// Model class representing an academic session.
/// Stores session details such as title, date, time range,
/// location, type, and attendance status.
class Session {
  String id;
  String title;
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  String location;
  String sessionType; // 'Class', 'Mastery Session', 'Study Group', 'PSL Meeting'
  bool? isPresent; // null = not recorded, true = present, false = absent

  Session({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location = '',
    required this.sessionType,
    this.isPresent,
  });

  /// Converts the Session object to a JSON-compatible Map.
  /// Used for serialization when saving to shared_preferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'sessionType': sessionType,
      'isPresent': isPresent,
    };
  }

  /// Creates a Session object from a JSON Map.
  /// Used for deserialization when loading from shared_preferences.
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String? ?? '',
      sessionType: json['sessionType'] as String,
      isPresent: json['isPresent'] as bool?,
    );
  }

  /// Checks if the session falls on the given date
  bool isOnDate(DateTime targetDate) {
    return date.year == targetDate.year &&
        date.month == targetDate.month &&
        date.day == targetDate.day;
  }

  /// Checks if the session is today
  bool get isToday {
    final now = DateTime.now();
    return isOnDate(now);
  }

  /// Returns a formatted time range string (e.g., "09:00 AM - 10:30 AM")
  String get formattedTimeRange {
    String formatTime(DateTime dt) {
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    }

    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }
}
