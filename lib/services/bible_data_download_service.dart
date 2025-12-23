import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class BibleDataDownloadService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  
  // Placeholder URLs - Replace with actual server URLs
  static const Map<String, String> _downloadUrls = {
    'krv': 'https://your-server.com/bibles/krv.json', // 개역개정
    'knv': 'https://your-server.com/bibles/knv.json', // 새번역
    'easy': 'https://your-server.com/bibles/easy.json', // 쉬운성경
    'rv': 'https://your-server.com/bibles/rv.json', // 개역한글
  };
  
  /// Download Bible data
  /// [version]: Bible version code
  /// [onProgress]: Progress callback (received bytes, total bytes)
  Future<Map<String, dynamic>?> downloadBibleData({
    required String version,
    required Function(int, int) onProgress,
  }) async {
    try {
      final url = _downloadUrls[version];
      if (url == null) {
        throw Exception('Unsupported Bible version: $version');
      }
      
      _logger.i('Starting Bible data download: $version');
      
      // For development/mocking purposes, if the URL triggers an error or is invalid, 
      // you might want to switch to a local asset or a mock delay if not actually connecting to a server yet.
      // But adhering to the spec, we implement the network call.
      
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.json),
        onReceiveProgress: (received, total) {
          // _logger.d('Progress: $received / $total'); // Too verbose for prod
          if (total != -1) {
            onProgress(received, total);
          }
        },
      );
      
      if (response.statusCode == 200) {
        _logger.i('Bible data download complete: $version');
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Bible data download error', error: e);
      rethrow;
    }
  }
}
