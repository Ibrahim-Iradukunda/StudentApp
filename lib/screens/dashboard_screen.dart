import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../models/session.dart';
import '../utils/constants.dart';

/// DashboardScreen is the main overview page of the app.
/// It displays:
///   - Current date and academic week
///   - Today's scheduled sessions
///   - Assignments due within 7 days
///   - Overall attendance percentage with a visual warning if below 75%
///   - Summary count of pending (incomplete) assignments
class DashboardScreen extends StatelessWidget {
  final List<Assignment> assignments;
  final List<Session> sessions;

  const DashboardScreen({
    super.key,
    required this.assignments,
    required this.sessions,
  });

  /// Calculates the current academic week number.
  /// Assumes the term started on a configurable date (default: Jan 13, 2026).
  int _getAcademicWeek() {
    // Set the term start date — adjust this as needed
    final termStart = DateTime(2026, 1, 13);
    final now = DateTime.now();
    final difference = now.difference(termStart).inDays;
    if (difference < 0) return 0;
    return (difference ~/ 7) + 1;
  }

  /// Calculates overall attendance percentage from all sessions
  /// that have attendance recorded (isPresent is not null).
  double _calculateAttendance() {
    final recordedSessions =
        sessions.where((s) => s.isPresent != null).toList();
    if (recordedSessions.isEmpty) return 100.0;

    final presentCount = recordedSessions.where((s) => s.isPresent == true).length;
    return (presentCount / recordedSessions.length) * 100;
  }

  /// Filters and returns today's sessions, sorted by start time
  List<Session> _getTodaySessions() {
    final now = DateTime.now();
    return sessions
        .where((s) => s.isOnDate(now))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Filters assignments due within the next 7 days, sorted by due date
  List<Assignment> _getUpcomingAssignments() {
    return assignments
        .where((a) => !a.isCompleted && a.isDueWithinDays(7))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Counts assignments that are not yet completed
  int _getPendingCount() {
    return assignments.where((a) => !a.isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now());
    final academicWeek = _getAcademicWeek();
    final attendance = _calculateAttendance();
    final todaySessions = _getTodaySessions();
    final upcomingAssignments = _getUpcomingAssignments();
    final pendingCount = _getPendingCount();
    final isAtRisk = attendance < 75;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== HEADER: Title and date ==========
              const Text('Dashboard', style: AppTextStyles.heading1),
              const SizedBox(height: 4),
              Text(today, style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(
                'Academic Week $academicWeek',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // ========== AT-RISK WARNING BANNER ==========
              if (isAtRisk)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dangerRed, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.dangerRed, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AT RISK WARNING — Attendance is ${attendance.toStringAsFixed(1)}% (below 75%)',
                          style: TextStyle(
                            color: AppColors.dangerRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ========== STATS ROW: Attendance, Pending, Sessions ==========
              Row(
                children: [
                  _StatCard(
                    icon: Icons.check_circle_outline,
                    value: '${attendance.toStringAsFixed(0)}%',
                    label: 'Attendance',
                    valueColor:
                        isAtRisk ? AppColors.dangerRed : AppColors.successGreen,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.assignment_outlined,
                    value: '$pendingCount',
                    label: 'Pending',
                    valueColor: AppColors.accentGold,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.event_outlined,
                    value: '${todaySessions.length}',
                    label: 'Today\'s\nSessions',
                    valueColor: AppColors.textWhite,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ========== TODAY'S SESSIONS SECTION ==========
              Text("Today's Sessions", style: AppTextStyles.heading2),
              const SizedBox(height: 12),
              if (todaySessions.isEmpty)
                _EmptyCard(message: 'No sessions scheduled for today')
              else
                ...todaySessions.map(
                  (session) => _DashboardSessionTile(session: session),
                ),
              const SizedBox(height: 24),

              // ========== UPCOMING ASSIGNMENTS SECTION ==========
              Text('Due This Week', style: AppTextStyles.heading2),
              const SizedBox(height: 12),
              if (upcomingAssignments.isEmpty)
                _EmptyCard(message: 'No assignments due in the next 7 days')
              else
                ...upcomingAssignments.map(
                  (assignment) =>
                      _DashboardAssignmentTile(assignment: assignment),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small stat card widget used in the stats row on the dashboard.
/// Displays an icon, a value, and a label in a compact card layout.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color valueColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryNavyLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: valueColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact tile for showing today's session info on the dashboard.
class _DashboardSessionTile extends StatelessWidget {
  final Session session;
  const _DashboardSessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryNavyLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          // Time column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.formattedTimeRange,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Session details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
                Text(
                  '${session.sessionType}${session.location.isNotEmpty ? ' • ${session.location}' : ''}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          // Attendance indicator
          if (session.isPresent != null)
            Icon(
              session.isPresent! ? Icons.check_circle : Icons.cancel,
              color: session.isPresent!
                  ? AppColors.successGreen
                  : AppColors.dangerRed,
              size: 20,
            )
          else
            Icon(Icons.radio_button_unchecked,
                color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

/// A compact tile for showing upcoming assignment info on the dashboard.
class _DashboardAssignmentTile extends StatelessWidget {
  final Assignment assignment;
  const _DashboardAssignmentTile({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final dueFormatted = DateFormat('MMM dd').format(assignment.dueDate);
    final priorityColor = PriorityLevels.getColor(assignment.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryNavyLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: assignment.isOverdue
              ? AppColors.dangerRed.withOpacity(0.5)
              : AppColors.borderColor,
        ),
      ),
      child: Row(
        children: [
          // Priority dot indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: priorityColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
                Text(assignment.course, style: AppTextStyles.caption),
              ],
            ),
          ),
          // Due date chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: assignment.isOverdue
                  ? AppColors.dangerRed.withOpacity(0.2)
                  : AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              assignment.isOverdue ? 'Overdue' : 'Due $dueFormatted',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: assignment.isOverdue
                    ? AppColors.dangerRed
                    : AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state card shown when there are no items to display
class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryNavyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Text(
        message,
        style: AppTextStyles.caption,
        textAlign: TextAlign.center,
      ),
    );
  }
}
