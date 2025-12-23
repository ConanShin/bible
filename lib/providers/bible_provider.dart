
import 'package:flutter/foundation.dart';
import '../models/bible_book.dart';
import '../models/bible_chapter.dart';
import '../models/bible_verse.dart';
import '../services/bible_service.dart';

class BibleProvider with ChangeNotifier {
  final BibleService _bibleService = BibleService();
  
  List<BibleBook> _books = [];
  List<BibleBook> get books => _books;
  
  List<Map<String, dynamic>> _versions = [];
  List<Map<String, dynamic>> get versions => _versions;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadBibleData() async {
    _isLoading = true;
    notifyListeners();
    
    _books = await _bibleService.loadBibleData();
    _versions = await _bibleService.getAvailableVersions();
    
    _isLoading = false;
    notifyListeners();
  }

  List<BibleVerse> getAllVerses() {
    List<BibleVerse> allVerses = [];
    for (var book in _books) {
      for (var chapter in book.chapters) {
        allVerses.addAll(chapter.verses);
      }
    }
    return allVerses;
  }

  BibleVerse? getTodayVerse() {
    final allVerses = getAllVerses();
    if (allVerses.isEmpty) return null;

    // Use day of year as seed
    final now = DateTime.now();
    final dayOfYear = int.parse("${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}");
    
    // Simple seeded random selection
    return allVerses[dayOfYear % allVerses.length];
  }
}
