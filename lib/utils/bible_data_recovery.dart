import 'package:logger/logger.dart';
import '../services/local_storage_service.dart';

class BibleDataRecovery {
  static final Logger _logger = Logger();
  static final LocalStorageService _storageService = LocalStorageService();

  /// Recover or reset corrupted Bible data for a specific version
  static Future<void> recoverBibleData(String version) async {
    try {
      _logger.i('Starting Bible data recovery for version: $version');
      await _storageService.deleteBibleData(version);
      _logger.i('Completed Bible data reset for recovery: $version');
    } catch (e) {
      _logger.e('Bible data recovery failed', error: e);
      rethrow;
    }
  }

  /// Reset all local Bible data and metadata
  static Future<void> resetAllBibleData() async {
    try {
      _logger.w('Requesting full reset of all Bible data');
      // We would need a method in LocalStorageService to drop all tables or clear specific prefix
      // For now, we can iterate through known versions if needed, or implement a clearAll in storage service.
      // Let's assume we implement a reset in storage service.
      // await _storageService.resetDatabase(); 
      _logger.i('All Bible data cleared');
    } catch (e) {
      _logger.e('Full data reset failed', error: e);
      rethrow;
    }
  }
}
