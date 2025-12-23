
import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeData get themeData => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  Future<void> loadThemeMode() async {
    final prefs = await _storageService.getUserPreferences();
    _isDarkMode = prefs.isDarkMode;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    // In a real app we'd save this change immediately or via UserProvider
  }
  
  // Helper to sync with UserProvider updates if needed
  void setDarkMode(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
    }
  }
}
