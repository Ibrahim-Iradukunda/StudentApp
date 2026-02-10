import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'assignments_screen.dart';
import 'announcements_screen.dart';
import '../risk_status/risk_status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AssignmentsScreen(),
    const AnnouncementsScreen(),
    const RiskStatusScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0B1C2D),
        selectedItemColor: const Color(0xFFFFC107),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Standings',
          ),
        ],
      ),
    );
  }
}
