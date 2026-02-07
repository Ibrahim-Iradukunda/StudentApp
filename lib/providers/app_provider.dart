import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../models/academic_session.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<Assignment> _assignments = [];
  List<AcademicSession> _sessions = [];
  String? _userName;
  bool _isLoading = false;

  AppProvider(this._storageService);

  // Getters
  List<Assignment> get assignments => _assignments;
  List<AcademicSession> get sessions => _sessions;
  String? get userName => _userName;
  bool get isLoading => _isLoading;

  /// Initialize: Load all data from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _assignments = await _storageService.loadAssignments();
      _sessions = await _storageService.loadSessions();
      _userName = _storageService.loadUserName();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get today's assignments
  List<Assignment> getTodaysAssignments() {
    final today = DateTime.now();
    return _assignments
        .where((a) =>
            a.dueDate.year == today.year &&
            a.dueDate.month == today.month &&
            a.dueDate.day == today.day &&
            !a.isCompleted)
        .toList();
  }

  /// Get assignments due in next 7 days
  List<Assignment> getUpcomingAssignments() {
    final today = DateTime.now();
    final nextWeek = today.add(const Duration(days: 7));
    return _assignments
        .where((a) =>
            a.dueDate.isAfter(today) &&
            a.dueDate.isBefore(nextWeek.add(const Duration(days: 1))) &&
            !a.isCompleted)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Get all pending assignments count
  int getPendingAssignmentsCount() {
    return _assignments.where((a) => !a.isCompleted).length;
  }

  /// Get today's sessions
  List<AcademicSession> getTodaysSessions() {
    final today = DateTime.now();
    return _sessions
        .where((s) =>
            s.date.year == today.year &&
            s.date.month == today.month &&
            s.date.day == today.day)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Get sessions for a specific week (starting from Monday)
  List<AcademicSession> getWeekSessions(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _sessions
        .where((s) => s.date.isAfter(weekStart) && s.date.isBefore(weekEnd))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date) == 0
          ? a.startTime.compareTo(b.startTime)
          : a.date.compareTo(b.date));
  }

  /// Calculate attendance percentage
  double calculateAttendancePercentage() {
    if (_sessions.isEmpty) return 100.0; // No sessions = 100% attendance

    // Only count sessions that have been marked as attended or absent
    final trackedSessions = _sessions.where((s) => s.isAttended != null).toList();

    if (trackedSessions.isEmpty) return 100.0;

    final attended = trackedSessions.where((s) => s.isAttended == true).length;
    return (attended / trackedSessions.length) * 100;
  }

  /// Add a new assignment
  Future<void> addAssignment(Assignment assignment) async {
    _assignments.add(assignment);
    await _storageService.saveAssignments(_assignments);
    notifyListeners();
  }

  /// Update an assignment
  Future<void> updateAssignment(Assignment assignment) async {
    final index = _assignments.indexWhere((a) => a.id == assignment.id);
    if (index != -1) {
      _assignments[index] = assignment;
      await _storageService.saveAssignments(_assignments);
      notifyListeners();
    }
  }

  /// Delete an assignment
  Future<void> deleteAssignment(String id) async {
    _assignments.removeWhere((a) => a.id == id);
    await _storageService.saveAssignments(_assignments);
    notifyListeners();
  }

  /// Mark assignment as completed
  Future<void> completeAssignment(String id) async {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _assignments[index].isCompleted = true;
      await _storageService.saveAssignments(_assignments);
      notifyListeners();
    }
  }

  /// Add a new academic session
  Future<void> addSession(AcademicSession session) async {
    _sessions.add(session);
    await _storageService.saveSessions(_sessions);
    notifyListeners();
  }

  /// Update an academic session
  Future<void> updateSession(AcademicSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
      await _storageService.saveSessions(_sessions);
      notifyListeners();
    }
  }

  /// Delete an academic session
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    await _storageService.saveSessions(_sessions);
    notifyListeners();
  }

  /// Toggle attendance for a session
  Future<void> toggleSessionAttendance(String id) async {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index != -1) {
      final session = _sessions[index];
      // Cycle: null -> true (present) -> false (absent) -> null
      bool? newAttendance = session.isAttended == null
          ? true
          : session.isAttended == true
              ? false
              : null;

      _sessions[index] = session.copyWith(isAttended: newAttendance);
      await _storageService.saveSessions(_sessions);
      notifyListeners();
    }
  }

  /// Set user name
  Future<void> setUserName(String name) async {
    _userName = name;
    await _storageService.saveUserName(name);
    notifyListeners();
  }
}
