import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/bible_provider.dart';
import '../../theme/app_text_styles.dart';
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
          const SizedBox(height: 24),

          // Start New Book
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: NewBookStartCard(),
          ),

          const SizedBox(height: 32),

          // Recent Reading History
          if (userProvider.readingHistory.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
              child: Text(
                '최근 읽은 기록',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: userProvider.readingHistory.length,
              itemBuilder: (context, index) {
                final item = userProvider.readingHistory[index];
                return RecentReadingCard(item: item);
              },
            ),
          ],

          const SizedBox(height: 40), // Bottom padding
        ],
      ),
    );
  }
}
