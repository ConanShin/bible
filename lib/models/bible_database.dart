class BibleDataTable {
  static const String tableName = 'bible_data';

  static const String columnId = 'id';
  static const String columnVersion = 'version';
  static const String columnBookId = 'book_id';
  static const String columnBookName = 'book_name';
  static const String columnChapterNumber = 'chapter_number';
  static const String columnVerseNumber = 'verse_number';
  static const String columnVerseText = 'verse_text';
  static const String columnCreatedAt = 'created_at';

  static const String createTableSql =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnVersion TEXT NOT NULL,
      $columnBookId INTEGER NOT NULL,
      $columnBookName TEXT NOT NULL,
      $columnChapterNumber INTEGER NOT NULL,
      $columnVerseNumber INTEGER NOT NULL,
      $columnVerseText TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      UNIQUE($columnVersion, $columnBookId, $columnChapterNumber, $columnVerseNumber)
    )
  ''';
}

class BibleMetadataTable {
  static const String tableName = 'bible_metadata';

  static const String columnVersion = 'version';
  static const String columnDownloadedAt = 'downloaded_at';
  static const String columnSize = 'size';
  static const String columnVerseCount = 'verse_count';

  static const String createTableSql =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnVersion TEXT PRIMARY KEY,
      $columnDownloadedAt TEXT NOT NULL,
      $columnSize INTEGER NOT NULL,
      $columnVerseCount INTEGER NOT NULL
    )
  ''';
}


class ReadingHistoryTable {
  static const String tableName = 'reading_history';

  static const String columnId = 'id';
  static const String columnBookId = 'book_id';
  static const String columnChapterNumber = 'chapter_number';
  static const String columnVerseNumber = 'verse_number';
  static const String columnTimestamp = 'timestamp';

  static const String createTableSql =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnBookId INTEGER NOT NULL,
      $columnChapterNumber INTEGER NOT NULL,
      $columnVerseNumber INTEGER NOT NULL,
      $columnTimestamp TEXT NOT NULL,
      UNIQUE($columnBookId, $columnChapterNumber, $columnVerseNumber)
    )
  ''';
}

class BookmarkTable {
  static const String tableName = 'bookmarks';

  static const String columnId = 'id';
  static const String columnBookName = 'book_name';
  static const String columnChapterNumber = 'chapter_number';
  static const String columnVerseNumber = 'verse_number';
  static const String columnVerseText = 'verse_text';
  static const String columnNote = 'note';
  static const String columnCreatedAt = 'created_at';

  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnBookName TEXT NOT NULL,
      $columnChapterNumber INTEGER NOT NULL,
      $columnVerseNumber INTEGER NOT NULL,
      $columnVerseText TEXT NOT NULL,
      $columnNote TEXT,
      $columnCreatedAt TEXT NOT NULL
    )
  ''';
}

