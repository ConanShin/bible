import 'package:flutter/material.dart';
import '../screens/home/bible_selection_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NewBookStartCard extends StatelessWidget {
  const NewBookStartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: false,
          backgroundColor: Colors.transparent,
          builder: (context) => const BibleSelectionScreen(),
        );
      },
      child: Container(
        width: double.infinity,
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEBF6F9), Color(0xFFF3F4F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD1E2E8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A9FB4).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primaryBrand,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "새로운 도서 시작",
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    "은혜로운 첫 장을 열어보세요",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.primaryBrand,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
