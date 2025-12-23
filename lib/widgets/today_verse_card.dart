import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/bible_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/bible_verse.dart';

class TodayVerseCard extends StatelessWidget {
  const TodayVerseCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch BibleProvider for the verse
    // Note: In a real app, we might want to fetch this once or use a FutureBuilder if it's async
    // But since getAllVerses is sync (after load), we can just access it.
    final bibleProvider = context.watch<BibleProvider>();
    final verse = bibleProvider.getTodayVerse();

    if (verse == null) {
      return const SizedBox.shrink(); // or a loading shimmer
    }

    // Watch UserProvider for bookmark status
    final userProvider = context.watch<UserProvider>();
    // Ensure verse is treated as non-null. Since we returned if null above, we can safely bang it.
    final nonNullVerse = verse!; 
    final isBookmarked = userProvider.bookmarks.any((v) => 
      v.text == nonNullVerse.text && v.bookName == nonNullVerse.bookName && v.chapterNumber == nonNullVerse.chapterNumber && v.verseNumber == nonNullVerse.verseNumber
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight, // #4A9FB4
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1), 
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${nonNullVerse.text}"',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              height: 1.6,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text(
            '${nonNullVerse.bookName} ${nonNullVerse.chapterNumber}:${nonNullVerse.verseNumber}',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
            ),
          ),
          Text(
            '개역개정', // Assuming version
            style: AppTextStyles.caption.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Spec shows buttons on bottom
            children: [
              IconButton(
                onPressed: () {
                  userProvider.toggleBookmark(nonNullVerse);
                },
                icon: Icon(
                  isBookmarked ? Icons.favorite : Icons.favorite_outline,
                  color: Colors.white,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  // Use Share (if SharePlus isn't found, revert. But try Share first as it's standard)
                  // The error said: 'Share' is deprecated. Use SharePlus instead.
                  // ignore: deprecated_member_use
                  Share.share(
                    '${nonNullVerse.text}\n\n${nonNullVerse.bookName} ${nonNullVerse.chapterNumber}:${nonNullVerse.verseNumber}',
                  );
                },
                icon: const Icon(Icons.share_outlined, color: Colors.white), // Spec says share ->
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

