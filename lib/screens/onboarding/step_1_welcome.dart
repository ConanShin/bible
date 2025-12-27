import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/spacing.dart';

class Step1Welcome extends StatelessWidget {
  final VoidCallback onNext;

  const Step1Welcome({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo placeholder (simulated with Icon for now)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          Text(
            "성경 읽기 여정을\n시작하세요",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            "함께하는 말씀으로\n매일을 의미있게 만드세요.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(
                "다음",
                style: AppTextStyles.bodyNormal.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}
