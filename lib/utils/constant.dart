import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryNavy = Color(0xFF001F3F);
  static const Color accentYellow = Color(0xFFFFC107);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color textGray = Color(0xFF666666);
  static const Color warningRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF4CAF50);
}

class PriorityLevel {
  static const String high = 'High';
  static const String medium = 'Medium';
  static const String low = 'Low';
  
  static List<String> get allLevels => [high, medium, low];
  
  static Color getColor(String? priority) {
    switch (priority) {
      case high:
        return AppColors.warningRed;
      case medium:
        return Colors.orange;
      case low:
        return Colors.blue;
      default:
        return AppColors.textGray;
    }
  }
}