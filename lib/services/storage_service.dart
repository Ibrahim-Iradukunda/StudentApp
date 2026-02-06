import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assignment.dart';
import '../models/academic_session.dart';

class StorageService {
  static const String _assignmentsKey = 'assignments';
  static const String _sessionsKey = 'sessions';
  static const String _userNameKey = 'userName';

  late SharedPreferences _prefs;

  /// Initialize the storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save assignments to storage
  Future<void> saveAssignments(List<Assignment> assignments) async {
    final jsonList = assignments.map((a) => jsonEncode(a.toJson())).toList();
    await _prefs.setStringList(_assignmentsKey, jsonList);
  }

  /// Load assignments from storage
  Future<List<Assignment>> loadAssignments() async {
    final jsonList = _prefs.getStringList(_assignmentsKey) ?? [];
    return jsonList.map((json) => Assignment.fromJson(jsonDecode(json))).toList();
  }

  /// Save academic sessions to storage
  Future<void> saveSessions(List<AcademicSession> sessions) async {
    final jsonList = sessions.map((s) => jsonEncode(s.toJson())).toList();
    await _prefs.setStringList(_sessionsKey, jsonList);
  }

  /// Load academic sessions from storage
  Future<List<AcademicSession>> loadSessions() async {
    final jsonList = _prefs.getStringList(_sessionsKey) ?? [];
    return jsonList.map((json) => AcademicSession.fromJson(jsonDecode(json))).toList();
  }

  /// Save user name
  Future<void> saveUserName(String userName) async {
    await _prefs.setString(_userNameKey, userName);
  }

  /// Load user name
  String? loadUserName() {
    return _prefs.getString(_userNameKey);
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
