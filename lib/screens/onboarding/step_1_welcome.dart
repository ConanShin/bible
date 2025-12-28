import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/spacing.dart';
import '../../l10n/app_strings.dart';
import '../../providers/user_provider.dart';

class Step1Welcome extends StatelessWidget {
  final VoidCallback onNext;

  const Step1Welcome({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final lang = userProvider.preferences.appLanguage;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Illustration or Logo placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            AppStrings.get('welcome_title', lang),
            style: AppTextStyles.heading1,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.get('welcome_subtitle', lang),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyNormal.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                textStyle: AppTextStyles.bodyNormal.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(AppStrings.get('next', lang)),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}
