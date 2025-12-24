class BibleDataParser {
  static const Map<String, Map<String, dynamic>> _bookMetadata = {
    '창': {'id': 1, 'name': '창세기', 'englishName': 'Genesis', 'testament': 'old'},
    '출': {'id': 2, 'name': '출애굽기', 'englishName': 'Exodus', 'testament': 'old'},
    '레': {
      'id': 3,
      'name': '레위기',
      'englishName': 'Leviticus',
      'testament': 'old',
    },
    '민': {'id': 4, 'name': '민수기', 'englishName': 'Numbers', 'testament': 'old'},
    '신': {
      'id': 5,
      'name': '신명기',
      'englishName': 'Deuteronomy',
      'testament': 'old',
    },
    '수': {'id': 6, 'name': '여호수아', 'englishName': 'Joshua', 'testament': 'old'},
    '삿': {'id': 7, 'name': '사사기', 'englishName': 'Judges', 'testament': 'old'},
    '룻': {'id': 8, 'name': '룻기', 'englishName': 'Ruth', 'testament': 'old'},
    '삼상': {
      'id': 9,
      'name': '사무엘상',
      'englishName': '1 Samuel',
      'testament': 'old',
    },
    '삼하': {
      'id': 10,
      'name': '사무엘하',
      'englishName': '2 Samuel',
      'testament': 'old',
    },
    '왕상': {
      'id': 11,
      'name': '열왕기상',
      'englishName': '1 Kings',
      'testament': 'old',
    },
    '왕하': {
      'id': 12,
      'name': '열왕기하',
      'englishName': '2 Kings',
      'testament': 'old',
    },
    '대상': {
      'id': 13,
      'name': '역대상',
      'englishName': '1 Chronicles',
      'testament': 'old',
    },
    '대하': {
      'id': 14,
      'name': '역대하',
      'englishName': '2 Chronicles',
      'testament': 'old',
    },
    '스': {'id': 15, 'name': '에스라', 'englishName': 'Ezra', 'testament': 'old'},
    '느': {
      'id': 16,
      'name': '느헤미야',
      'englishName': 'Nehemiah',
      'testament': 'old',
    },
    '에': {'id': 17, 'name': '에스더', 'englishName': 'Esther', 'testament': 'old'},
    '욥': {'id': 18, 'name': '욥기', 'englishName': 'Job', 'testament': 'old'},
    '시': {'id': 19, 'name': '시편', 'englishName': 'Psalms', 'testament': 'old'},
    '잠': {
      'id': 20,
      'name': '잠언',
      'englishName': 'Proverbs',
      'testament': 'old',
    },
    '전': {
      'id': 21,
      'name': '전도서',
      'englishName': 'Ecclesiastes',
      'testament': 'old',
    },
    '아': {
      'id': 22,
      'name': '아가',
      'englishName': 'Song of Solomon',
      'testament': 'old',
    },
    '사': {'id': 23, 'name': '이사야', 'englishName': 'Isaiah', 'testament': 'old'},
    '렘': {
      'id': 24,
      'name': '예레미야',
      'englishName': 'Jeremiah',
      'testament': 'old',
    },
    '애': {
      'id': 25,
      'name': '예레미야 애가',
      'englishName': 'Lamentations',
      'testament': 'old',
    },
    '겔': {
      'id': 26,
      'name': '에스겔',
      'englishName': 'Ezekiel',
      'testament': 'old',
    },
    '단': {'id': 27, 'name': '다니엘', 'englishName': 'Daniel', 'testament': 'old'},
    '호': {'id': 28, 'name': '호세아', 'englishName': 'Hosea', 'testament': 'old'},
    '욜': {'id': 29, 'name': '요엘', 'englishName': 'Joel', 'testament': 'old'},
    '암': {'id': 30, 'name': '아모스', 'englishName': 'Amos', 'testament': 'old'},
    '오': {
      'id': 31,
      'name': '오바댜',
      'englishName': 'Obadiah',
      'testament': 'old',
    },
    '욘': {'id': 32, 'name': '요나', 'englishName': 'Jonah', 'testament': 'old'},
    '미': {'id': 33, 'name': '미가', 'englishName': 'Micah', 'testament': 'old'},
    '나': {'id': 34, 'name': '나훔', 'englishName': 'Nahum', 'testament': 'old'},
    '합': {
      'id': 35,
      'name': '하박국',
      'englishName': 'Hashakkuk',
      'testament': 'old',
    },
    '습': {
      'id': 36,
      'name': '스바냐',
      'englishName': 'Zephaniah',
      'testament': 'old',
    },
    '학': {'id': 37, 'name': '학개', 'englishName': 'Haggai', 'testament': 'old'},
    '슥': {
      'id': 38,
      'name': '스가랴',
      'englishName': 'Zechariah',
      'testament': 'old',
    },
    '말': {
      'id': 39,
      'name': '말라기',
      'englishName': 'Malachi',
      'testament': 'old',
    },
    '마': {
      'id': 40,
      'name': '마태복음',
      'englishName': 'Matthew',
      'testament': 'new',
    },
    '막': {'id': 41, 'name': '마가복음', 'englishName': 'Mark', 'testament': 'new'},
    '눅': {'id': 42, 'name': '누가복음', 'englishName': 'Luke', 'testament': 'new'},
    '요': {'id': 43, 'name': '요한복음', 'englishName': 'John', 'testament': 'new'},
    '행': {'id': 44, 'name': '사도행전', 'englishName': 'Acts', 'testament': 'new'},
    '롬': {'id': 45, 'name': '로마서', 'englishName': 'Romans', 'testament': 'new'},
    '고전': {
      'id': 46,
      'name': '고린도전서',
      'englishName': '1 Corinthians',
      'testament': 'new',
    },
    '고후': {
      'id': 47,
      'name': '고린도후서',
      'englishName': '2 Corinthians',
      'testament': 'new',
    },
    '갈': {
      'id': 48,
      'name': '갈라디아서',
      'englishName': 'Galatians',
      'testament': 'new',
    },
    '엡': {
      'id': 49,
      'name': '에베소서',
      'englishName': 'Ephesians',
      'testament': 'new',
    },
    '빌': {
      'id': 50,
      'name': '빌립보서',
      'englishName': 'Philippians',
      'testament': 'new',
    },
    '골': {
      'id': 51,
      'name': '골로새서',
      'englishName': 'Colossians',
      'testament': 'new',
    },
    '살전': {
      'id': 52,
      'name': '데살로니가전서',
      'englishName': '1 Thessalonians',
      'testament': 'new',
    },
    '살후': {
      'id': 53,
      'name': '데살로니가후서',
      'englishName': '2 Thessalonians',
      'testament': 'new',
    },
    '딤전': {
      'id': 54,
      'name': '디모데전서',
      'englishName': '1 Timothy',
      'testament': 'new',
    },
    '딤후': {
      'id': 55,
      'name': '디모데후서',
      'englishName': '2 Timothy',
      'testament': 'new',
    },
    '딛': {'id': 56, 'name': '디도서', 'englishName': 'Titus', 'testament': 'new'},
    '몬': {
      'id': 57,
      'name': '빌레몬서',
      'englishName': 'Philemon',
      'testament': 'new',
    },
    '히': {
      'id': 58,
      'name': '히브리서',
      'englishName': 'Hebrews',
      'testament': 'new',
    },
    '약': {'id': 59, 'name': '야고보서', 'englishName': 'James', 'testament': 'new'},
    '벧전': {
      'id': 60,
      'name': '베드로전서',
      'englishName': '1 Peter',
      'testament': 'new',
    },
    '벧후': {
      'id': 61,
      'name': '베드로후서',
      'englishName': '2 Peter',
      'testament': 'new',
    },
    '요일': {
      'id': 62,
      'name': '요한일서',
      'englishName': '1 John',
      'testament': 'new',
    },
    '요이': {
      'id': 63,
      'name': '요한이서',
      'englishName': '2 John',
      'testament': 'new',
    },
    '요삼': {
      'id': 64,
      'name': '요한삼서',
      'englishName': '3 John',
      'testament': 'new',
    },
    '유': {'id': 65, 'name': '유다서', 'englishName': 'Jude', 'testament': 'new'},
    '계': {
      'id': 66,
      'name': '요한계시록',
      'englishName': 'Revelation',
      'testament': 'new',
    },
  };

  static final RegExp _verseKeyRegex = RegExp(r'^([^\d]+)(\d+):(\d+)$');

  /// Parses flat JSON format {"창1:1": "..."} to hierarchical map format
  static Map<String, dynamic> parseFlatBibleJson(
    Map<String, dynamic> flatData,
  ) {
    final Map<int, Map<String, dynamic>> booksMap = {};

    flatData.forEach((key, value) {
      final match = _verseKeyRegex.firstMatch(key);
      if (match == null) return;

      final String abbr = match.group(1)!;
      final int chapterNum = int.parse(match.group(2)!);
      final int verseNum = int.parse(match.group(3)!);

      final meta = _bookMetadata[abbr];
      if (meta == null) return;

      final int bookId = meta['id'] as int;

      final bookData = booksMap.putIfAbsent(
        bookId,
        () => {
          'id': bookId,
          'name': meta['name'],
          'englishName': meta['englishName'],
          'abbreviation': abbr,
          'testament': meta['testament'],
          'totalChapters': 0,
          'chapters': <int, Map<String, dynamic>>{},
        },
      );

      final Map<int, Map<String, dynamic>> chapters = bookData['chapters'];
      final chapterData = chapters.putIfAbsent(
        chapterNum,
        () => {'chapterNumber': chapterNum, 'verses': []},
      );

      (chapterData['verses'] as List).add({
        'verseNumber': verseNum,
        'text': value.toString().trim(),
      });
    });

    // Convert internal maps to lists as expected by the app
    List<Map<String, dynamic>> finalBooks = [];
    var sortedBookIds = booksMap.keys.toList()..sort();

    for (var bookId in sortedBookIds) {
      var bookData = booksMap[bookId]!;
      Map<int, Map<String, dynamic>> chaptersMap = bookData['chapters'];
      List<Map<String, dynamic>> finalChapters = [];

      var sortedChapterNums = chaptersMap.keys.toList()..sort();
      for (var chapterNum in sortedChapterNums) {
        var chapterData = chaptersMap[chapterNum]!;
        // Sort verses
        (chapterData['verses'] as List).sort(
          (a, b) =>
              (a['verseNumber'] as int).compareTo(b['verseNumber'] as int),
        );
        finalChapters.add(chapterData);
      }

      bookData['chapters'] = finalChapters;
      bookData['totalChapters'] = finalChapters.length;
      finalBooks.add(bookData);
    }

    return {'books': finalBooks};
  }
}
