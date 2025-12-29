import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter/widgets.dart';
import '../models/user_preferences.dart';
import '../services/local_storage_service.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';
import '../models/bookmark.dart';
import '../models/reading_history_item.dart';
import '../providers/bible_provider.dart';
import '../models/bible_database.dart';

class UserProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  UserPreferences _preferences = UserPreferences();
  UserPreferences get preferences => _preferences;

  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  UserProvider() {
    _initDefaultLanguage();
  }

  void _initDefaultLanguage() {
    try {
      final systemLocale =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      if (systemLocale == 'ko') {
        _preferences.appLanguage = 'ko';
      } else {
        _preferences.appLanguage = 'en';
      }
    } catch (_) {
      // Fallback already set to 'en' in UserPreferences
    }
  }

  Future<void> loadPreferences() async {
    _isLoading = true;
    notifyListeners();

    _hasCompletedOnboarding = await _storage.getOnboardingStatus();
    _preferences = await _storage.getUserPreferences();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserData(BibleProvider bibleProvider) async {
    _isLoading = true;
    notifyListeners();

    // Load history from SQLite
    try {
      final historyData = await _storage.getHistory();
      final books = bibleProvider.books;

      _readingHistory = historyData.map((map) {
        final bookId = map[ReadingHistoryTable.columnBookId] as int;
        // Handle case where book ID might not exist in current version if swapped
        final book = books.firstWhere(
          (b) => b.id == bookId,
          orElse: () => books.first,
        );

        return ReadingHistoryItem(
          book: book,
          chapterNumber: map[ReadingHistoryTable.columnChapterNumber] as int,
          verseNumber: map[ReadingHistoryTable.columnVerseNumber] as int,
          timestamp: DateTime.parse(map[ReadingHistoryTable.columnTimestamp]),
        );
      }).toList();

      // Load bookmarks
      _bookmarks = await _storage.getBookmarks();
    } catch (e) {
      print('Error loading user data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _storage.saveOnboardingStatus(true);
    // Also ensure current preferences are saved
    await _storage.saveUserPreferences(_preferences);
    notifyListeners();
  }

  Future<void> updatePreferences(UserPreferences newPrefs) async {
    _preferences = newPrefs;
    await _storage.saveUserPreferences(newPrefs);
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
    } else if (key == 'appLanguage') {
      _preferences.appLanguage = value;
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
    await _storage.saveUserPreferences(_preferences);
    notifyListeners();
  }

  Future<void> updateLanguage(String lang) async {
    _preferences.appLanguage = lang;
    await _storage.saveUserPreferences(_preferences);
    notifyListeners();
  }

  Future<void> updateBibleVersion(String newVersion) async {
    _preferences.selectedBibleVersion = newVersion;
    await _storage.saveUserPreferences(_preferences);
    notifyListeners();
  }

  // Bookmarks
  List<Bookmark> _bookmarks = [];
  List<Bookmark> get bookmarks => _bookmarks;

  bool isBookmarked(BibleVerse verse) {
    return _bookmarks.any(
      (b) =>
          b.bookName == verse.bookName &&
          b.chapterNumber == verse.chapterNumber &&
          b.verseNumber == verse.verseNumber,
    );
  }

  Future<void> addBookmark(BibleVerse verse, {String? note}) async {
    final newBookmark = Bookmark(
      id: '${verse.bookName}_${verse.chapterNumber}_${verse.verseNumber}',
      verseText: verse.text,
      bookName: verse.bookName,
      chapterNumber: verse.chapterNumber,
      verseNumber: verse.verseNumber,
      createdAt: DateTime.now(),
      note: note,
    );

    // Remove if exists (to update note)
    _bookmarks.removeWhere(
      (b) =>
          b.bookName == verse.bookName &&
          b.chapterNumber == verse.chapterNumber &&
          b.verseNumber == verse.verseNumber,
    );

    _bookmarks.insert(0, newBookmark);
    notifyListeners();

    await _storage.saveBookmark(newBookmark);
  }

  Future<void> removeBookmark(BibleVerse verse) async {
    final id = '${verse.bookName}_${verse.chapterNumber}_${verse.verseNumber}';
    _bookmarks.removeWhere((b) => b.id == id);
    notifyListeners();

    await _storage.deleteBookmark(id);
  }

  Future<void> deleteBookmarkById(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
    notifyListeners();
    await _storage.deleteBookmark(id);
  }

  // Reading History (placeholder for now using BibleBook as item)
  List<ReadingHistoryItem> _readingHistory = [];
  List<ReadingHistoryItem> get readingHistory => _readingHistory;

  Future<void> resetApp() async {
    await _storage.clearAllData();

    // Reset in-memory state
    _hasCompletedOnboarding = false;
    _preferences = await _storage.getUserPreferences();
    _bookmarks = [];
    _readingHistory = [];

    notifyListeners();
  }

  void addToHistory(BibleBook book, int chapterNumber, int verseNumber) async {
    // Remove if already exists with same content to avoid duplicates and move to top
    _readingHistory.removeWhere(
      (item) =>
          item.book.id == book.id &&
          item.chapterNumber == chapterNumber &&
          item.verseNumber == verseNumber,
    );

    _readingHistory.insert(
      0,
      ReadingHistoryItem(
        book: book,
        chapterNumber: chapterNumber,
        verseNumber: verseNumber,
        timestamp: DateTime.now(),
      ),
    );

    if (_readingHistory.length > 30) {
      _readingHistory.removeLast();
    }

    notifyListeners();

    // Persist to SQLite
    await _storage.saveHistoryItem(book.id, chapterNumber, verseNumber);
    print(
      "Saved to persistent history: ${book.name} $chapterNumber:$verseNumber",
    );
  }
}
