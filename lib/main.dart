import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/assignments.dart';
import 'screens/screen.dart';
import 'utils/constant.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Assignments Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryNavy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryNavy,
          primary: AppColors.primaryNavy,
          secondary: AppColors.accentYellow,
        ),
        useMaterial3: true,
      ),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<Assignment> _assignments = [
    Assignment(
      id: '1',
      title: 'Flutter Group Project',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      courseName: 'Mobile App Development',
      priority: 'High',
    ),
    Assignment(
      id: '2',
      title: 'Essay on Leadership',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      courseName: 'Leadership Studies',
      priority: 'Medium',
    ),
  ];

  void _addAssignment(Assignment assignment) {
    setState(() {
      _assignments.add(assignment);
    });
  }

  void _updateAssignment(Assignment updatedAssignment) {
    setState(() {
      final index = _assignments.indexWhere((a) => a.id == updatedAssignment.id);
      if (index != -1) {
        _assignments[index] = updatedAssignment;
      }
    });
  }

  void _deleteAssignment(String assignmentId) {
    setState(() {
      _assignments.removeWhere((a) => a.id == assignmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AssignmentsScreen(
      assignments: _assignments,
      onAddAssignment: _addAssignment,
      onUpdateAssignment: _updateAssignment,
      onDeleteAssignment: _deleteAssignment,
    );
  }
}