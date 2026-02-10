import 'package:flutter/material.dart';
import '../models/assignments.dart';
import '../utils/constant.dart';
import '../utils/helpers.dart';

/// Add/Edit Assignment Dialog
/// Author: Yvette Uwimpaye
class AddAssignmentDialog extends StatefulWidget {
  final Assignment? assignment;
  final Function(Assignment) onSave;

  const AddAssignmentDialog({
    Key? key,
    this.assignment,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddAssignmentDialog> createState() => _AddAssignmentDialogState();
}

class _AddAssignmentDialogState extends State<AddAssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _courseController;
  late DateTime _selectedDate;
  String? _selectedPriority;

  // ✅ ADD THIS
  late String _assignmentType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.assignment?.title ?? '',
    );
    _courseController = TextEditingController(
      text: widget.assignment?.courseName ?? '',
    );
    _selectedDate = widget.assignment?.dueDate ?? DateTime.now();
    _selectedPriority = widget.assignment?.priority;

    // ✅ ADD THIS
    _assignmentType = widget.assignment?.assignmentType ?? 'Formative';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryNavy,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveAssignment() {
    if (_formKey.currentState!.validate()) {
      final assignment = Assignment(
        id: widget.assignment?.id ?? Helpers.generateId(),
        title: _titleController.text.trim(),
        dueDate: _selectedDate,
        courseName: _courseController.text.trim(),

        // ✅ THIS IS THE ACTUAL FIX
        assignmentType: _assignmentType,

        priority: _selectedPriority,
        isCompleted: widget.assignment?.isCompleted ?? false,
      );

      widget.onSave(assignment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.assignment != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Assignment' : 'New Assignment',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 24),

                // ---- Title ----
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Assignment Title *',
                    hintText: 'e.g., Essay on Leadership',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primaryNavy,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter assignment title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ---- Course ----
                TextFormField(
                  controller: _courseController,
                  decoration: InputDecoration(
                    labelText: 'Course Name *',
                    hintText: 'e.g., Introduction to Python',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primaryNavy,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter course name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ---- Due Date ----
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Due Date *',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textGray,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Helpers.formatDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primaryNavy,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ---- Priority ----
                const Text(
                  'Priority (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: PriorityLevel.allLevels.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    return ChoiceChip(
                      label: Text(priority),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedPriority = selected ? priority : null;
                        });
                      },
                      selectedColor:
                          PriorityLevel.getColor(priority).withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? PriorityLevel.getColor(priority)
                            : AppColors.textGray,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? PriorityLevel.getColor(priority)
                            : Colors.grey,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // ---- Actions ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveAssignment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(isEditing ? 'Update' : 'Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
