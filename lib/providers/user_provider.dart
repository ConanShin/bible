
import 'package:flutter/foundation.dart';
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
    notifyListeners();
  }

  Future<void> updatePreferences(UserPreferences newPrefs) async {
    _preferences = newPrefs;
    await _storageService.saveUserPreferences(newPrefs);
    notifyListeners();
  }

  // Bookmarks
  List<BibleVerse> _bookmarks = [];
  List<BibleVerse> get bookmarks => _bookmarks;

  void addBookmark(BibleVerse verse) {
    if (!_bookmarks.any((v) => v.text == verse.text && v.bookName == verse.bookName)) {
      _bookmarks.add(verse);
      notifyListeners();
      // TODO: Persist bookmarks
    }
  }

  void removeBookmark(BibleVerse verse) {
    _bookmarks.removeWhere((v) => v.text == verse.text && v.bookName == verse.bookName);
    notifyListeners();
    // TODO: Persist bookmarks
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
      // TODO: Persist history
    }
  }
}
