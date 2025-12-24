import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class BibleDataDownloadService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
  final Logger _logger = Logger();

  static const Map<String, String> _downloadUrls = {
    'krv':
        'https://github.com/ConanShin/assets/raw/refs/heads/main/bible_krv.json',
    'knv': 'https://your-server.com/bibles/knv.json',
    'easy': 'https://your-server.com/bibles/easy.json',
    'rv': 'https://your-server.com/bibles/rv.json',
  };

  Future<Map<String, dynamic>?> downloadBibleData({
    required String version,
    required Function(int, int) onProgress,
    CancelToken? cancelToken,
  }) async {
    final url = _downloadUrls[version];
    if (url == null) {
      throw Exception('Unsupported Bible version: $version');
    }

    try {
      _logger.i('Starting download for Bible version: $version');

      final response = await _dio.get(
        url,
        cancelToken: cancelToken,
        options: Options(responseType: ResponseType.json),
        onReceiveProgress: onProgress,
      );

      if (response.statusCode == 200) {
        return _handleResponseData(response.data, version);
      } else {
        throw Exception('Download failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        _logger.w('Download cancelled by user: $version');
        rethrow;
      }
      _logger.e('Network error während Bible download: $version', error: e);
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error während Bible download: $version', error: e);
      rethrow;
    }
  }

  Map<String, dynamic> _handleResponseData(dynamic data, String version) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is String) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (e) {
        _logger.e('Failed to decode JSON string for $version', error: e);
        throw Exception('Invalid JSON format received from server');
      }
    } else {
      throw Exception('Unsupported data format: ${data.runtimeType}');
    }
  }
}
