import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assignment.dart';
import '../models/session.dart';

/// StorageHelper provides methods to persist and retrieve
/// assignments and sessions using shared_preferences.
/// Data is stored as JSON strings under dedicated keys.
class StorageHelper {
  // Keys for shared_preferences storage
  static const String _assignmentsKey = 'alu_assignments';
  static const String _sessionsKey = 'alu_sessions';

  // ==================== ASSIGNMENTS ====================

  /// Saves the full list of assignments to shared_preferences.
  /// Converts each Assignment to JSON, then stores as a JSON string list.
  static Future<void> saveAssignments(List<Assignment> assignments) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = assignments.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_assignmentsKey, jsonList);
  }

  /// Loads all assignments from shared_preferences.
  /// Returns an empty list if no data is stored yet.
  static Future<List<Assignment>> loadAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_assignmentsKey);
    if (jsonList == null) return [];

    return jsonList.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Assignment.fromJson(map);
    }).toList();
  }

  // ==================== SESSIONS ====================

  /// Saves the full list of sessions to shared_preferences.
  /// Converts each Session to JSON, then stores as a JSON string list.
  static Future<void> saveSessions(List<Session> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = sessions.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_sessionsKey, jsonList);
  }

  /// Loads all sessions from shared_preferences.
  /// Returns an empty list if no data is stored yet.
  static Future<List<Session>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_sessionsKey);
    if (jsonList == null) return [];

    return jsonList.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Session.fromJson(map);
    }).toList();
  }

  /// Clears all stored data (useful for testing or reset)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_assignmentsKey);
    await prefs.remove(_sessionsKey);
  }
}
