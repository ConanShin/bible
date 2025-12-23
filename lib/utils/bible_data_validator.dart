import 'dart:convert';
import 'package:logger/logger.dart';

class BibleDataValidator {
  static final Logger _logger = Logger();

  // Validate downloaded JSON data
  static bool validateBibleJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      
      // Check required fields
      if (!data.containsKey('books') || data['books'] is! List) {
        _logger.w('Validation failed: missing books list');
        return false;
      }
      
      final books = data['books'] as List;
      
      for (var book in books) {
        // Validate book
        if (!_validateBook(book)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      _logger.e('JSON Validation Failed', error: e);
      return false;
    }
  }
  
  static bool _validateBook(dynamic book) {
    if (book is! Map) return false;
    
    final required = ['id', 'name', 'chapters'];
    for (final field in required) {
      if (!book.containsKey(field)) {
         _logger.w('Validation failed: book missing $field');
        return false;
      }
    }
    
    final chapters = book['chapters'] as List;
    for (var chapter in chapters) {
      if (!_validateChapter(chapter)) {
        return false;
      }
    }
    
    return true;
  }
  
  static bool _validateChapter(dynamic chapter) {
    if (chapter is! Map) return false;
    
    final required = ['chapterNumber', 'verses'];
    for (final field in required) {
      if (!chapter.containsKey(field)) {
         _logger.w('Validation failed: chapter missing $field');
        return false;
      }
    }
    
    return true;
  }
}
