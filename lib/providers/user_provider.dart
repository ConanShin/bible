import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import '../models/user_preferences.dart';
import '../services/local_storage_service.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';

class UserProvider with ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  
  UserPreferences _preferences = UserPreferences();
  UserPreferences get preferences => _preferences;
  
  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> loadState() async {
    _isLoading = true;
    notifyListeners();
    
    _hasCompletedOnboarding = await _storageService.getOnboardingStatus();
    _preferences = await _storageService.getUserPreferences();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _storageService.saveOnboardingStatus(true);
    // Also ensure current preferences are saved
    await _storageService.saveUserPreferences(_preferences);
    notifyListeners();
  }

  Future<void> updatePreferences(UserPreferences newPrefs) async {
    _preferences = newPrefs;
    await _storageService.saveUserPreferences(newPrefs);
    notifyListeners();
  }
  
  Future<void> savePreference(String key, dynamic value) async {
    // Update local object
    if (key == 'isDarkMode') {
      _preferences.isDarkMode = value;
    } else if (key == 'fontSize') {
      _preferences.fontSize = value;
    } else if (key == 'selectedBibleVersion') {
      _preferences.selectedBibleVersion = value;
    } else if (key == 'isNotificationEnabled') {
      _preferences.isNotificationEnabled = value;
    } else if (key == 'dailyNotificationTime') {
      // Assuming value is String "HH:mm"
      final parts = value.split(':');
      _preferences.dailyNotificationTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    
    // Save to disk
    await _storageService.saveUserPreferences(_preferences);
    notifyListeners();
  }

  Future<void> updateBibleVersion(String newVersion) async {
    _preferences.selectedBibleVersion = newVersion;
    await _storageService.saveUserPreferences(_preferences);
    notifyListeners();
  }

  // Bookmarks
  List<BibleVerse> _bookmarks = [];
  List<BibleVerse> get bookmarks => _bookmarks;

  void addBookmark(BibleVerse verse) {
    if (!_bookmarks.any((v) => v.text == verse.text && v.bookName == verse.bookName)) {
      _bookmarks.add(verse);
      notifyListeners();
      // TODO: Persist bookmarks in LocalStorageService
    }
  }

  void removeBookmark(BibleVerse verse) {
    _bookmarks.removeWhere((v) => v.text == verse.text && v.bookName == verse.bookName);
    notifyListeners();
    // TODO: Persist bookmarks in LocalStorageService
  }

  void toggleBookmark(BibleVerse verse) {
    if (_bookmarks.any((v) => v.text == verse.text && v.bookName == verse.bookName)) {
      removeBookmark(verse);
    } else {
      addBookmark(verse);
    }
  }

  // Reading History (placeholder for now using BibleBook as item)
  List<BibleBook> _readingHistory = [];
  List<BibleBook> get readingHistory => _readingHistory;

  void addToHistory(BibleBook book) {
    if (!_readingHistory.contains(book)) {
      _readingHistory.insert(0, book);
      if (_readingHistory.length > 5) {
        _readingHistory.removeLast();
      }
      notifyListeners();
      // TODO: Persist history in LocalStorageService
    }
  }
}
