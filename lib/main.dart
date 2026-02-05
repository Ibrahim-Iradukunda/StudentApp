import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/assignment.dart';
import 'models/session.dart';
import 'screens/dashboard_screen.dart';
import 'screens/assignments_screen.dart';
import 'screens/schedule_screen.dart';
import 'utils/constants.dart';
import 'utils/storage_helper.dart';

/// Entry point of the ALU Academic Assistant application.
/// Initializes Flutter bindings and launches the app.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the status bar style to match our dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ALUAcademicAssistantApp());
}

/// Root widget of the application.
/// Configures the Material theme with ALU branding colors and
/// sets up the main navigation shell.
class ALUAcademicAssistantApp extends StatelessWidget {
  const ALUAcademicAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Academic Assistant',
      debugShowCheckedModeBanner: false,
      // Dark theme configuration using ALU color palette
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.primaryDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentGold,
          secondary: AppColors.accentGold,
          surface: AppColors.primaryNavy,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryDark,
          elevation: 0,
        ),
        // Snackbar theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primaryNavy,
          contentTextStyle: const TextStyle(color: AppColors.textWhite),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const MainNavigationShell(),
    );
  }
}

/// MainNavigationShell is the root stateful widget that manages:
///   - Bottom navigation between the 3 main tabs
///   - Loading and saving data to shared_preferences
///   - Passing data down to child screens
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  // Currently selected tab index for the BottomNavigationBar
  int _currentIndex = 0;

  // App-wide data lists — these are the single source of truth
  List<Assignment> _assignments = [];
  List<Session> _sessions = [];

  // Loading flag for showing a progress indicator on first launch
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData(); // Load saved data from shared_preferences
  }

  /// Loads assignments and sessions from shared_preferences.
  /// Called once on app startup to restore persisted data.
  Future<void> _loadData() async {
    try {
      final assignments = await StorageHelper.loadAssignments();
      final sessions = await StorageHelper.loadSessions();
      setState(() {
        _assignments = assignments;
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      // If loading fails, start with empty lists
      setState(() => _isLoading = false);
    }
  }

  /// Callback for when assignments are modified by the Assignments screen.
  /// Saves the updated list to shared_preferences and triggers a rebuild.
  void _onAssignmentsChanged(List<Assignment> updated) {
    setState(() => _assignments = updated);
    StorageHelper.saveAssignments(updated);
  }

  /// Callback for when sessions are modified by the Schedule screen.
  /// Saves the updated list to shared_preferences and triggers a rebuild.
  void _onSessionsChanged(List<Session> updated) {
    setState(() => _sessions = updated);
    StorageHelper.saveSessions(updated);
  }

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while data is being loaded
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.primaryDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentGold),
        ),
      );
    }

    // Build the list of screens — each receives the data it needs
    final screens = [
      DashboardScreen(
        assignments: _assignments,
        sessions: _sessions,
      ),
      AssignmentsScreen(
        assignments: _assignments,
        onAssignmentsChanged: _onAssignmentsChanged,
      ),
      ScheduleScreen(
        sessions: _sessions,
        onSessionsChanged: _onSessionsChanged,
      ),
    ];

    return Scaffold(
      // Display the currently selected screen
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),

      // BottomNavigationBar with 3 primary tabs as specified
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryNavy,
          border: Border(
            top: BorderSide(color: AppColors.borderColor, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.primaryNavy,
          selectedItemColor: AppColors.accentGold,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Assignments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Schedule',
            ),
          ],
        ),
      ),
    );
  }
}
