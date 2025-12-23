
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
        actions: [
          TextButton(
            onPressed: onComplete,
            child: Text("완료", style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBrand, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("읽기 경험 설정", style: AppTextStyles.heading2),
                const SizedBox(height: AppSpacing.xxxl),
                
                // Font Size Slider
                Text("글자 크기", style: AppTextStyles.heading3.copyWith(fontSize: 16)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text("가", style: AppTextStyles.bodySmall),
                    Expanded(
                      child: Slider(
                        value: userProvider.preferences.fontSize,
                        min: 12.0,
                        max: 24.0,
                        divisions: 6,
                        activeColor: AppColors.primaryBrand,
                        label: userProvider.preferences.fontSize.toString(),
                        onChanged: (value) {
                           UserPreferences newPrefs = userProvider.preferences;
                           newPrefs.fontSize = value;
                           userProvider.updatePreferences(newPrefs);
                        },
                      ),
                    ),
                    Text("가", style: AppTextStyles.heading2),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xxxl),
                
                // Night Mode Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("야간 모드", style: AppTextStyles.heading3.copyWith(fontSize: 16)),
                    Switch(
                      value: userProvider.preferences.isDarkMode,
                      activeColor: AppColors.primaryBrand,
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
                Text("자동 진행 (선택사항)", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text("매일 알림 받기", style: AppTextStyles.heading3.copyWith(fontSize: 16)),
                       Text(
                         "${userProvider.preferences.dailyNotificationTime.format(context)}에 알림", 
                         style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)
                       ),
                     ],
                   ),
                    Switch(
                      value: userProvider.preferences.isNotificationEnabled,
                      activeColor: AppColors.primaryBrand,
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
                          initialTime: userProvider.preferences.dailyNotificationTime,
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
                       backgroundColor: AppColors.primaryBrand,
                       foregroundColor: Colors.white,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
