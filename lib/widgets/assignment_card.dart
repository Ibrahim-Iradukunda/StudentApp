import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../utils/constants.dart';

/// A card widget that displays a single assignment's details.
/// Shows title, course, due date, priority badge, and completion status.
/// Provides callbacks for toggling completion, editing, and deleting.
class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Format the due date for display
    final dueDateFormatted = DateFormat('MMM dd, yyyy').format(assignment.dueDate);
    final priorityColor = PriorityLevels.getColor(assignment.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryNavyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: assignment.isOverdue
              ? AppColors.dangerRed.withOpacity(0.5)
              : AppColors.borderColor,
          width: assignment.isOverdue ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Title + Priority badge
            Row(
              children: [
                // Completion checkbox
                GestureDetector(
                  onTap: onToggleComplete,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: assignment.isCompleted
                          ? AppColors.successGreen
                          : Colors.transparent,
                      border: Border.all(
                        color: assignment.isCompleted
                            ? AppColors.successGreen
                            : AppColors.textMuted,
                        width: 2,
                      ),
                    ),
                    child: assignment.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Assignment title
                Expanded(
                  child: Text(
                    assignment.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                      decoration: assignment.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: AppColors.textMuted,
                    ),
                  ),
                ),
                // Priority badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assignment.priority,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Course name and due date row
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Row(
                children: [
                  Icon(Icons.book_outlined,
                      size: 14, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(
                    assignment.course,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: assignment.isOverdue
                        ? AppColors.dangerRed
                        : AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dueDateFormatted,
                    style: TextStyle(
                      fontSize: 12,
                      color: assignment.isOverdue
                          ? AppColors.dangerRed
                          : AppColors.textLight,
                      fontWeight: assignment.isOverdue
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (assignment.isOverdue) ...[
                    const SizedBox(width: 6),
                    Text(
                      'OVERDUE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dangerRed,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Action buttons row
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Row(
                children: [
                  const Spacer(),
                  // Edit button
                  IconButton(
                    icon: Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.accentGold),
                    onPressed: onEdit,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    tooltip: 'Edit assignment',
                  ),
                  const SizedBox(width: 8),
                  // Delete button
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: AppColors.dangerRed),
                    onPressed: onDelete,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    tooltip: 'Delete assignment',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
