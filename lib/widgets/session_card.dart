import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session.dart';
import '../utils/constants.dart';

/// A card widget that displays a single academic session's details.
/// Shows title, date, time range, location, session type, and attendance toggle.
/// Provides callbacks for attendance recording, editing, and deleting.
class SessionCard extends StatelessWidget {
  final Session session;
  final Function(bool?) onAttendanceChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SessionCard({
    super.key,
    required this.session,
    required this.onAttendanceChanged,
    required this.onEdit,
    required this.onDelete,
  });

  /// Returns a color associated with the session type for visual distinction
  Color _getSessionTypeColor() {
    switch (session.sessionType) {
      case 'Class':
        return AppColors.accentGold;
      case 'Mastery Session':
        return AppColors.successGreen;
      case 'Study Group':
        return const Color(0xFF3498DB);
      case 'PSL Meeting':
        return const Color(0xFF9B59B6);
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('EEE, MMM dd').format(session.date);
    final typeColor = _getSessionTypeColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryNavyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Session type badge + action buttons
            Row(
              children: [
                // Session type chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    session.sessionType,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
                  ),
                ),
                const Spacer(),
                // Edit button
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.accentGold),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  tooltip: 'Edit session',
                ),
                const SizedBox(width: 4),
                // Delete button
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 18, color: AppColors.dangerRed),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  tooltip: 'Delete session',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Session title
            Text(
              session.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            // Date and time row
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(dateFormatted, style: AppTextStyles.caption),
                const SizedBox(width: 16),
                Icon(Icons.access_time_outlined,
                    size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(session.formattedTimeRange, style: AppTextStyles.caption),
              ],
            ),
            // Location (if provided)
            if (session.location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(session.location, style: AppTextStyles.caption),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Attendance toggle row
            Row(
              children: [
                Text('Attendance:', style: AppTextStyles.caption),
                const SizedBox(width: 12),
                // Present button
                _AttendanceButton(
                  label: 'Present',
                  isSelected: session.isPresent == true,
                  color: AppColors.successGreen,
                  onTap: () => onAttendanceChanged(true),
                ),
                const SizedBox(width: 8),
                // Absent button
                _AttendanceButton(
                  label: 'Absent',
                  isSelected: session.isPresent == false,
                  color: AppColors.dangerRed,
                  onTap: () => onAttendanceChanged(false),
                ),
                if (session.isPresent != null) ...[
                  const SizedBox(width: 8),
                  // Clear attendance button
                  GestureDetector(
                    onTap: () => onAttendanceChanged(null),
                    child: Icon(Icons.close,
                        size: 16, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small toggle button used for Present/Absent attendance marking
class _AttendanceButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _AttendanceButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.textMuted,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? color : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
