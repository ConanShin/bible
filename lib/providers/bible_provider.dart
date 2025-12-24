import 'package:flutter/foundation.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';
import '../services/bible_service.dart';

class BibleProvider with ChangeNotifier {
  final BibleService _bibleService;

  List<BibleBook> get books => _bibleService.loadBibleDataSync();

  List<Map<String, dynamic>> _versions = [];
  List<Map<String, dynamic>> get versions => _versions;

  bool _isLoading = false;
  bool get isLoading => _isLoading || _bibleService.isDownloading;

  BibleProvider(this._bibleService) {
    _bibleService.addListener(_onServiceChanged);
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    _versions = await _bibleService.getAvailableVersions();
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

  Future<List<Map<String, dynamic>>> getAvailableVersions() async {
    return await _bibleService.getAvailableVersions();
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

  BibleVerse? getTodayVerse() {
    final allVerses = getAllVerses();
    if (allVerses.isEmpty) return null;

    final now = DateTime.now();
    final dayOfYear = int.parse(
      "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}",
    );

    return allVerses[dayOfYear % allVerses.length];
  }
}
