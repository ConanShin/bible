import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import '../models/user_preferences.dart';
import '../services/local_storage_service.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';
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

  Future<void> loadState(BibleProvider bibleProvider) async {
    _isLoading = true;
    notifyListeners();

    _hasCompletedOnboarding = await _storage.getOnboardingStatus();
    _preferences = await _storage.getUserPreferences();

    // Load history from SQLite
    final historyData = await _storage.getHistory();
    final books = bibleProvider.books;

    _readingHistory = historyData.map((map) {
      final bookId = map[ReadingHistoryTable.columnBookId] as int;
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

  Future<void> updateBibleVersion(String newVersion) async {
    _preferences.selectedBibleVersion = newVersion;
    await _storage.saveUserPreferences(_preferences);
    notifyListeners();
  }

  // Bookmarks
  List<BibleVerse> _bookmarks = [];
  List<BibleVerse> get bookmarks => _bookmarks;

  void addBookmark(BibleVerse verse) {
    if (!_bookmarks.any(
      (v) => v.text == verse.text && v.bookName == verse.bookName,
    )) {
      _bookmarks.add(verse);
      notifyListeners();
      // TODO: Persist bookmarks in LocalStorageService
    }
  }

  void removeBookmark(BibleVerse verse) {
    _bookmarks.removeWhere(
      (v) => v.text == verse.text && v.bookName == verse.bookName,
    );
    notifyListeners();
    // TODO: Persist bookmarks in LocalStorageService
  }

  void toggleBookmark(BibleVerse verse) {
    if (_bookmarks.any(
      (v) => v.text == verse.text && v.bookName == verse.bookName,
    )) {
      removeBookmark(verse);
    } else {
      addBookmark(verse);
    }
  }

  // Reading History (placeholder for now using BibleBook as item)
  List<ReadingHistoryItem> _readingHistory = [];
  List<ReadingHistoryItem> get readingHistory => _readingHistory;

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

    if (_readingHistory.length > 20) {
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
