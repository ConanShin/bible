import 'package:flutter_test/flutter_test.dart';
import 'package:bible_app/utils/bible_data_parser.dart';

void main() {
  group('BibleDataParser Tests', () {
    test(
      'parseFlatBibleJson should correctly transform flat format to hierarchical',
      () {
        final flatData = {
          "창1:1": "태초에 하나님이 천지를 창조하시니라",
          "창1:2": "땅이 혼돈하고 공허하며...",
          "마1:1": "아브라함과 다윗의 자손...",
        };

        final result = BibleDataParser.parseFlatBibleJson(flatData);

        expect(result.containsKey('books'), true);
        final books = result['books'] as List;
        expect(books.length, 2); // 창세기, 마태복음

        // Check Genesis (ID 1)
        final genesis = books.firstWhere((b) => b['id'] == 1);
        expect(genesis['name'], '창세기');
        expect((genesis['chapters'] as List).length, 1);
        final chapter1 = (genesis['chapters'] as List)[0];
        expect(chapter1['chapterNumber'], 1);
        expect((chapter1['verses'] as List).length, 2);
        expect((chapter1['verses'] as List)[0]['verseNumber'], 1);
        expect((chapter1['verses'] as List)[0]['text'], '태초에 하나님이 천지를 창조하시니라');

        // Check Matthew (ID 40)
        final matthew = books.firstWhere((b) => b['id'] == 40);
        expect(matthew['name'], '마태복음');
      },
    );

    test('parseFlatBibleJson should handle sorting correctly', () {
      final flatData = {
        "창1:2": "Verse 2",
        "창1:1": "Verse 1",
        "창2:1": "Chapter 2 Verse 1",
      };

      final result = BibleDataParser.parseFlatBibleJson(flatData);
      final genesis = (result['books'] as List)[0];
      final chapters = genesis['chapters'] as List;

      expect(chapters.length, 2);
      expect(chapters[0]['chapterNumber'], 1);
      expect(chapters[1]['chapterNumber'], 2);

      final c1verses = chapters[0]['verses'] as List;
      expect(c1verses[0]['verseNumber'], 1);
      expect(c1verses[1]['verseNumber'], 2);
    });
  });
}
