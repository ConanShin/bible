import 'package:flutter/material.dart';

class AppColors {
  // --- Base Palette (Raw Values) ---
  static const Color _darkDeepest = Color(0xFF121212);
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkVariant = Color(0xFF2C2C2C);
  static const Color _neutralWhite = Color(0xFFE0E0E0);
  static const Color _neutralGrey = Color(0xFF9E9E9E);

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
  static const Color darkPrimary = Color(0xFFCCCCCC); // Neutral Light Grey
  static const Color darkPrimaryLight = Color(0xFF999999);
  static const Color darkBackground = _darkDeepest;
  static const Color darkSurface = _darkSurface;
  static const Color darkSurfaceVariant = _darkVariant;
  static const Color darkTextPrimary = _neutralWhite;
  static const Color darkTextSecondary = _neutralGrey;

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
