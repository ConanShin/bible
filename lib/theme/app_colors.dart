import 'package:flutter/material.dart';

class AppColors {
  // --- Base Palette (Raw Values) ---
  // Earth/Rose Palette
  static const Color _navyDeepest = Color(0xFF0B0F19);
  static const Color _navySurface = Color(0xFF161C2C);
  static const Color _navyVariant = Color(0xFF1F293D);
  static const Color _softWhite = Color(0xFFE6EDF3);
  static const Color _mutedGrey = Color(0xFF8B949E);

  // --- Light Theme Tokens ---
  static const Color lightPrimary = Color(0xFF333333); // Neutral Dark Grey
  static const Color lightPrimaryLight = Color(0xFF666666);
  static const Color lightPrimaryDark = Color(0xFF000000);
  static const Color lightBackground = Color(
    0xFFF8F8F8,
  ); // Very Light Neutral Grey (No Blue tint)
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFEEEEEE);
  static const Color lightTextPrimary = Color(0xFF1A1A1A); // Almost Black
  static const Color lightTextSecondary = Color(0xFF4D4D4D);
  static const Color lightTextTertiary = Color(0xFF808080);

  // --- Dark Theme Tokens ---
  // static const Color darkPrimary = _espresso;
  static const Color darkPrimary = Color.fromARGB(255, 130, 149, 214);
  static const Color darkPrimaryLight = _navyVariant;
  static const Color darkBackground = _navyDeepest;
  static const Color darkSurface = _navySurface;
  static const Color darkSurfaceVariant = _navyVariant;
  static const Color darkTextPrimary = _softWhite;
  static const Color darkTextSecondary = _mutedGrey;

  // --- Testament Colors ---
  static const Color oldTestament = Color.fromARGB(255, 116, 125, 162);
  static const Color newTestament = Color.fromARGB(255, 116, 102, 91);

  // --- Functional & Universal ---
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color secondaryAccent = Color(0xFFD4A373);
  static const Color overlay = Color(0x66000000);
}
