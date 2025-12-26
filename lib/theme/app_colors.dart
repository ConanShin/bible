import 'package:flutter/material.dart';

class AppColors {
  // --- Base Palette (Raw Values) ---
  // Earth/Rose Palette
  static const Color _cream = Color(0xFFFFF8EA);
  static const Color _creamDarker = Color(0xFFF2EAD3);
  static const Color _roseMuted = Color(0xFF9E7676);
  static const Color _roseEarthy = Color(0xFF815B5B);
  static const Color _espresso = Color(0xFF594545);
  static const Color _roseLight = Color(0xFFD6BCBC);
  static const Color _roseTertiary = Color(0xFFA68E8E);

  // Deep Navy Palette (Dark Mode)
  static const Color _navyDeepest = Color(0xFF0B0F19);
  static const Color _navySurface = Color(0xFF161C2C);
  static const Color _navyVariant = Color(0xFF1F293D);
  static const Color _softWhite = Color(0xFFE6EDF3);
  static const Color _mutedGrey = Color(0xFF8B949E);

  // --- Light Theme Tokens ---
  static const Color lightPrimary = _roseMuted;
  static const Color lightPrimaryLight = _roseLight;
  static const Color lightPrimaryDark = _roseEarthy;
  static const Color lightBackground = _cream;
  static const Color lightSurface = _creamDarker;
  static const Color lightSurfaceVariant = _roseEarthy;
  static const Color lightTextPrimary = _espresso;
  static const Color lightTextSecondary = _roseEarthy;
  static const Color lightTextTertiary = _roseTertiary;

  // --- Dark Theme Tokens ---
  static const Color darkPrimary = _roseLight;
  static const Color darkPrimaryLight = _roseTertiary;
  static const Color darkBackground = _navyDeepest;
  static const Color darkSurface = _navySurface;
  static const Color darkSurfaceVariant = _navyVariant;
  static const Color darkTextPrimary = _softWhite;
  static const Color darkTextSecondary = _mutedGrey;

  // --- Testament Colors ---
  static const Color oldTestament = Color(0xFF08164B); 
  static const Color newTestament = Color(0xFF3B1C07); 

  // --- Functional & Universal ---
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color secondaryAccent = Color(0xFFD4A373);
  static const Color overlay = Color(0x66000000); 
}
