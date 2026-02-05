import 'package:flutter/material.dart';
import '../models/assignments.dart';
import '../utils/constant.dart';
import '../utils/helpers.dart';
import '../widgets/add_assignment_dialog.dart';

/// Assignments Screen - YOUR FEATURE
/// Author: [YOUR NAME HERE]
class AssignmentsScreen extends StatefulWidget {
  final List<Assignment> assignments;
  final Function(Assignment) onAddAssignment;
  final Function(Assignment) onUpdateAssignment;
  final Function(String) onDeleteAssignment;

  const AssignmentsScreen({
    Key? key,
    required this.assignments,
    required this.onAddAssignment,
    required this.onUpdateAssignment,
    required this.onDeleteAssignment,
  }) : super(key: key);

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  String _selectedFilter = 'All'; // All, Formative, Summative

  List<Assignment> _getFilteredAssignments() {
    List<Assignment> filtered;

    switch (_selectedFilter) {
      case 'Formative':
        // Show only Formative assignments
        filtered = widget.assignments
            .where((a) => a.assignmentType == 'Formative')
            .toList();
        break;
      case 'Summative':
        // Show only Summative assignments
        filtered = widget.assignments
            .where((a) => a.assignmentType == 'Summative')
            .toList();
        break;
      default:
        // Show all assignments
        filtered = widget.assignments;
    }

    // Sort by due date (earliest first)
    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return filtered;
  }

  void _showAddAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAssignmentDialog(
        onSave: (assignment) {
          widget.onAddAssignment(assignment);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment added successfully')),
          );
        },
      ),
    );
  }

  void _showEditAssignmentDialog(Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AddAssignmentDialog(
        assignment: assignment,
        onSave: (updatedAssignment) {
          widget.onUpdateAssignment(updatedAssignment);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment updated successfully')),
          );
        },
      ),
    );
  }

  void _toggleCompletion(Assignment assignment) {
    final updated = assignment.copyWith(isCompleted: !assignment.isCompleted);
    widget.onUpdateAssignment(updated);
  }

  void _confirmDelete(Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text('Are you sure you want to delete "${assignment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteAssignment(assignment.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Assignment deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.warningRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAssignments = _getFilteredAssignments();

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        title: const Text(
          'Assignments',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.accentYellow,
              size: 28,
            ),
            onPressed: _showAddAssignmentDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildFilterChip('All', widget.assignments.length),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Formative',
                  widget.assignments
                      .where((a) => a.assignmentType == 'Formative')
                      .length,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Summative',
                  widget.assignments
                      .where((a) => a.assignmentType == 'Summative')
                      .length,
                ),
              ],
            ),
          ),

          // Assignments List Section
          Expanded(
            child: filteredAssignments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredAssignments.length,
                    itemBuilder: (context, index) {
                      final assignment = filteredAssignments[index];
                      return _buildAssignmentCard(assignment);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentYellow
              : AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryNavy : AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryNavy.withOpacity(0.2)
                    : AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? AppColors.primaryNavy : AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    final isOverdue = assignment.isOverdue();
    final daysUntilDue = assignment.dueDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showEditAssignmentDialog(assignment),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Completion Checkbox
                    GestureDetector(
                      onTap: () => _toggleCompletion(assignment),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: assignment.isCompleted
                              ? AppColors.successGreen
                              : Colors.transparent,
                          border: Border.all(
                            color: assignment.isCompleted
                                ? AppColors.successGreen
                                : AppColors.textGray,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: assignment.isCompleted
                            ? const Icon(Icons.check,
                                size: 16, color: AppColors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Assignment Title
                    Expanded(
                      child: Text(
                        assignment.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                          decoration: assignment.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),

                    // Assignment Type Badge (Formative/Summative)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: assignment.assignmentType == 'Formative'
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        assignment.assignmentType,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: assignment.assignmentType == 'Formative'
                              ? Colors.blue
                              : Colors.purple,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Delete Button
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: AppColors.textGray,
                      onPressed: () => _confirmDelete(assignment),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Course Name
                Row(
                  children: [
                    Icon(Icons.book_outlined,
                        size: 16, color: AppColors.textGray),
                    const SizedBox(width: 6),
                    Text(
                      assignment.courseName,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Due Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color:
                          isOverdue ? AppColors.warningRed : AppColors.textGray,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Due: ${Helpers.formatDate(assignment.dueDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isOverdue
                            ? AppColors.warningRed
                            : AppColors.textGray,
                        fontWeight:
                            isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (!assignment.isCompleted &&
                        daysUntilDue >= 0 &&
                        daysUntilDue <= 7) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${Helpers.getRelativeDateString(assignment.dueDate)})',
                        style: TextStyle(
                          fontSize: 12,
                          color: daysUntilDue <= 2
                              ? AppColors.warningRed
                              : AppColors.textGray,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),

                // Overdue Warning
                if (isOverdue)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warningRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: AppColors.warningRed,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Overdue',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.warningRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: AppColors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All'
                ? 'No assignments yet'
                : 'No ${_selectedFilter.toLowerCase()} assignments',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add one',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
