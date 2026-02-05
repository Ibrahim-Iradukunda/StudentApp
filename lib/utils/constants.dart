import 'package:flutter/material.dart';

/// ALU Official Color Palette & App Constants
/// These colors are derived from the ALU branding guidelines.
class AppColors {
  // Primary colors
  static const Color primaryDark = Color(0xFF0A1628);      // Deep navy background
  static const Color primaryNavy = Color(0xFF0D1F3C);      // Card/surface color
  static const Color primaryNavyLight = Color(0xFF152744);  // Lighter navy for cards
  static const Color accentGold = Color(0xFFF0C808);        // ALU Gold/Yellow
  static const Color accentGoldDark = Color(0xFFD4B106);    // Darker gold for pressed states

  // Status colors
  static const Color dangerRed = Color(0xFFE63946);         // At-risk / warning red
  static const Color successGreen = Color(0xFF2ECC71);      // Success / present
  static const Color warningOrange = Color(0xFFF39C12);     // Medium priority

  // Text colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFFB0BEC5);         // Secondary text
  static const Color textMuted = Color(0xFF6C7A89);         // Muted text

  // Border & divider
  static const Color borderColor = Color(0xFF1E3A5F);
  static const Color dividerColor = Color(0xFF1A2D47);
}

/// App-wide text styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: AppColors.textWhite,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textLight,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
}

/// Session type options for academic sessions
class SessionTypes {
  static const List<String> types = [
    'Class',
    'Mastery Session',
    'Study Group',
    'PSL Meeting',
  ];
}

/// Priority levels for assignments
class PriorityLevels {
  static const List<String> levels = ['High', 'Medium', 'Low'];

  /// Returns a color associated with the given priority level
  static Color getColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.dangerRed;
      case 'Medium':
        return AppColors.warningOrange;
      case 'Low':
        return AppColors.successGreen;
      default:
        return AppColors.textMuted;
    }
  }
}
