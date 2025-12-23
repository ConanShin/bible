
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/spacing.dart';
import '../../providers/bible_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_preferences.dart';

class Step2BibleSelection extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2BibleSelection({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: onBack,
        ),
        title: Text("성경 선택", style: AppTextStyles.bodyLarge),
        actions: [
          TextButton(
            onPressed: onNext,
            child: Text("건너뛰기", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
      body: Consumer<BibleProvider>(
        builder: (context, bibleProvider, child) {
          final versions = bibleProvider.versions;
          if (versions.isEmpty && bibleProvider.isLoading) {
             return const Center(child: CircularProgressIndicator());
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  "어떤 성경 번역본을\n선호하시나요?",
                  style: AppTextStyles.heading2,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: versions.length,
                  itemBuilder: (context, index) {
                    final version = versions[index];
                    final String versionId = version['id'];
                    final String versionName = version['name'];
                    // Mock descriptions for now
                    String description = "한국 교회의 가장 널리 사용되는 번역";
                    if (versionId == 'knv') description = "직역성과 가독성의 균형잡은 번역";
                    if (versionId == 'easy') description = "현대인을 위해 알기 쉽게 번역";

                    return Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        final isSelected = userProvider.preferences.selectedBibleVersion == versionName;
                        
                        return GestureDetector(
                          onTap: () {
                             UserPreferences newPrefs = userProvider.preferences;
                             newPrefs.selectedBibleVersion = versionName;
                             userProvider.updatePreferences(newPrefs);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryBrand : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: AppColors.primaryBrand.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(versionName, style: AppTextStyles.heading3.copyWith(fontSize: 18)),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: AppColors.success),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SizedBox(
                   width: double.infinity,
                   height: 48,
                   child: ElevatedButton(
                     onPressed: onNext,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppColors.primaryBrand,
                       foregroundColor: Colors.white,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                       ),
                     ),
                     child: const Text("다음"),
                   ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
