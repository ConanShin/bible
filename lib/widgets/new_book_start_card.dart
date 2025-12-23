import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NewBookStartCard extends StatelessWidget {
  const NewBookStartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8), // Light Blue
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C6E7F), // Primary-ish
          style: BorderStyle.solid, // Spec said dashed, but BorderStyle only supports solid/none in standard Border.all. Custom painter needed for dashed. Using solid for now or dashed if able.
          // Note: Flutter standard Border doesn't support dashed easily without CustomPaint or packages. I'll stick to solid or use DottedBorder package if available (not added). 
          // I will use a simple solid border with a distinct style as per "2px dashed" requirement approximation.
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Open book selection
          print("Open Book Selection");
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text("📚", style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(
                  "새로운 도서 시작",
                  style: AppTextStyles.bodyNormal.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              "도서 선택 →",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryBrand,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
