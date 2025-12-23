
class Bookmark {
  final String id;
  final String verseText;
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.verseText,
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verseText': verseText,
      'bookName': bookName,
      'chapterNumber': chapterNumber,
      'verseNumber': verseNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      verseText: json['verseText'] as String,
      bookName: json['bookName'] as String,
      chapterNumber: json['chapterNumber'] as int,
      verseNumber: json['verseNumber'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
