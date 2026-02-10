import 'package:flutter/material.dart';

void main() {
  runApp(const RiskApp());
}

class RiskApp extends StatelessWidget {
  const RiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const RiskStatusScreen(),
    );
  }
}

class RiskStatusScreen extends StatelessWidget {
  const RiskStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1A3A),
              Color(0xFF020C1E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      "Your Risk Status",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Greeting
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Hello Alex  At Risk",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Risk Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    RiskCard(
                      percentage: "75%",
                      label: "Attendance",
                      color: Color(0xFFE53935),
                    ),
                    RiskCard(
                      percentage: "60%",
                      label: "Assignment to\nStatement",
                      color: Color(0xFFF9A825),
                    ),
                    RiskCard(
                      percentage: "63%",
                      label: "Average\nExams",
                      color: Color(0xFFF57C00),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Get Help Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Get Help",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bottom Navigation
              BottomNavigationBar(
                backgroundColor: const Color(0xFF020C1E),
                selectedItemColor: const Color(0xFFFFD600),
                unselectedItemColor: Colors.grey,
                currentIndex: 3,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Dashboard",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics),
                    label: "Analytics",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.school),
                    label: "Learning",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "Me",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RiskCard extends StatelessWidget {
  final String percentage;
  final String label;
  final Color color;

  const RiskCard({
    super.key,
    required this.percentage,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            percentage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
