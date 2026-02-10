import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1C2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1C2D),
        elevation: 0,
        title: const Text(
          'Announcements',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnnouncementCard(
              title: 'Reminder: Project Deadlines',
              description:
                  'Department of Software Engineering Commencing at deliverable beyond will issued in',
            ),
            _buildAnnouncementCard(
              title: 'Upcoming Industry Talk',
              description: 'Farming a new iny of 1 LI state your coursework',
            ),
            _buildAnnouncementCard(
              title: 'Update for All Students',
              description:
                  'See additional online courses for asssit in your coursework',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
