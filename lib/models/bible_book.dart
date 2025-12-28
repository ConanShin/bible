import 'bible_chapter.dart';

class BibleBook {
  final int id;
  final String name;
  final String englishName;
  final String abbreviation;
  final String testament; // 'old' or 'new'
  final int totalChapters;
  final List<BibleChapter> chapters;

  BibleBook({
    required this.id,
    required this.name,
    required this.englishName,
    required this.abbreviation,
    required this.testament,
    required this.totalChapters,
    required this.chapters,
  });

  String getDisplayName(String lang) {
    return lang == 'ko' ? name : englishName;
  }

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    var list = json['chapters'] as List;
    String bookName = json['name'] as String;
    List<BibleChapter> chaptersList = list
        .map((i) => BibleChapter.fromJson(i, bookName))
        .toList();

    return BibleBook(
      id: json['id'] as int,
      name: bookName,
      englishName: json['englishName'] as String,
      abbreviation: json['abbreviation'] as String,
      testament: json['testament'] as String,
      totalChapters: json['totalChapters'] as int,
      chapters: chaptersList,
    );
  }
}
