import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';
import 'bible_data_download_service.dart';
import 'local_storage_service.dart';
import '../utils/bible_data_parser.dart';

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
      final String response = await rootBundle.loadString(
        'assets/data/bible_data.json',
      );
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
    CancelToken? cancelToken,
  }) async {
    try {
      _isDownloading = true;
      notifyListeners();

      // 1. Download raw data
      final rawData = await _downloadService.downloadBibleData(
        version: version,
        onProgress: onProgress,
        cancelToken: cancelToken,
      );

      if (rawData == null) return false;

      // 2. Process/Transform data if necessary
      final Map<String, dynamic> processedData = _processDownloadedData(
        version,
        rawData,
      );

      // 3. Save to Local Storage & Metadata
      await _saveBibleDataToLocal(version, processedData);

      // 4. Reload into memory
      await loadBibleData(version: version);

      return true;
    } catch (e) {
      _logger.e('Bible data download/processing failed for $version', error: e);
      rethrow;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _processDownloadedData(
    String version,
    Map<String, dynamic> data,
  ) {
    if (version == 'krv' && !data.containsKey('books')) {
      _logger.i('Transforming flat KRV JSON to hierarchical format');
      return BibleDataParser.parseFlatBibleJson(data);
    }
    return data;
  }

  Future<void> _saveBibleDataToLocal(
    String version,
    Map<String, dynamic> data,
  ) async {
    final jsonString = jsonEncode(data);

    await Future.wait([
      _storageService.saveBibleData(version, jsonString),
      _storageService.saveBibleMetadata(version, {
        'downloadedAt': DateTime.now().toIso8601String(),
        'size': jsonString.length,
      }),
    ]);
    _logger.i('Successfully saved Bible data and metadata for $version');
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
