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

    // Use lighter colors for Dark Mode visibility
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final displayColor = isDarkMode
        ? (isOldTestament
              ? const Color(0xFF9FA8DA) // Indigo 200 for Dark Mode
              : const Color(0xFFBCAAA4)) // Brown 200 for Dark Mode
        : (isOldTestament ? AppColors.oldTestament : AppColors.newTestament);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => BibleReadingScreen(
              bookId: item.book.id,
              chapterNumber: item.chapterNumber,
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: displayColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.book_outlined, color: displayColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.book.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.chapterNumber}장 ${item.verseNumber}절 읽음',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
