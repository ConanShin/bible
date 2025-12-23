import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/bible_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/download_progress_dialog.dart';
import 'package:logger/logger.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Logger _logger = Logger();
  bool _isDownloadingBible = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final preferences = userProvider.preferences;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionTitle('읽기 설정'),
          
          // Font Size
          ListTile(
            title: const Text('글자 크기'),
            subtitle: Row(
              children: [
                const Icon(Icons.text_fields, size: 16),
                Expanded(
                  child: Slider(
                    value: preferences.fontSize,
                    min: 12,
                    max: 30,
                    onChanged: (value) {
                      userProvider.savePreference('fontSize', value);
                    },
                  ),
                ),
                const Icon(Icons.text_fields, size: 24),
              ],
            ),
          ),

          // Dark Mode
          SwitchListTile(
            title: const Text('야간 모드'),
            value: preferences.isDarkMode,
            onChanged: (value) {
              userProvider.savePreference('isDarkMode', value);
              themeProvider.setDarkMode(value);
            },
          ),

          // Bible Version Selector
          ListTile(
            title: const Text('성경 버전'),
            subtitle: Text(preferences.selectedBibleVersion == 'krv' ? '개역개정' : 
                           preferences.selectedBibleVersion == 'knv' ? '새번역' :
                           preferences.selectedBibleVersion == 'easy' ? '쉬운성경' : '개역한글'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBibleVersionSelector(context),
          ),

          const Divider(),
          _buildSectionTitle('앱 설정'),

          // Language (Placeholder)
          ListTile(
            title: const Text('언어'),
            subtitle: const Text('한국어'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('다국어 지원 준비 중입니다.')),
              );
            },
          ),

          // Notifications
          SwitchListTile(
            title: const Text('일일 알림'),
            value: preferences.isNotificationEnabled,
            onChanged: (value) {
              userProvider.savePreference('isNotificationEnabled', value);
            },
          ),

          if (preferences.isNotificationEnabled)
            ListTile(
              title: const Text('알림 시간'),
              trailing: Text(preferences.dailyNotificationTime.format(context)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: preferences.dailyNotificationTime,
                );
                if (picked != null) {
                  userProvider.savePreference(
                    'dailyNotificationTime', 
                    '${picked.hour}:${picked.minute}'
                  );
                }
              },
            ),

          const Divider(),
          _buildSectionTitle('기타'),

          ListTile(
            title: const Text('앱 버전'),
            trailing: const Text('1.0.0'),
          ),

          ListTile(
            title: const Text('피드백 보내기'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('피드백 기능 준비 중입니다.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showBibleVersionSelector(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final bibleProvider = context.read<BibleProvider>();
    final currentVersion = userProvider.preferences.selectedBibleVersion;

    final versions = [
      {'id': 'krv', 'name': '개역개정'},
      {'id': 'knv', 'name': '새번역'},
      {'id': 'easy', 'name': '쉬운성경'},
      {'id': 'rv', 'name': '개역한글'},
    ];

    final String? selected = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: versions.map((v) {
              return ListTile(
                title: Text(v['name']!),
                trailing: currentVersion == v['id'] ? const Icon(Icons.check, color: AppColors.primaryBrand) : null,
                onTap: () => Navigator.pop(context, v['id']),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected != null && selected != currentVersion) {
      _onBibleVersionChanged(selected);
    }
  }

  Future<void> _onBibleVersionChanged(String newVersion) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('성경 버전 변경'),
        content: Text('${newVersion == 'krv' ? '개역개정' : newVersion == 'knv' ? '새번역' : newVersion == 'easy' ? '쉬운성경' : '개역한글'} 버전을 다운로드하시겠습니까?\n네트워크 연결이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('다운로드'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      
      final success = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => DownloadProgressDialog(bibleVersion: newVersion),
      );

      if (success == true) {
        if (!mounted) return;
        final userProvider = context.read<UserProvider>();
        final bibleProvider = context.read<BibleProvider>();
        
        await userProvider.updateBibleVersion(newVersion);
        await bibleProvider.loadBibleData(version: newVersion);
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('성경 버전이 성공적으로 변경되었습니다.')),
          );
        }
      }
    }
  }
}
