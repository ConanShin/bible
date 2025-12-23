import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';

class DownloadErrorHandler {
  static void handleDownloadError(
    BuildContext context,
    dynamic error,
    VoidCallback onRetry,
  ) {
    String message = '다운로드에 실패했습니다.';
    
    if (error is SocketException) {
      message = '네트워크 연결을 확인해주세요.';
    } else if (error is TimeoutException) {
      message = '다운로드 시간이 초과되었습니다.';
    } else if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          message = '네트워크 연결을 확인해주세요.';
          break;
        case DioExceptionType.badResponse:
          message = '서버 오류가 발생했습니다. (${error.response?.statusCode})';
          break;
        default:
          message = '다운로드에 실패했습니다.';
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('다운로드 실패'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text('재시도'),
          ),
        ],
      ),
    );
  }
}
