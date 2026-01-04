import 'bible_book.dart';

class ReadingHistoryItem {
  final BibleBook book;
  final int chapterNumber;
  final int verseNumber;
  final DateTime timestamp;

  ReadingHistoryItem({
    required this.book,
    required this.chapterNumber,
    required this.verseNumber,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookId': book.id,
      'chapterNumber': chapterNumber,
      'verseNumber': verseNumber,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
