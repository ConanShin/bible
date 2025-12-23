import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/bible_book.dart';
import '../models/bible_chapter.dart';
import '../models/bible_verse.dart';
import 'bible_data_download_service.dart';
import 'local_storage_service.dart';

class BibleService extends ChangeNotifier {
  final BibleDataDownloadService _downloadService = BibleDataDownloadService();
  final LocalStorageService _storageService = LocalStorageService();
  final Logger _logger = Logger();
  
  List<BibleBook> _books = [];
  Map<String, dynamic>? _versions;
  
  String _currentVersion = 'krv'; // Default
  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  List<BibleBook> loadBibleDataSync() {
    return _books;
  }

  Future<List<BibleBook>> loadBibleData({String? version}) async {
    final targetVersion = version ?? _currentVersion;
    
    // 1. Try to load from Local Storage (SQLite)
    try {
      final localData = await _storageService.loadBibleData(targetVersion);
      if (localData.isNotEmpty) {
        _books = localData;
        _currentVersion = targetVersion;
        _logger.i('Loaded Bible data from Local Storage: $targetVersion');
        notifyListeners();
        return _books;
      }
    } catch (e) {
      _logger.e('Failed to load from local storage', error: e);
    }
    
    // ... rest of the logic
    // For now, if local is empty, we try assets for default data if available, or return empty.
    if (_books.isNotEmpty) return _books;

    try {
      // Logic to load default asset if available, currently just keep existing asset logic as fallback
      // but ideally we only want downloaded data. 
      // Let's keep existing logic but wrapped.
      final String response = await rootBundle.loadString('assets/data/bible_data.json');
      final data = await json.decode(response);
      
      var booksList = data['books'] as List;
      _books = booksList.map((i) => BibleBook.fromJson(i)).toList();
      _versions = {'versions': data['bibleVersions']};
      
      notifyListeners();
      return _books;
    } catch (e) {
      _logger.e("Error loading bible data from assets: $e");
      return [];
    }
  }

  Future<bool> downloadBibleData({
    required String version,
    required Function(int, int) onProgress,
  }) async {
    try {
      _isDownloading = true;
      notifyListeners();
      
      // 1. Download
      final data = await _downloadService.downloadBibleData(
        version: version,
        onProgress: onProgress,
      );
      
      if (data != null) {
        // 2. Save to Local Storage
        // Convert map back to string for the verify/save method expecting json string
        // Or refactor save to take Map. For now, stringify.
        await _storageService.saveBibleData(version, jsonEncode(data));
        
        // 3. Save Metadata
        await _storageService.saveBibleMetadata(version, {
          'downloadedAt': DateTime.now().toIso8601String(),
          'size': jsonEncode(data).length, // Approximation
        });
        
        // 4. Load into memory
        await loadBibleData(version: version);
        
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Bible data download failed', error: e);
      rethrow;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<BibleBook?> getBook(String bookName) async {
    if (_books.isEmpty) await loadBibleData();
    try {
      return _books.firstWhere((book) => book.name == bookName);
    } catch (e) {
      return null;
    }
  }
  
  Future<List<Map<String, dynamic>>> getAvailableVersions() async {
    // If we have versions from asset/metadata, use them. 
    // Otherwise return hardcoded supported versions or fetch from server.
     if (_versions != null && _versions!['versions'] != null) {
      return List<Map<String, dynamic>>.from(_versions!['versions']);
    }
    
    // Fallback/Default supported versions
    return [
      {'id': 'krv', 'name': '개역개정'},
      {'id': 'knv', 'name': '새번역'},
      {'id': 'easy', 'name': '쉬운성경'},
      {'id': 'rv', 'name': '개역한글'},
    ];
  }

  Future<List<BibleVerse>> searchVerses(String keyword) async {
     if (_books.isEmpty) await loadBibleData();
     List<BibleVerse> results = [];
     
     for (var book in _books) {
       for (var chapter in book.chapters) {
         for (var verse in chapter.verses) {
           if (verse.text.contains(keyword)) {
             results.add(verse);
           }
         }
       }
     }
     return results;
  }
}
