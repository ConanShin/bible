import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bible_book.dart';
import '../../models/bible_chapter.dart';
import '../../providers/bible_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class BibleReadingScreen extends StatefulWidget {
  final BibleBook book;
  final BibleChapter chapter;
  final int initialVerse;

  const BibleReadingScreen({
    super.key,
    required this.book,
    required this.chapter,
    this.initialVerse = 1,
  });

  @override
  State<BibleReadingScreen> createState() => _BibleReadingScreenState();
}

class _BibleReadingScreenState extends State<BibleReadingScreen> {
  final Map<int, GlobalKey> _verseKeys = {};

  @override
  void initState() {
    super.initState();
    _initKeys();
    // Scroll after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToVerse(widget.initialVerse);
    });
  }

  void _initKeys() {
    _verseKeys.clear();
    for (var verse in widget.chapter.verses) {
      _verseKeys[verse.verseNumber] = GlobalKey();
    }
  }

  void _scrollToVerse(int verseNumber) {
    Future.delayed(const Duration(milliseconds: 300), () {
      final key = _verseKeys[verseNumber];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _navigateToNext(BibleBook nextBook, BibleChapter nextChapter) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BibleReadingScreen(
          book: nextBook,
          chapter: nextChapter,
          initialVerse: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bibleProvider = context.read<BibleProvider>();
    final books = bibleProvider.books;

    // Find next chapter/book
    BibleBook? nextBook;
    BibleChapter? nextChapter;

    final currentChapterIndex = widget.book.chapters.indexWhere(
      (c) => c.chapterNumber == widget.chapter.chapterNumber,
    );

    if (currentChapterIndex < widget.book.chapters.length - 1) {
      nextBook = widget.book;
      nextChapter = widget.book.chapters[currentChapterIndex + 1];
    } else {
      final currentBookIndex = books.indexWhere((b) => b.id == widget.book.id);
      if (currentBookIndex < books.length - 1) {
        nextBook = books[currentBookIndex + 1];
        if (nextBook.chapters.isNotEmpty) {
          nextChapter = nextBook.chapters[0];
        }
      }
    }

    final isOldTestament = widget.book.testament == 'old';
    final testamentColor = isOldTestament
        ? AppColors.oldTestament
        : AppColors.newTestament;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: Text('${widget.book.name} ${widget.chapter.chapterNumber}장'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
        elevation: 1,
        backgroundColor: testamentColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ...widget.chapter.verses.map((verse) {
              final isTarget = verse.verseNumber == widget.initialVerse;

              return Container(
                key: _verseKeys[verse.verseNumber],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isTarget
                      ? AppColors.primaryBrand.withOpacity(0.1)
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${verse.verseNumber}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryBrand,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        verse.text,
                        style: AppTextStyles.bodyNormal.copyWith(
                          fontSize: context
                              .watch<UserProvider>()
                              .preferences
                              .fontSize,
                          height: 1.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            // Next Chapter Button
            if (nextBook != null && nextChapter != null)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _navigateToNext(nextBook!, nextChapter!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primaryBrand,
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nextBook.id == widget.book.id
                              ? '다음 장 (${nextChapter.chapterNumber}장)'
                              : '다음 책 (${nextBook.name} 1장)',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBrand,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
