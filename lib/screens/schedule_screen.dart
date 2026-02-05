import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/session.dart';
import '../utils/constants.dart';
import '../widgets/session_card.dart';

/// ScheduleScreen provides the academic session planning interface.
/// Users can:
///   - View a weekly calendar with day-by-day navigation
///   - Schedule new sessions with title, date, time range, location, and type
///   - Record attendance (Present/Absent) for each session
///   - Edit or delete existing sessions
///   - View an overall attendance summary
class ScheduleScreen extends StatefulWidget {
  final List<Session> sessions;
  final Function(List<Session>) onSessionsChanged;

  const ScheduleScreen({
    super.key,
    required this.sessions,
    required this.onSessionsChanged,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // The currently selected date in the week view
  late DateTime _selectedDate;

  // The start of the displayed week
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekStart = _getWeekStart(_selectedDate);
  }

  /// Gets the Monday of the week containing the given date
  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// Returns sessions for the currently selected date, sorted by start time
  List<Session> get _sessionsForSelectedDate {
    return widget.sessions
        .where((s) => s.isOnDate(_selectedDate))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Calculate attendance percentage for the summary
  Map<String, dynamic> get _attendanceStats {
    final recorded = widget.sessions.where((s) => s.isPresent != null).toList();
    final present = recorded.where((s) => s.isPresent == true).length;
    final total = recorded.length;
    final percentage = total == 0 ? 100.0 : (present / total) * 100;
    return {
      'present': present,
      'absent': total - present,
      'total': total,
      'percentage': percentage,
    };
  }

  /// Navigates to the previous week
  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      _selectedDate = _weekStart;
    });
  }

  /// Navigates to the next week
  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      _selectedDate = _weekStart;
    });
  }

  /// Updates attendance for a session
  void _updateAttendance(Session session, bool? isPresent) {
    setState(() {
      session.isPresent = isPresent;
    });
    widget.onSessionsChanged(widget.sessions);
  }

  /// Deletes a session after confirmation
  void _deleteSession(Session session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.primaryNavy,
        title: const Text('Delete Session',
            style: TextStyle(color: AppColors.textWhite)),
        content: Text(
          'Are you sure you want to delete "${session.title}"?',
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
                widget.sessions.removeWhere((s) => s.id == session.id);
              });
              widget.onSessionsChanged(widget.sessions);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.dangerRed)),
          ),
        ],
      ),
    );
  }

  /// Opens the form dialog for creating or editing a session
  void _showSessionForm({Session? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final locationController =
        TextEditingController(text: existing?.location ?? '');
    DateTime selectedDate = existing?.date ?? _selectedDate;
    TimeOfDay startTime = existing != null
        ? TimeOfDay.fromDateTime(existing.startTime)
        : const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = existing != null
        ? TimeOfDay.fromDateTime(existing.endTime)
        : const TimeOfDay(hour: 10, minute: 30);
    String selectedType = existing?.sessionType ?? SessionTypes.types.first;

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
            /// Helper to pick a time
            Future<void> pickTime(bool isStart) async {
              final picked = await showTimePicker(
                context: context,
                initialTime: isStart ? startTime : endTime,
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
                setModalState(() {
                  if (isStart) {
                    startTime = picked;
                  } else {
                    endTime = picked;
                  }
                });
              }
            }

            /// Formats TimeOfDay for display
            String formatTimeOfDay(TimeOfDay t) {
              final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
              final minute = t.minute.toString().padLeft(2, '0');
              final period = t.period == DayPeriod.am ? 'AM' : 'PM';
              return '$hour:$minute $period';
            }

            return Padding(
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
                      existing == null
                          ? 'Schedule New Session'
                          : 'Edit Session',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 20),

                    // Title field (required)
                    Text('Session Title *', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(
                          color: AppColors.textWhite, fontSize: 14),
                      decoration: _inputDecoration(
                          'e.g., Data Structures Lecture'),
                    ),
                    const SizedBox(height: 16),

                    // Session type dropdown
                    Text('Session Type', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavyLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedType,
                          dropdownColor: AppColors.primaryNavy,
                          style: const TextStyle(
                              color: AppColors.textWhite, fontSize: 14),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: AppColors.accentGold),
                          items: SessionTypes.types.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedType = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date picker
                    Text('Date', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 30)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
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
                              DateFormat('EEE, MMM dd, yyyy')
                                  .format(selectedDate),
                              style: const TextStyle(
                                  color: AppColors.textWhite, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time pickers row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Time',
                                  style: AppTextStyles.caption),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => pickTime(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryNavyLight,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          color: AppColors.accentGold,
                                          size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        formatTimeOfDay(startTime),
                                        style: const TextStyle(
                                            color: AppColors.textWhite,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Time',
                                  style: AppTextStyles.caption),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => pickTime(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryNavyLight,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          color: AppColors.accentGold,
                                          size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        formatTimeOfDay(endTime),
                                        style: const TextStyle(
                                            color: AppColors.textWhite,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Location field (optional)
                    Text('Location (optional)', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    TextField(
                      controller: locationController,
                      style: const TextStyle(
                          color: AppColors.textWhite, fontSize: 14),
                      decoration: _inputDecoration('e.g., Room 201, ALU Campus'),
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
                                content:
                                    Text('Please enter a session title'),
                                backgroundColor: AppColors.dangerRed,
                              ),
                            );
                            return;
                          }

                          // Validate end time is after start time
                          final startMinutes =
                              startTime.hour * 60 + startTime.minute;
                          final endMinutes =
                              endTime.hour * 60 + endTime.minute;
                          if (endMinutes <= startMinutes) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'End time must be after start time'),
                                backgroundColor: AppColors.dangerRed,
                              ),
                            );
                            return;
                          }

                          // Build DateTime objects for start and end times
                          final startDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            startTime.hour,
                            startTime.minute,
                          );
                          final endDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            endTime.hour,
                            endTime.minute,
                          );

                          if (existing != null) {
                            // Update existing session
                            setState(() {
                              existing.title = titleController.text.trim();
                              existing.date = selectedDate;
                              existing.startTime = startDateTime;
                              existing.endTime = endDateTime;
                              existing.location =
                                  locationController.text.trim();
                              existing.sessionType = selectedType;
                            });
                          } else {
                            // Create new session
                            final newSession = Session(
                              id: const Uuid().v4(),
                              title: titleController.text.trim(),
                              date: selectedDate,
                              startTime: startDateTime,
                              endTime: endDateTime,
                              location: locationController.text.trim(),
                              sessionType: selectedType,
                            );
                            setState(() {
                              widget.sessions.add(newSession);
                            });
                          }
                          widget.onSessionsChanged(widget.sessions);
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
                              ? 'Schedule Session'
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

  /// Returns a consistent input decoration for text fields
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysList = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final sessionsForDay = _sessionsForSelectedDate;
    final stats = _attendanceStats;
    final isAtRisk = (stats['percentage'] as double) < 75;

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
                  const Text('Schedule', style: AppTextStyles.heading1),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showSessionForm(),
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
                          Icon(Icons.add,
                              color: AppColors.primaryDark, size: 18),
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

            // ========== ATTENDANCE SUMMARY BAR ==========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isAtRisk
                      ? AppColors.dangerRed.withOpacity(0.15)
                      : AppColors.successGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAtRisk
                        ? AppColors.dangerRed
                        : AppColors.successGreen,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAtRisk
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: isAtRisk
                          ? AppColors.dangerRed
                          : AppColors.successGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Attendance: ${(stats['percentage'] as double).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isAtRisk
                            ? AppColors.dangerRed
                            : AppColors.successGreen,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${stats['present']} present · ${stats['absent']} absent',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ========== WEEK NAVIGATION ==========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: AppColors.textWhite),
                    onPressed: _previousWeek,
                  ),
                  Text(
                    '${DateFormat('MMM dd').format(_weekStart)} — ${DateFormat('MMM dd').format(_weekStart.add(const Duration(days: 6)))}',
                    style: AppTextStyles.heading3,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: AppColors.textWhite),
                    onPressed: _nextWeek,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ========== WEEK DAY SELECTOR ==========
            SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 7,
                itemBuilder: (ctx, index) {
                  final day = daysList[index];
                  final isSelected = day.day == _selectedDate.day &&
                      day.month == _selectedDate.month &&
                      day.year == _selectedDate.year;
                  final isToday = day.day == DateTime.now().day &&
                      day.month == DateTime.now().month &&
                      day.year == DateTime.now().year;
                  final hasSession =
                      widget.sessions.any((s) => s.isOnDate(day));

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = day),
                    child: Container(
                      width: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentGold
                            : AppColors.primaryNavyLight,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday && !isSelected
                            ? Border.all(
                                color: AppColors.accentGold, width: 1.5)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E').format(day).substring(0, 3),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : AppColors.textWhite,
                            ),
                          ),
                          if (hasSession)
                            Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.accentGold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ========== SESSIONS FOR SELECTED DAY ==========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                DateFormat('EEEE, MMMM dd').format(_selectedDate),
                style: AppTextStyles.heading3,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: sessionsForDay.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_outlined,
                              size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No sessions on this day.\nTap + to schedule one!',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: sessionsForDay.length,
                      itemBuilder: (ctx, index) {
                        final session = sessionsForDay[index];
                        return SessionCard(
                          session: session,
                          onAttendanceChanged: (val) =>
                              _updateAttendance(session, val),
                          onEdit: () =>
                              _showSessionForm(existing: session),
                          onDelete: () => _deleteSession(session),
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
