import 'bible_database.dart';

class Bookmark {
  final String id;
  final String verseText;
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final DateTime createdAt;

  final String? note;

  Bookmark({
    required this.id,
    required this.verseText,
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.createdAt,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      BookmarkTable.columnId: id,
      BookmarkTable.columnVerseText: verseText,
      BookmarkTable.columnBookName: bookName,
      BookmarkTable.columnChapterNumber: chapterNumber,
      BookmarkTable.columnVerseNumber: verseNumber,
      BookmarkTable.columnCreatedAt: createdAt.toIso8601String(),
      BookmarkTable.columnNote: note,
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json[BookmarkTable.columnId] as String,
      verseText: json[BookmarkTable.columnVerseText] as String,
      bookName: json[BookmarkTable.columnBookName] as String,
      chapterNumber: json[BookmarkTable.columnChapterNumber] as int,
      verseNumber: json[BookmarkTable.columnVerseNumber] as int,
      createdAt: DateTime.parse(json[BookmarkTable.columnCreatedAt] as String),
      note: json[BookmarkTable.columnNote] as String?,
    );
  }
}

