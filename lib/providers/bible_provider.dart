import 'package:flutter/foundation.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';
import '../services/bible_service.dart';
import '../utils/hangul_utils.dart';

class BibleProvider with ChangeNotifier {
  final BibleService _bibleService;

  List<BibleBook> get books => _bibleService.loadBibleDataSync();

  List<Map<String, dynamic>> _versions = [];
  List<Map<String, dynamic>> get versions => _versions;

  String? _currentLanguageCode;
  String? get currentLanguageCode => _currentLanguageCode;

  bool _isLoading = false;
  bool get isLoading => _isLoading || _bibleService.isDownloading;

  BibleProvider(this._bibleService) {
    _bibleService.addListener(_onServiceChanged);
    _loadVersions();
  }

  Future<void> updateLanguageFilter(String languageCode) async {
    await _loadVersions(languageCode: languageCode);
  }

  Future<void> _loadVersions({String? languageCode}) async {
    _currentLanguageCode = languageCode;
    _versions = await _bibleService.getAvailableVersions(
      languageCode: languageCode,
    );
    notifyListeners();
  }

  void _onServiceChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _bibleService.removeListener(_onServiceChanged);
    super.dispose();
  }

  Future<void> loadBibleData({String? version}) async {
    _isLoading = true;
    notifyListeners();

    await _bibleService.loadBibleData(version: version);

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getAvailableVersions({
    String? languageCode,
  }) async {
    return await _bibleService.getAvailableVersions(languageCode: languageCode);
  }

  List<BibleVerse> getAllVerses() {
    List<BibleVerse> allVerses = [];
    for (var book in books) {
      for (var chapter in book.chapters) {
        allVerses.addAll(chapter.verses);
      }
    }
    return allVerses;
  }

  BibleVerse? getVerse(String bookName, int chapterNumber, int verseNumber) {
    if (books.isEmpty) return null;

    try {
      final book = books.firstWhere(
        (b) => b.name == bookName || b.englishName == bookName,
      );
      final chapter = book.chapters.firstWhere(
        (c) => c.chapterNumber == chapterNumber,
      );
      return chapter.verses.firstWhere((v) => v.verseNumber == verseNumber);
    } catch (e) {
      return null;
    }
  }

  BibleVerse? getTodayVerse() {
    final allVerses = getAllVerses();
    if (allVerses.isEmpty) return null;

    final now = DateTime.now();
    final dayOfYear = int.parse(
      "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}",
    );

    return allVerses[dayOfYear % allVerses.length];
  }

  List<BibleVerse> searchVerses(String query) {
    if (query.trim().isEmpty) {
      return [];
    }

    final terms = query.trim().toLowerCase().split(RegExp(r'\s+'));
    final allVerses = getAllVerses();

    return allVerses.where((verse) {
      final text = verse.text;
      // All terms must be present in the verse text (literal or chosung)
      return terms.every((term) => HangulUtils.matches(text, term));
    }).toList();
  }
}
