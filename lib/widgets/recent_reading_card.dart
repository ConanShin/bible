import 'package:flutter/material.dart';
import '../models/bible_book.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RecentReadingCard extends StatelessWidget {
  final BibleBook book;
  final int currentChapter; // 1-indexed (e.g., 1 for "1장")

  const RecentReadingCard({
    super.key,
    required this.book,
    this.currentChapter = 1, // Default to 1st chapter
  });

  @override
  Widget build(BuildContext context) {
    final double progress = book.totalChapters > 0 
        ? currentChapter / book.totalChapters 
        : 0.0;
        
    final bool isCompleted = currentChapter > book.totalChapters; // Logic: if current > total, assume done
    final safeProgress = progress.clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, // #FFFFFF
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)), // Light gray border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, color: AppColors.primaryBrand, size: 20),
              const SizedBox(width: 8),
              Text(
                book.name,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isCompleted ? '완료됨! ✓' : '$currentChapter장 읽는 중...',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 8),
          if (!isCompleted)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: safeProgress,
                backgroundColor: const Color(0xFFF3F4F6), // Light Gray
                color: const Color(0xFF10B981), // Green
                minHeight: 8,
              ),
            ),
          const SizedBox(height: 12),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Or spread
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to reading screen
                    // TODO: Implement navigation
                    print("Navigate to ${book.name} Chapter $currentChapter");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isCompleted ? '다시 읽기' : '읽기 계속하기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
