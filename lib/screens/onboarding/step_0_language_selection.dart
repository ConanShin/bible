import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/spacing.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_provider.dart';

class Step0LanguageSelection extends StatefulWidget {
  final Function(String) onLanguageSelected;

  const Step0LanguageSelection({super.key, required this.onLanguageSelected});

  @override
  State<Step0LanguageSelection> createState() => _Step0LanguageSelectionState();
}

class _Step0LanguageSelectionState extends State<Step0LanguageSelection> {
  String _selectedLanguage = 'ko';

  @override
  void initState() {
    super.initState();
    // Use device locale to set initial language
    final deviceLocale = PlatformDispatcher.instance.locale;
    if (deviceLocale.languageCode == 'ko') {
      _selectedLanguage = 'ko';
    } else {
      _selectedLanguage = 'en';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Text(
            AppStrings.get('select_language', _selectedLanguage),
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.get('select_language_sub', _selectedLanguage),
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildLanguageOption(
            title: "한국어",
            subtitle: "Korean",
            languageCode: 'ko',
            isSelected: _selectedLanguage == 'ko',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLanguageOption(
            title: "English",
            subtitle: "영어",
            languageCode: 'en',
            isSelected: _selectedLanguage == 'en',
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Save language to UserProvider
                  context.read<UserProvider>().updateLanguage(
                    _selectedLanguage,
                  );
                  widget.onLanguageSelected(_selectedLanguage);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  textStyle: AppTextStyles.bodyNormal.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(AppStrings.get('next', _selectedLanguage)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String subtitle,
    required String languageCode,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = languageCode;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}
