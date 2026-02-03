import 'package:flutter/material.dart';

/// App color palette
/// Inspired by menumia-customer-app design system
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color brightBlue = Color(0xFF0066FF);
  static const Color electricViolet = Color(0xFF8B5CF6);
  static const Color hotRed = Color(0xFFFF4444);

  // Navbar and UI colors
  static const Color navbarBackground = Color(0xFF283142);
  static const Color navbarText = Color(0xFFFEFEFE);

  // Neutral colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF0F141A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [hotRed, Color(0xFFFF6B9D), electricViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
