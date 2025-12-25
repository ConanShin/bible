import 'package:flutter/material.dart';
import '../models/reading_history_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

import '../screens/home/bible_reading_screen.dart';

class RecentReadingCard extends StatelessWidget {
  final ReadingHistoryItem item;

  const RecentReadingCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isOldTestament = item.book.testament == 'old';
    final testamentColor = isOldTestament
        ? AppColors.oldTestament
        : AppColors.newTestament;

    return InkWell(
      onTap: () {
        final chapterIndex = (item.chapterNumber - 1).clamp(
          0,
          item.book.chapters.length - 1,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => BibleReadingScreen(
              book: item.book,
              chapter: item.book.chapters[chapterIndex],
              initialVerse: item.verseNumber,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: testamentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.book_outlined, color: testamentColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.book.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.chapterNumber}장 ${item.verseNumber}절 읽음',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
