import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/bible_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/download_progress_dialog.dart';
import 'package:logger/logger.dart';
import '../../l10n/app_strings.dart';
import '../../services/notification_service.dart';

import 'package:url_launcher/url_launcher.dart';
import '../onboarding/onboarding_screen.dart';

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map(
        (e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
      )
      .join('&');
}

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
    final lang = preferences.appLanguage;

    return Scaffold(
      body: ListView(
        children: [
          _buildSectionTitle(AppStrings.get('reading_settings', lang)),

          // Font Size
          ListTile(
            title: Text(AppStrings.get('font_size', lang)),
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
                Consumer<BibleProvider>(
                  builder: (context, bibleProvider, _) {
                    String previewText = '태초에 하나님이 천지를 창조하시니라';
                    String previewRef = '창세기 1:1';

                    try {
                      if (bibleProvider.books.isNotEmpty) {
                        final firstBook = bibleProvider.books.first;
                        if (firstBook.chapters.isNotEmpty) {
                          final firstChapter = firstBook.chapters.first;
                          if (firstChapter.verses.isNotEmpty) {
                            final firstVerse = firstChapter.verses.first;
                            previewText = firstVerse.text;
                            previewRef =
                                '${firstBook.getDisplayName(lang)} ${firstChapter.chapterNumber}:${firstVerse.verseNumber}';
                          }
                        }
                      }
                    } catch (e) {
                      // Fallback to default
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            previewRef,
                            style: AppTextStyles.caption.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            previewText,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: preferences.fontSize,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Dark Mode
          SwitchListTile(
            title: Text(AppStrings.get('night_mode', lang)),
            value: preferences.isDarkMode,
            onChanged: (value) {
              userProvider.savePreference('isDarkMode', value);
              themeProvider.setDarkMode(value);
            },
          ),

          // Bible Version Selector
          ListTile(
            title: Text(AppStrings.get('bible_selection_title', lang)),
            subtitle: Text(
              _getVersionName(context, preferences.selectedBibleVersion),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBibleVersionSelector(context),
          ),

          const Divider(),
          _buildSectionTitle(AppStrings.get('app_settings', lang)),

          // Language
          ListTile(
            title: Text(AppStrings.get('select_language', lang)),
            subtitle: Text(preferences.appLanguage == 'ko' ? '한국어' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageSelector(context),
          ),

          // Notifications
          SwitchListTile(
            title: Text(AppStrings.get('daily_notification', lang)),
            value: preferences.isNotificationEnabled,
            onChanged: (value) async {
              if (value) {
                // Show reasoning dialog first
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      AppStrings.get('notification_permission_title', lang),
                    ),
                    content: Text(
                      AppStrings.get('notification_permission_content', lang),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(AppStrings.get('deny', lang)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(AppStrings.get('allow', lang)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  userProvider.savePreference('isNotificationEnabled', true);
                  await NotificationService().requestPermissions();
                  await NotificationService().scheduleDailyNotification(
                    time: preferences.dailyNotificationTime,
                    title: AppStrings.get('daily_reading_title', lang),
                    body: AppStrings.get('daily_reading_body', lang),
                  );
                } else {
                  // Revert switch if denied
                  userProvider.savePreference('isNotificationEnabled', false);
                }
              } else {
                userProvider.savePreference('isNotificationEnabled', false);
                await NotificationService().cancelAll();
              }
            },
          ),

          if (preferences.isNotificationEnabled)
            ListTile(
              title: Text(AppStrings.get('notification_time', lang)),
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
                  // Reschedule with new time
                  await NotificationService().scheduleDailyNotification(
                    time: picked,
                    title: AppStrings.get('daily_reading_title', lang),
                    body: AppStrings.get('daily_reading_body', lang),
                  );
                }
              },
            ),

          const Divider(),
          _buildSectionTitle(AppStrings.get('etc', lang)),

          ListTile(
            title: Text(AppStrings.get('app_version', lang)),
            trailing: const Text('1.0.0'),
          ),

          ListTile(
            title: Text(AppStrings.get('send_feedback', lang)),
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'cheolmin.conan.shin@gmail.com',
                query: encodeQueryParameters({
                  'subject': '[${AppStrings.get('feedback_subject', lang)}]',
                }),
              );

              try {
                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('메일 앱을 열 수 없습니다.')),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('작업 중 오류가 발생했습니다.')),
                  );
                }
              }
            },
          ),

          const Divider(),

          ListTile(
            title: Text(
              AppStrings.get('reset_app', lang),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            subtitle: Text(AppStrings.get('reset_app_sub', lang)),
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
      builder: (context) {
        final lang = context.watch<UserProvider>().preferences.appLanguage;
        return AlertDialog(
          title: Text(AppStrings.get('reset_confirm_title', lang)),
          content: Text(AppStrings.get('reset_confirm_content', lang)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.get('cancel', lang)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppStrings.get('reset_app', lang)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final userProvider = context.read<UserProvider>();
      await userProvider.resetApp();

      if (context.mounted) {
        // Sync theme with newly reset preferences
        context.read<ThemeProvider>().setDarkMode(
          userProvider.preferences.isDarkMode,
        );
      }

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

  Future<void> _showBibleVersionSelector(
    BuildContext context, {
    String? languageCode,
  }) async {
    final userProvider = context.read<UserProvider>();
    final bibleProvider = context.read<BibleProvider>();
    final currentVersion = userProvider.preferences.selectedBibleVersion;
    final targetLanguage = languageCode ?? userProvider.preferences.appLanguage;

    // Get versions filtered by target language
    final versions = await bibleProvider.getAvailableVersions(
      languageCode: targetLanguage,
    );

    if (!mounted) return;

    final String? selected = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: versions.map((v) {
              final String versionName = targetLanguage == 'ko'
                  ? v['name']!
                  : (v['englishName'] ?? v['name']!);
              return ListTile(
                title: Text(versionName),
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
      await _onBibleVersionChanged(selected);
    }
  }

  String _getVersionName(BuildContext context, String versionId) {
    final bibleProvider = context.read<BibleProvider>();
    // Since this might be called during build, accessing provider is fine if watched or read.
    // However, read inside build (or helper called by build) is safe if context is correct.
    // Ideally use data from watch in build. But for helper, let's look it up from cached versions list if possible.
    try {
      final version = bibleProvider.versions.firstWhere(
        (v) => v['id'] == versionId,
        orElse: () => {'name': versionId},
      );
      final lang = context.read<UserProvider>().preferences.appLanguage;
      return lang == 'ko'
          ? version['name']
          : (version['englishName'] ?? version['name']);
    } catch (e) {
      return versionId;
    }
  }

  Future<void> _onBibleVersionChanged(String newVersion) async {
    final versionName = _getVersionName(context, newVersion);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final lang = context.watch<UserProvider>().preferences.appLanguage;
        return AlertDialog(
          title: Text(AppStrings.get('change_version_title', lang)),
          content: Text(
            "${versionName} ${AppStrings.get('change_version_content', lang)}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.get('cancel', lang)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppStrings.get('download', lang)),
            ),
          ],
        );
      },
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
          final lang = context.read<UserProvider>().preferences.appLanguage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.get('bible_version_changed', lang)),
            ),
          );
        }
      }
    }
  }

  Future<void> _showLanguageSelector(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final currentLanguage = userProvider.preferences.appLanguage;

    final String? selected = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('한국어'),
                subtitle: const Text('Korean'),
                trailing: currentLanguage == 'ko'
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () => Navigator.pop(context, 'ko'),
              ),
              ListTile(
                title: const Text('English'),
                subtitle: const Text('영어'),
                trailing: currentLanguage == 'en'
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () => Navigator.pop(context, 'en'),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && selected != currentLanguage) {
      if (mounted) {
        // Show dialog requiring Bible version change
        final shouldChangeBible = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final lang = currentLanguage;
            return AlertDialog(
              title: Text(AppStrings.get('lang_change_confirm_title', lang)),
              content: Text(
                lang == 'ko'
                    ? '언어를 영어로 변경하려면 영어 성경 버전을 선택해야 합니다.\n\n성경 버전을 선택하시겠습니까?'
                    : 'To change the language to Korean, you must select a Korean Bible version.\n\nWould you like to select a Bible version?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppStrings.get('cancel', lang)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(AppStrings.get('select_bible', lang)),
                ),
              ],
            );
          },
        );

        if (shouldChangeBible == true && mounted) {
          // Open Bible version selector and wait for selection
          await _showBibleVersionSelector(context, languageCode: selected);

          // Only update language if a new Bible version was selected
          final newVersion = userProvider.preferences.selectedBibleVersion;
          final bibleProvider = context.read<BibleProvider>();
          final versions = await bibleProvider.getAvailableVersions(
            languageCode: selected,
          );

          // Check if the current version matches the new language
          final isVersionValid = versions.any((v) => v['id'] == newVersion);

          if (isVersionValid && mounted) {
            // Language change is complete, update the language
            await userProvider.updateLanguage(selected);
            // Update BibleProvider filter
            await bibleProvider.updateLanguageFilter(selected);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.get('lang_changed', selected)),
                ),
              );
            }
          }
        }
      }
    }
  }
}
