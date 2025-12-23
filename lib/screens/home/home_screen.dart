import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/bible_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/today_verse_card.dart';
import '../../widgets/recent_reading_card.dart';
import '../../widgets/new_book_start_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    // final bibleProvider = context.watch<BibleProvider>(); // Not used directly here yet

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Verse
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '오늘의 말씀',
              style: AppTextStyles.heading3,
            ),
          ),
          const TodayVerseCard(),
          
          const SizedBox(height: 24),
          
          // Recent Reading
          if (userProvider.readingHistory.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '최근 읽은 내용',
                style: AppTextStyles.heading3,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: userProvider.readingHistory.length,
              itemBuilder: (context, index) {
                final book = userProvider.readingHistory[index];
                return RecentReadingCard(book: book); // Default chapter 1 for now
              },
            ),
            const SizedBox(height: 24),
          ],
          
          // Start New Book
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: NewBookStartCard(),
          ),
          
          const SizedBox(height: 40), // Bottom padding
        ],
      ),
    );
  }
}
