
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
}
