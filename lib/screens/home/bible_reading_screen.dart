import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bible_book.dart';
import '../../models/bible_chapter.dart';
import '../../providers/bible_provider.dart';
import '../../providers/bible_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/bible_verse.dart';
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

  void _showBookmarkModal(BuildContext context, BibleVerse verse) {
    final userProvider = context.read<UserProvider>();
    final isBookmarked = userProvider.isBookmarked(verse);
    final existingBookmark = isBookmarked
        ? userProvider.bookmarks.firstWhere(
            (b) =>
                b.bookName == verse.bookName &&
                b.chapterNumber == verse.chapterNumber &&
                b.verseNumber == verse.verseNumber,
          )
        : null;

    final noteController = TextEditingController(text: existingBookmark?.note);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    verse.text,
                    style: AppTextStyles.bodyNormal.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      hintText: '메모를 입력하세요 (선택)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (isBookmarked)
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              userProvider.removeBookmark(verse);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('북마크가 삭제되었습니다.')),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('삭제'),
                          ),
                        ),
                      if (isBookmarked) const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            userProvider.addBookmark(
                              verse,
                              note: noteController.text,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('북마크가 저장되었습니다.')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBrand,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('저장'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
              final userProvider = context.watch<UserProvider>();
              final isBookmarked = userProvider.isBookmarked(verse);

              return InkWell(
                onTap: () => _showBookmarkModal(context, verse),
                child: Container(
                  key: _verseKeys[verse.verseNumber],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12, // Increased padding for better touch target
                  ),
                  decoration: BoxDecoration(
                    color:
                        isTarget
                            ? AppColors.primaryBrand.withOpacity(0.1)
                            : (isBookmarked
                                ? Colors.yellow.withOpacity(0.1)
                                : null),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 35,
                        child: Column(
                          children: [
                            Text(
                              '${verse.verseNumber}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryBrand,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isBookmarked)
                              const Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Icon(
                                  Icons.bookmark,
                                  size: 12,
                                  color: AppColors.primaryBrand,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          verse.text,
                          style: AppTextStyles.bodyNormal.copyWith(
                            fontSize:
                                userProvider.preferences.fontSize,
                            height: 1.6,
                            color: AppColors.textPrimary,
                            decoration:
                                isBookmarked
                                    ? TextDecoration.underline
                                    : null,
                            decorationColor: AppColors.primaryBrand
                                .withOpacity(0.3),
                            decorationStyle: TextDecorationStyle.dashed,
                          ),
                        ),
                      ),
                    ],
                  ),
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
