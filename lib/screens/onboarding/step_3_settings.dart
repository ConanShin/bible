import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/spacing.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_preferences.dart';

class Step3Settings extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onComplete;

  const Step3Settings({
    super.key,
    required this.onBack,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: onBack,
        ),
        title: Text("설정", style: AppTextStyles.bodyLarge),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "읽기 경험 설정",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // Font Size Slider
                Text(
                  "글자 크기",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text("가", style: Theme.of(context).textTheme.bodySmall),
                    Expanded(
                      child: Slider(
                        value: userProvider.preferences.fontSize,
                        min: 12.0,
                        max: 24.0,
                        divisions: 6,
                        activeColor: Theme.of(context).primaryColor,
                        label: userProvider.preferences.fontSize.toString(),
                        onChanged: (value) {
                          UserPreferences newPrefs = userProvider.preferences;
                          newPrefs.fontSize = value;
                          userProvider.updatePreferences(newPrefs);
                        },
                      ),
                    ),
                    Text(
                      "가",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Night Mode Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "야간 모드",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: userProvider.preferences.isDarkMode,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        UserPreferences newPrefs = userProvider.preferences;
                        newPrefs.isDarkMode = value;
                        userProvider.updatePreferences(newPrefs);
                        // Sync theme instantly
                        context.read<ThemeProvider>().setDarkMode(value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Notification (Simple Toggle)
                Text(
                  "자동 진행 (선택사항)",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "매일 알림 받기",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          "${userProvider.preferences.dailyNotificationTime.format(context)}에 알림",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                    Switch(
                      value: userProvider.preferences.isNotificationEnabled,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        UserPreferences newPrefs = userProvider.preferences;
                        newPrefs.isNotificationEnabled = value;
                        userProvider.updatePreferences(newPrefs);
                      },
                    ),
                  ],
                ),
                if (userProvider.preferences.isNotificationEnabled)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: OutlinedButton(
                      child: const Text("시간 변경"),
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime:
                              userProvider.preferences.dailyNotificationTime,
                        );
                        if (picked != null) {
                          UserPreferences newPrefs = userProvider.preferences;
                          newPrefs.dailyNotificationTime = picked;
                          userProvider.updatePreferences(newPrefs);
                        }
                      },
                    ),
                  ),

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                    child: const Text("설정 완료 & 시작"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
