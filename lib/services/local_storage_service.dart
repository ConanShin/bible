import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import '../models/user_preferences.dart';
import '../models/bookmark.dart';
import '../models/bible_database.dart';
import '../models/bible_book.dart';
import '../models/bible_chapter.dart';
import '../models/bible_verse.dart';

class LocalStorageService {
  static const String KEY_ONBOARDING_COMPLETED = 'onboarding_completed';
  static const String KEY_THEME_MODE =
      'is_dark_mode'; // true: dark, false: light
  static const String KEY_FONT_SIZE = 'font_size';
  static const String KEY_BIBLE_VERSION = 'bible_version';
  static const String KEY_NOTIF_ENABLED = 'notification_enabled';
  static const String KEY_NOTIF_TIME_HOUR = 'notification_time_hour';
  static const String KEY_NOTIF_TIME_MINUTE = 'notification_time_minute';
  static const String KEY_BOOKMARKS = 'bookmarks';

  static Database? _database;
  final Logger _logger = Logger();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bible_app.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute(BibleDataTable.createTableSql);
        await db.execute(BibleMetadataTable.createTableSql);
        await db.execute(ReadingHistoryTable.createTableSql);
        await db.execute(BookmarkTable.createTableSql);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(ReadingHistoryTable.createTableSql);
        }
        if (oldVersion < 3) {
          await db.execute(BookmarkTable.createTableSql);
        }
      },
    );
  }

  Future<void> saveBibleData(String version, String jsonString) async {
    final db = await database;
    final data = jsonDecode(jsonString);
    final books = data['books'] as List;

    final batch = db.batch();

    for (var book in books) {
      final bookId = book['id'];
      final bookName = book['name'];
      final chapters = book['chapters'] as List;

      for (var chapter in chapters) {
        final chapterNumber = chapter['chapterNumber'];
        final verses = chapter['verses'] as List;

        for (var verse in verses) {
          batch.insert(BibleDataTable.tableName, {
            BibleDataTable.columnVersion: version,
            BibleDataTable.columnBookId: bookId,
            BibleDataTable.columnBookName: bookName,
            BibleDataTable.columnChapterNumber: chapterNumber,
            BibleDataTable.columnVerseNumber: verse['verseNumber'],
            BibleDataTable.columnVerseText: verse['text'],
            BibleDataTable.columnCreatedAt: DateTime.now().toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    }

    await batch.commit(noResult: true);
    _logger.i('Saved Bible data for version: $version');
  }

  Future<void> saveBibleMetadata(
    String version,
    Map<String, dynamic> metadata,
  ) async {
    final db = await database;
    await db.insert(BibleMetadataTable.tableName, {
      BibleMetadataTable.columnVersion: version,
      BibleMetadataTable.columnDownloadedAt: metadata['downloadedAt'],
      BibleMetadataTable.columnSize: metadata['size'],
      BibleMetadataTable.columnVerseCount: 0, // Placeholder, can be calculated
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<BibleBook>> loadBibleData(String version) async {
    final db = await database;

    // Get all verses ordered by book, chapter, verse
    final List<Map<String, dynamic>> maps = await db.query(
      BibleDataTable.tableName,
      where: '${BibleDataTable.columnVersion} = ?',
      whereArgs: [version],
      orderBy:
          '${BibleDataTable.columnBookId}, ${BibleDataTable.columnChapterNumber}, ${BibleDataTable.columnVerseNumber}',
    );

    if (maps.isEmpty) return [];

    // Transform flat list of verses into hierarchical structure
    List<BibleBook> books = [];
    int currentBookId = -1;
    BibleBook? currentBook;
    int currentChapterNum = -1;
    BibleChapter? currentChapter;

    for (var map in maps) {
      int bookId = map[BibleDataTable.columnBookId];
      String bookName = map[BibleDataTable.columnBookName];
      int chapterNum = map[BibleDataTable.columnChapterNumber];
      int verseNum = map[BibleDataTable.columnVerseNumber];
      String verseText = map[BibleDataTable.columnVerseText];

      if (bookId != currentBookId) {
        currentBook = BibleBook(
          id: bookId,
          name: bookName,
          englishName: bookName, // Fallback to name if not stored
          abbreviation: bookName.substring(0, 1),
          testament: bookId <= 39
              ? 'old'
              : 'new', // Simple heuristic for Protestant Bible
          totalChapters: 0, // Not stored in this table
          chapters: [],
        );
        books.add(currentBook);
        currentBookId = bookId;
        currentChapterNum = -1;
      }

      if (chapterNum != currentChapterNum) {
        currentChapter = BibleChapter(
          chapterNumber: chapterNum,
          bookName: bookName,
          verses: [],
        );
        if (currentBook != null) {
          currentBook.chapters.add(currentChapter);
        }
        currentChapterNum = chapterNum;
      }

      if (currentChapter != null) {
        currentChapter.verses.add(
          BibleVerse(
            bookName: bookName,
            chapterNumber: chapterNum,
            verseNumber: verseNum,
            text: verseText,
          ),
        );
      }
    }

    return books;
  }

  Future<bool> isBibleDataExists(String version) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${BibleMetadataTable.tableName} WHERE ${BibleMetadataTable.columnVersion} = ?',
        [version],
      ),
    );
    return (count ?? 0) > 0;
  }

  Future<int> getBibleDataSize(String version) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      BibleMetadataTable.tableName,
      columns: [BibleMetadataTable.columnSize],
      where: '${BibleMetadataTable.columnVersion} = ?',
      whereArgs: [version],
    );
    if (maps.isNotEmpty) {
      return maps.first[BibleMetadataTable.columnSize] as int;
    }
    return 0;
  }

  Future<void> deleteBibleData(String version) async {
    final db = await database;
    await db.delete(
      BibleDataTable.tableName,
      where: '${BibleDataTable.columnVersion} = ?',
      whereArgs: [version],
    );
    await db.delete(
      BibleMetadataTable.tableName,
      where: '${BibleMetadataTable.columnVersion} = ?',
      whereArgs: [version],
    );
  }

  Future<void> saveOnboardingStatus(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_ONBOARDING_COMPLETED, completed);
  }

  Future<bool> getOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_ONBOARDING_COMPLETED) ?? false;
  }

  Future<void> saveUserPreferences(UserPreferences prefs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(KEY_THEME_MODE, prefs.isDarkMode);
    await sp.setDouble(KEY_FONT_SIZE, prefs.fontSize);
    await sp.setString(KEY_BIBLE_VERSION, prefs.selectedBibleVersion);
    await sp.setBool(KEY_NOTIF_ENABLED, prefs.isNotificationEnabled);
    await sp.setInt(KEY_NOTIF_TIME_HOUR, prefs.dailyNotificationTime.hour);
    await sp.setInt(KEY_NOTIF_TIME_MINUTE, prefs.dailyNotificationTime.minute);
  }

  Future<UserPreferences> getUserPreferences() async {
    final sp = await SharedPreferences.getInstance();
    final storedVersion = sp.getString(KEY_BIBLE_VERSION) ?? 'krv';
    final version = _migrateLegacyVersion(storedVersion);

    // Determine default dark mode from system settings
    bool defaultDarkMode = false;
    try {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      defaultDarkMode = brightness == Brightness.dark;
    } catch (_) {
      // Fallback if binding not initialized
    }

    return UserPreferences(
      isDarkMode: sp.getBool(KEY_THEME_MODE) ?? defaultDarkMode,
      fontSize: sp.getDouble(KEY_FONT_SIZE) ?? 16.0,
      selectedBibleVersion: version,
      isNotificationEnabled: sp.getBool(KEY_NOTIF_ENABLED) ?? false,
      dailyNotificationTime: TimeOfDay(
        hour: sp.getInt(KEY_NOTIF_TIME_HOUR) ?? 6,
        minute: sp.getInt(KEY_NOTIF_TIME_MINUTE) ?? 0,
      ),
    );
  }

  String _migrateLegacyVersion(String version) {
    const migrationMap = {
      '개역개정': 'krv',
      '새번역': 'knv',
      '쉬운성경': 'easy',
      '개역한글': 'rv',
    };
    return migrationMap[version] ?? version;
  }

  // --- Reading History ---

  Future<void> saveHistoryItem(
    int bookId,
    int chapterNumber,
    int verseNumber,
  ) async {
    final db = await database;
    final timestamp = DateTime.now().toIso8601String();

    await db.insert(ReadingHistoryTable.tableName, {
      ReadingHistoryTable.columnBookId: bookId,
      ReadingHistoryTable.columnChapterNumber: chapterNumber,
      ReadingHistoryTable.columnVerseNumber: verseNumber,
      ReadingHistoryTable.columnTimestamp: timestamp,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    return await db.query(
      ReadingHistoryTable.tableName,
      orderBy: '${ReadingHistoryTable.columnTimestamp} DESC',
      limit: 20,
    );
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete(ReadingHistoryTable.tableName);
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(BibleDataTable.tableName);
      await txn.delete(BibleMetadataTable.tableName);
      await txn.delete(ReadingHistoryTable.tableName);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _logger.i('All local data and preferences cleared.');
  }

  // --- Bookmarks ---

  Future<void> saveBookmark(Bookmark bookmark) async {
    final db = await database;
    await db.insert(
      BookmarkTable.tableName,
      bookmark.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBookmark(String id) async {
    final db = await database;
    await db.delete(
      BookmarkTable.tableName,
      where: '${BookmarkTable.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Bookmark>> getBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      BookmarkTable.tableName,
      orderBy: '${BookmarkTable.columnCreatedAt} DESC',
    );

    return List.generate(maps.length, (i) {
      return Bookmark.fromJson(maps[i]);
    });
  }
}
