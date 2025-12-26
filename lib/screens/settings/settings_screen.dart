import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/bible_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/download_progress_dialog.dart';
import 'package:logger/logger.dart';

import '../onboarding/onboarding_screen.dart';

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
      body: ListView(
        children: [
          _buildSectionTitle('읽기 설정'),

          // Font Size
          ListTile(
            title: const Text('글자 크기'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '창세기 1:1',
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '태초에 하나님이 천지를 창조하시니라',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: preferences.fontSize,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
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
            subtitle: Text(
              preferences.selectedBibleVersion == 'krv'
                  ? '개역개정'
                  : preferences.selectedBibleVersion == 'knv'
                  ? '새번역'
                  : preferences.selectedBibleVersion == 'easy'
                  ? '쉬운성경'
                  : '개역한글',
            ),
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('다국어 지원 준비 중입니다.')));
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
                    '${picked.hour}:${picked.minute}',
                  );
                }
              },
            ),

          const Divider(),
          _buildSectionTitle('기타'),

          ListTile(title: const Text('앱 버전'), trailing: const Text('1.0.0')),

          ListTile(
            title: const Text('피드백 보내기'),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('피드백 기능 준비 중입니다.')));
            },
          ),

          const Divider(),
          
          ListTile(
            title: Text(
              '앱 초기화',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            subtitle: const Text('모든 데이터가 삭제되고 초기 상태로 돌아갑니다.'),
            onTap: () => _showResetConfirmation(context),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showResetConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 초기화'),
        content: const Text(
          '정말 초기화하시겠습니까?\n\n'
          '다운로드한 성경, 즐겨찾기, 읽기 기록 등\n'
          '모든 데이터가 영구적으로 삭제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('초기화'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final userProvider = context.read<UserProvider>();
      await userProvider.resetApp();
      
      if (context.mounted) {
        // Navigate to Onboarding and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                trailing: currentVersion == v['id']
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
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
        content: Text(
          '${newVersion == 'krv'
              ? '개역개정'
              : newVersion == 'knv'
              ? '새번역'
              : newVersion == 'easy'
              ? '쉬운성경'
              : '개역한글'} 버전을 다운로드하시겠습니까?\n네트워크 연결이 필요합니다.',
        ),
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
