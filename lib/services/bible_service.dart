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
        _sanitizeBooks(); // Auto-correct any corrupted English names in cache
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

      _sanitizeBooks();

      notifyListeners();
      return _books;
    } catch (e) {
      _logger.e("Error loading bible data from assets: $e");
      return [];
    }
  }

  void _sanitizeBooks() {
    for (var i = 0; i < _books.length; i++) {
      final book = _books[i];
      final correctEnglishName = BibleDataParser.getEnglishName(book.id);

      // Overwrite if englishName is invalid (contains Korean or doesn't match metadata)
      // We strictly enforce metadata English name to ensure it is English.
      if (correctEnglishName != null &&
          book.englishName != correctEnglishName) {
        _books[i] = BibleBook(
          id: book.id,
          name: book.name,
          englishName: correctEnglishName,
          abbreviation: book.abbreviation,
          testament: book.testament,
          totalChapters: book.totalChapters,
          chapters: book.chapters,
        );
      }
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

      final versionData = _versions?['versions']?.firstWhere(
        (v) => v['id'] == version,
        orElse: () => null,
      );
      final String? downloadUrl = versionData?['url'];

      if (downloadUrl == null) {
        _logger.e('Download URL not found for version: $version');
        return false;
      }

      // 1. Download raw data
      final rawData = await _downloadService.downloadBibleData(
        version: version,
        url: downloadUrl,
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
    if (!data.containsKey('books')) {
      _logger.i('Transforming flat Bible JSON to hierarchical format');
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

  Future<List<Map<String, dynamic>>> getAvailableVersions({
    String? languageCode,
  }) async {
    List<Map<String, dynamic>> versions = [];

    // Try to load from assets if not loaded yet
    try {
      final String response = await rootBundle.loadString(
        'assets/data/bible_data.json',
      );
      final data = await json.decode(response);
      _versions = {'versions': data['bibleVersions']};
      if (_versions != null && _versions!['versions'] != null) {
        versions = List<Map<String, dynamic>>.from(_versions!['versions']);
      }
    } catch (e) {
      _logger.e("Error loading versions from assets: $e");
    }

    if (versions.isEmpty) {
      // Fallback/Default supported versions
      versions = [
        // Korean Versions
        {
          'id': 'krv',
          'language': 'ko',
          'name': '개역개정',
          'description': '한국교회 표준 성경. 1961년 개역한글을 현대어로 대폭 개정.',
          'url':
              'https://raw.githubusercontent.com/ConanShin/bible-crawler/main/output/bible_krv_ko.json',
        },
        {
          'id': 'snkv',
          'language': 'ko',
          'name': '새번역',
          'description': '일상어 중심의 현대적 번역. 이해하기 쉬운 표현.',
          'url':
              'https://raw.githubusercontent.com/ConanShin/bible-crawler/main/output/bible_snkv_ko.json',
        },
        {
          'id': 'ncv',
          'language': 'ko',
          'name': '표준새번역',
          'description': '새번역의 정확성/표준성 강화. 현대어 유지하면서 원문 충실도 높임.',
          'url':
              'https://raw.githubusercontent.com/ConanShin/bible-crawler/main/output/bible_ncv_ko.json',
        },
        {
          'id': 'ksv',
          'language': 'ko',
          'name': '개역한글',
          'description': '1938년 개역판을 한글맞춤법 통일안에 맞춰 개정. 문어체 스타일 유지.',
          'url':
              'https://raw.githubusercontent.com/ConanShin/bible-crawler/main/output/bible_ksv_ko.json',
        },
        {
          'id': 'kcb',
          'language': 'ko',
          'name': '공동번역',
          'description': '가톨릭/개신교 공동 번역. 생태계/평등 용어 현대화.',
          'url':
              'https://raw.githubusercontent.com/ConanShin/bible-crawler/main/output/bible_kcb_ko.json',
        },
        // English Versions
        {
          'id': 'niv',
          'language': 'en',
          'name': 'NIV',
          'description':
              'New International Version. A balance of accuracy and readability.',
          'url':
              'https://raw.githubusercontent.com/ConanShin/bible-crawler/main/output/bible_niv_en.json',
        },
        {
          'id': 'esv',
          'language': 'en',
          'name': 'ESV',
          'description': 'English Standard Version. Word-for-word translation.',
          'url':
              'https://raw.githubusercontent.com/ConanShin/bible-crawler/main/output/bible_esv_en.json',
        },
        {
          'id': 'nkjv',
          'language': 'en',
          'name': 'NKJV',
          'description':
              'New King James Version. Modern language based on KJV.',
          'url':
              'https://raw.githubusercontent.com/ConanShin/bible-crawler/main/output/bible_nkjv_en.json',
        },
        {
          'id': 'nlt',
          'language': 'en',
          'name': 'NLT',
          'description':
              'New Living Translation. Easy to understand, thought-for-thought.',
          'url':
              'https://raw.githubusercontent.com/ConanShin/bible-crawler/main/output/bible_nlt_en.json',
        },
        {
          'id': 'nasb',
          'language': 'en',
          'name': 'NASB',
          'description':
              'New American Standard Bible. Highly literal translation.',
          'url':
              'https://raw.githubusercontent.com/ConanShin/bible-crawler/main/output/bible_nasb_en.json',
        },
        {
          'id': 'kjv',
          'language': 'en',
          'name': 'KJV',
          'description': 'King James Version. Classic English translation.',
          'url':
              'https://raw.githubusercontent.com/ConanShin/bible-crawler/main/output/bible_kjv_en.json',
        },
      ];
    }

    if (languageCode != null) {
      return versions.where((v) => v['language'] == languageCode).toList();
    }

    return versions;
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
