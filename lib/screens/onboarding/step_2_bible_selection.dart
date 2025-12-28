import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/spacing.dart';
import '../../providers/bible_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_preferences.dart';
import '../../l10n/app_strings.dart';

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
    final userProvider = context.watch<UserProvider>();
    final lang = userProvider.preferences.appLanguage;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: onBack,
        ),
        title: Text(
          AppStrings.get('bible_selection_title', lang),
          style: AppTextStyles.bodyLarge,
        ),
      ),
      body: Consumer<BibleProvider>(
        builder: (context, bibleProvider, child) {
          final versions = bibleProvider.versions;
          if (versions.isEmpty && bibleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Auto-select first version if none selected or current selection is not in list
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final currentSelection =
              userProvider.preferences.selectedBibleVersion;
          final bool isCurrentSelectionValid = versions.any(
            (v) => v['id'] == currentSelection,
          );

          if ((currentSelection.isEmpty || !isCurrentSelectionValid) &&
              versions.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final latestSelection =
                  userProvider.preferences.selectedBibleVersion;
              final bool stillInvalid = !versions.any(
                (v) => v['id'] == latestSelection,
              );
              if (latestSelection.isEmpty || stillInvalid) {
                UserPreferences newPrefs = userProvider.preferences;
                newPrefs.selectedBibleVersion = versions.first['id'];
                userProvider.updatePreferences(newPrefs);
              }
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  AppStrings.get('bible_selection_question', lang),
                  style: AppTextStyles.heading2,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: versions.length,
                  itemBuilder: (context, index) {
                    final version = versions[index];
                    final String versionId = version['id'];
                    final String versionName = lang == 'ko'
                        ? version['name']
                        : (version['englishName'] ?? version['name']);
                    final String description =
                        version['description'] ??
                        AppStrings.get(
                          'no_description',
                          userProvider.preferences.appLanguage,
                        );

                    return Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        final isSelected =
                            userProvider.preferences.selectedBibleVersion ==
                            versionId;

                        return GestureDetector(
                          onTap: () {
                            UserPreferences newPrefs = userProvider.preferences;
                            newPrefs.selectedBibleVersion = versionId;
                            userProvider.updatePreferences(newPrefs);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.1),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        versionName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  ),
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
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    final isSelected = userProvider
                        .preferences
                        .selectedBibleVersion
                        .isNotEmpty;

                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSelected ? onNext : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          textStyle: AppTextStyles.bodyNormal.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          AppStrings.get(
                            'next',
                            userProvider.preferences.appLanguage,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
