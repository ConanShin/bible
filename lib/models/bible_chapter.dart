
import 'bible_verse.dart';

class BibleChapter {
  final int chapterNumber;
  final String bookName;
  final List<BibleVerse> verses;
  bool isRead;

  BibleChapter({
    required this.chapterNumber,
    required this.bookName,
    required this.verses,
    this.isRead = false,
  });

  factory BibleChapter.fromJson(Map<String, dynamic> json, String bookName) {
    var list = json['verses'] as List;
    List<BibleVerse> versesList = list.map((i) {
      // Inject bookName and chapterNumber into verse for flattened usage if needed
      var verse = BibleVerse.fromJson(i); 
      return BibleVerse(
        verseNumber: verse.verseNumber,
        text: verse.text,
        bookName: bookName,
        chapterNumber: json['chapterNumber'] as int,
      );
    }).toList();

    return BibleChapter(
      chapterNumber: json['chapterNumber'] as int,
      bookName: bookName,
      verses: versesList,
    );
  }
}
