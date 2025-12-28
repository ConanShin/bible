import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/bible_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../l10n/app_strings.dart';

class DownloadProgressDialog extends StatefulWidget {
  final String bibleVersion;

  const DownloadProgressDialog({required this.bibleVersion, Key? key})
    : super(key: key);

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  final CancelToken _cancelToken = CancelToken();
  double? _progress;
  String _currentFile = '';
  String _progressText = '0%';
  String _sizeText = '0.00 MB';
  bool _isDownloading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDownload();
    });
  }

  @override
  void dispose() {
    if (_isDownloading) {
      _cancelToken.cancel('Dialog disposed');
    }
    super.dispose();
  }

  Future<void> _startDownload() async {
    final bibleService = context.read<BibleService>();
    final userProvider = context.read<UserProvider>();
    final lang = userProvider.preferences.appLanguage;

    try {
      await bibleService.downloadBibleData(
        version: widget.bibleVersion,
        cancelToken: _cancelToken,
        onProgress: (received, total) {
          if (mounted) {
            setState(() {
              if (total > 0) {
                // If received exceeds total (due to decompression), clamp it for UI consistency
                final bool isProcessing = received >= total;
                final displayReceived = isProcessing ? total : received;

                _progress = isProcessing ? 1.0 : (displayReceived / total);

                if (isProcessing) {
                  _progressText = AppStrings.get('download_processing', lang);
                } else {
                  _progressText = '${(_progress! * 100).toStringAsFixed(1)}%';
                }

                final receivedMB = (displayReceived / 1024 / 1024)
                    .toStringAsFixed(2);
                final totalMB = (total / 1024 / 1024).toStringAsFixed(2);
                _sizeText = '$receivedMB MB / $totalMB MB';
              } else {
                // If total is unknown or 0, show indeterminate progress
                _progress = null;
                _progressText = AppStrings.get('downloading_status', lang);

                final receivedMB = (received / 1024 / 1024).toStringAsFixed(2);
                _sizeText = '$receivedMB MB';
              }
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _progress = 1.0;
          _progressText = '100%';
          _isDownloading = false;
        });

        // Close dialog immediately
        Navigator.pop(context, true); // Return true on success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          if (e is DioException && e.type == DioExceptionType.cancel) {
            _errorMessage = AppStrings.get('download_cancelled', lang);
          } else {
            _errorMessage = e.toString();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<UserProvider>().preferences.appLanguage;
    return AlertDialog(
      title: Text(
        _errorMessage == null
            ? AppStrings.get('downloading_bible', lang)
            : AppStrings.get('download_failed', lang),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null) ...[
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
          ] else ...[
            // Progress Bar
            LinearProgressIndicator(value: _progress, minHeight: 8),
            const SizedBox(height: 16),

            // Progress Text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _progressText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(_sizeText, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.get('download_required', lang),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: [
        if (_errorMessage != null)
          TextButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _isDownloading = true;
                _progress = 0;
              });
              _startDownload();
            },
            child: Text(AppStrings.get('download_retry', lang)),
          ),

        TextButton(
          onPressed: () {
            if (_isDownloading) {
              _cancelToken.cancel('User cancelled');
              Navigator.pop(context, false);
            } else {
              Navigator.pop(context, false);
            }
          },
          child: Text(
            _errorMessage == null && !_isDownloading
                ? AppStrings.get('download_close', lang)
                : AppStrings.get('cancel', lang),
          ),
        ),
      ],
    );
  }
}
