import 'package:flutter/material.dart';
import '../services/bible_service.dart';
import 'package:provider/provider.dart';

class DownloadProgressDialog extends StatefulWidget {
  final String bibleVersion;
  
  const DownloadProgressDialog({
    required this.bibleVersion,
    Key? key,
  }) : super(key: key);

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double _progress = 0.0;
  String _currentFile = '';
  String _progressText = '0%';
  String _sizeText = '0 MB / 0 MB';
  bool _isDownloading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _startDownload();
  }
  
  Future<void> _startDownload() async {
    final bibleService = context.read<BibleService>();
    
    try {
      await bibleService.downloadBibleData(
        version: widget.bibleVersion,
        onProgress: (received, total) {
          if (mounted) {
            setState(() {
              _progress = total != 0 ? received / total : 0;
              _progressText = '${(_progress * 100).toStringAsFixed(1)}%';
              _sizeText = '${(received / 1024 / 1024).toStringAsFixed(1)} MB / ${(total / 1024 / 1024).toStringAsFixed(1)} MB';
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
        
        // Close dialog after short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context, true); // Return true on success
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_errorMessage == null ? 'Downloading Bible Data' : 'Download Failed'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null) ...[
             Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
             const SizedBox(height: 16),
          ] else ...[
            // Progress Bar
            LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            
            // Progress Text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_progressText, style: Theme.of(context).textTheme.bodyLarge),
                Text(_sizeText, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Downloads are required for offline access.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ]
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
             child: const Text('Retry'),
           ),
           
        TextButton(
          onPressed: _isDownloading ? null : () => Navigator.pop(context, false),
          child: Text(_errorMessage == null && !_isDownloading ? 'Close' : 'Cancel'),
        ),
      ],
    );
  }
}
