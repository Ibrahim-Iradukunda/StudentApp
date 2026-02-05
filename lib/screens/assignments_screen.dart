import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/assignment.dart';
import '../utils/constants.dart';
import '../widgets/assignment_card.dart';

/// AssignmentsScreen provides the full assignment management interface.
/// Users can:
///   - View all assignments sorted by due date
///   - Create new assignments with title, due date, course, and priority
///   - Mark assignments as completed
///   - Edit existing assignment details
///   - Delete assignments from the list
class AssignmentsScreen extends StatefulWidget {
  final List<Assignment> assignments;
  final Function(List<Assignment>) onAssignmentsChanged;

  const AssignmentsScreen({
    super.key,
    required this.assignments,
    required this.onAssignmentsChanged,
  });

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  // Filter state: 'All', 'Pending', 'Completed'
  String _filter = 'All';

  /// Returns the filtered and sorted list of assignments
  List<Assignment> get _filteredAssignments {
    List<Assignment> filtered;
    switch (_filter) {
      case 'Pending':
        filtered = widget.assignments.where((a) => !a.isCompleted).toList();
        break;
      case 'Completed':
        filtered = widget.assignments.where((a) => a.isCompleted).toList();
        break;
      default:
        filtered = List.from(widget.assignments);
    }
    // Sort by due date ascending (earliest first)
    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return filtered;
  }

  /// Toggles the completion status of an assignment
  void _toggleComplete(Assignment assignment) {
    setState(() {
      assignment.isCompleted = !assignment.isCompleted;
    });
    widget.onAssignmentsChanged(widget.assignments);
  }

  /// Deletes an assignment after confirmation
  void _deleteAssignment(Assignment assignment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.primaryNavy,
        title: const Text('Delete Assignment',
            style: TextStyle(color: AppColors.textWhite)),
        content: Text(
          'Are you sure you want to delete "${assignment.title}"?',
          style: const TextStyle(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                widget.assignments.removeWhere((a) => a.id == assignment.id);
              });
              widget.onAssignmentsChanged(widget.assignments);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.dangerRed)),
          ),
        ],
      ),
    );
  }

  /// Opens the form dialog for creating or editing an assignment
  void _showAssignmentForm({Assignment? existing}) {
    // Controllers pre-filled if editing
    final titleController = TextEditingController(text: existing?.title ?? '');
    final courseController = TextEditingController(text: existing?.course ?? '');
    DateTime selectedDate = existing?.dueDate ?? DateTime.now();
    String selectedPriority = existing?.priority ?? 'Medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              // Padding adjusts when keyboard opens
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form header
                    Text(
                      existing == null ? 'New Assignment' : 'Edit Assignment',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 20),

                    // Title field (required)
                    _buildTextField(
                      controller: titleController,
                      label: 'Assignment Title *',
                      hint: 'e.g., Data Structures Quiz 1',
                    ),
                    const SizedBox(height: 16),

                    // Course field
                    _buildTextField(
                      controller: courseController,
                      label: 'Course Name',
                      hint: 'e.g., Introduction to Algorithms',
                    ),
                    const SizedBox(height: 16),

                    // Due date picker
                    Text('Due Date', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                              const Duration(days: 30)),
                          lastDate: DateTime.now().add(
                              const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.accentGold,
                                  surface: AppColors.primaryNavy,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavyLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: AppColors.accentGold, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('MMM dd, yyyy').format(selectedDate),
                              style: const TextStyle(
                                  color: AppColors.textWhite, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Priority selector
                    Text('Priority Level', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    Row(
                      children: PriorityLevels.levels.map((level) {
                        final isSelected = selectedPriority == level;
                        final color = PriorityLevels.getColor(level);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() => selectedPriority = level);
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                right: level != 'Low' ? 8 : 0,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withOpacity(0.2)
                                    : AppColors.primaryNavyLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? color
                                      : AppColors.borderColor,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  level,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? color
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate required fields
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter an assignment title'),
                                backgroundColor: AppColors.dangerRed,
                              ),
                            );
                            return;
                          }

                          if (existing != null) {
                            // Update existing assignment
                            setState(() {
                              existing.title = titleController.text.trim();
                              existing.course = courseController.text.trim();
                              existing.dueDate = selectedDate;
                              existing.priority = selectedPriority;
                            });
                          } else {
                            // Create new assignment
                            final newAssignment = Assignment(
                              id: const Uuid().v4(),
                              title: titleController.text.trim(),
                              dueDate: selectedDate,
                              course: courseController.text.trim(),
                              priority: selectedPriority,
                            );
                            setState(() {
                              widget.assignments.add(newAssignment);
                            });
                          }
                          widget.onAssignmentsChanged(widget.assignments);
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          existing == null
                              ? 'Create Assignment'
                              : 'Save Changes',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds a styled text input field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            filled: true,
            fillColor: AppColors.primaryNavyLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.accentGold),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAssignments;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== HEADER ==========
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Text('Assignments', style: AppTextStyles.heading1),
                  const Spacer(),
                  // Add button
                  GestureDetector(
                    onTap: () => _showAssignmentForm(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: AppColors.primaryDark, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ========== FILTER TABS ==========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['All', 'Pending', 'Completed'].map((filter) {
                  final isActive = _filter == filter;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = filter),
                      child: Container(
                        margin: EdgeInsets.only(
                            right: filter != 'Completed' ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accentGold
                              : AppColors.primaryNavyLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive
                                ? AppColors.accentGold
                                : AppColors.borderColor,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppColors.primaryDark
                                  : AppColors.textLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ========== ASSIGNMENT LIST ==========
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined,
                              size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            _filter == 'All'
                                ? 'No assignments yet.\nTap + to create one!'
                                : 'No $_filter assignments.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, index) {
                        final assignment = filtered[index];
                        return AssignmentCard(
                          assignment: assignment,
                          onToggleComplete: () => _toggleComplete(assignment),
                          onEdit: () =>
                              _showAssignmentForm(existing: assignment),
                          onDelete: () => _deleteAssignment(assignment),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
