
class BibleVerse {
  final int verseNumber;
  final String text;
  final String bookName;
  final int chapterNumber;
  final bool isHighlighted;
  bool isBookmarked;

  BibleVerse({
    required this.verseNumber,
    required this.text,
    this.bookName = '',
    this.chapterNumber = 0,
    this.isHighlighted = false,
    this.isBookmarked = false,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      verseNumber: json['verseNumber'] as int,
      text: json['text'] as String,
      bookName: json['bookName'] as String? ?? '',
      chapterNumber: json['chapterNumber'] as int? ?? 0,
    );
  }
}
