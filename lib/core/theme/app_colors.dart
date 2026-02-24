import 'package:flutter/material.dart';

class AppColors {
  // Brand colors (from ZENZO logo)
  static const Color primaryTeal = Color(0xFF1B4332); // Dark Zen Green
  static const Color accentBlue = Color(0xFF4A7BAF); // Calming Blue
  static const Color zenGold = Color(0xFFD1A15E); // Subtle Gold

  // UI colors
  static const Color background = Color(0xFFF9FBFB); // Very light grey/white
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D302E); // Soft Slate Black
  static const Color textSecondary = Color(0xFF6B706D); // Muted Green-Grey
  static const Color error = Color(0xFFE63946); // Soft Red

  // Gradients
  static const LinearGradient zenGradient = LinearGradient(
    colors: [primaryTeal, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
