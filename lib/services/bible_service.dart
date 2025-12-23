
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_book.dart';
import '../models/bible_chapter.dart';
import '../models/bible_verse.dart';

class BibleService {
  List<BibleBook> _books = [];
  Map<String, dynamic>? _versions;

  Future<List<BibleBook>> loadBibleData() async {
    if (_books.isNotEmpty) return _books;

    try {
      final String response = await rootBundle.loadString('assets/data/bible_data.json');
      final data = await json.decode(response);
      
      var booksList = data['books'] as List;
      _books = booksList.map((i) => BibleBook.fromJson(i)).toList();
      _versions = {'versions': data['bibleVersions']};
      
      return _books;
    } catch (e) {
      print("Error loading bible data: $e");
      return [];
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
    if (_books.isEmpty) await loadBibleData();
    if (_versions != null && _versions!['versions'] != null) {
      return List<Map<String, dynamic>>.from(_versions!['versions']);
    }
    return [];
  }

  Future<List<BibleVerse>> searchVerses(String keyword) async {
     if (_books.isEmpty) await loadBibleData();
     List<BibleVerse> results = [];
     
     // Simple search implementation
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
