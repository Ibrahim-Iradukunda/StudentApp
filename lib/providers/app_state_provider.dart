import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/assignment.dart';
import '../models/academic_session.dart';

class AppStateProvider with ChangeNotifier {
  List<Assignment> _assignments = [];
  List<AcademicSession> _sessions = [];
  late SharedPreferences _prefs;

  List<Assignment> get assignments => _assignments;
  List<AcademicSession> get sessions => _sessions;

  /// Get assignments due within the next 7 days
  List<Assignment> get upcomingAssignments {
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));
    return _assignments
        .where((a) => a.dueDate.isAfter(now) && a.dueDate.isBefore(sevenDaysLater))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Get today's sessions
  List<AcademicSession> get todaySessions {
    final today = DateTime.now();
    return _sessions
        .where((s) =>
            s.date.year == today.year &&
            s.date.month == today.month &&
            s.date.day == today.day)
        .toList();
  }

  /// Calculate attendance percentage
  double get attendancePercentage {
    if (_sessions.isEmpty) return 100.0;
    final attended =
        _sessions.where((s) => s.isAttended == true).length;
    return (attended / _sessions.length) * 100;
  }

  /// Initialize and load data
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
  }

  /// Load data from shared preferences
  Future<void> _loadData() async {
    try {
      final assignmentsJson = _prefs.getStringList('assignments') ?? [];
      final sessionsJson = _prefs.getStringList('sessions') ?? [];

      _assignments = assignmentsJson
          .map((json) => Assignment.fromJson(jsonDecode(json)))
          .toList();
      _sessions = sessionsJson
          .map((json) => AcademicSession.fromJson(jsonDecode(json)))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  /// Save data to shared preferences
  Future<void> _saveData() async {
    try {
      await _prefs.setStringList(
        'assignments',
        _assignments.map((a) => jsonEncode(a.toJson())).toList(),
      );
      await _prefs.setStringList(
        'sessions',
        _sessions.map((s) => jsonEncode(s.toJson())).toList(),
      );
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  /// Add assignment
  Future<void> addAssignment(Assignment assignment) async {
    _assignments.add(assignment);
    _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    await _saveData();
    notifyListeners();
  }

  /// Update assignment
  Future<void> updateAssignment(Assignment assignment) async {
    final index = _assignments.indexWhere((a) => a.id == assignment.id);
    if (index != -1) {
      _assignments[index] = assignment;
      _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      await _saveData();
      notifyListeners();
    }
  }

  /// Delete assignment
  Future<void> deleteAssignment(String id) async {
    _assignments.removeWhere((a) => a.id == id);
    await _saveData();
    notifyListeners();
  }

  /// Add session
  Future<void> addSession(AcademicSession session) async {
    _sessions.add(session);
    _sessions.sort((a, b) => a.date.compareTo(b.date));
    await _saveData();
    notifyListeners();
  }

  /// Update session
  Future<void> updateSession(AcademicSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
      _sessions.sort((a, b) => a.date.compareTo(b.date));
      await _saveData();
      notifyListeners();
    }
  }

  /// Toggle attendance for session
  Future<void> toggleAttendance(String sessionId) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final session = _sessions[index];
      session.isAttended = !(session.isAttended ?? false);
      await _saveData();
      notifyListeners();
    }
  }

  /// Delete session
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    await _saveData();
    notifyListeners();
  }
}
