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
}
