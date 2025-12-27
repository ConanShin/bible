import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bible_book.dart';
import '../../models/bible_chapter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_service.dart';
import '../../providers/bible_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/bible_verse.dart';
import '../../theme/app_text_styles.dart';

class BibleReadingScreen extends StatefulWidget {
  final int bookId;
  final int chapterNumber;
  final int initialVerse;

  const BibleReadingScreen({
    super.key,
    required this.bookId,
    required this.chapterNumber,
    this.initialVerse = 1,
  });

  @override
  State<BibleReadingScreen> createState() => _BibleReadingScreenState();
}

class _BibleReadingScreenState extends State<BibleReadingScreen> {
  final Map<int, GlobalKey> _verseKeys = {};
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    // Scroll after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToVerse(widget.initialVerse);
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _initKeys(BibleChapter chapter) {
    _verseKeys.clear();
    for (var verse in chapter.verses) {
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

  void _navigateToNext(int nextBookId, int nextChapterNumber) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BibleReadingScreen(
          bookId: nextBookId,
          chapterNumber: nextChapterNumber,
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
      builder: (context) => Padding(
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
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
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
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('북마크 삭제'),
                              content: const Text('이 북마크를 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('취소'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.error,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('삭제'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            userProvider.removeBookmark(verse);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('북마크가 삭제되었습니다.')),
                              );
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
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
                        backgroundColor: Theme.of(context).primaryColor,
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
    final bibleProvider = context.watch<BibleProvider>();
    final books = bibleProvider.books;

    // Find current book and chapter objects dynamically based on ID and version
    BibleBook? currentBook;
    try {
      currentBook = books.firstWhere((b) => b.id == widget.bookId);
    } catch (_) {
      // If book not found in current version, fallback or return error
      return Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: const Center(child: Text('성경 데이터를 찾을 수 없습니다.')),
      );
    }

    BibleChapter? currentChapter;
    try {
      currentChapter = currentBook.chapters.firstWhere(
        (c) => c.chapterNumber == widget.chapterNumber,
      );
    } catch (_) {
      currentChapter = currentBook.chapters.isNotEmpty
          ? currentBook.chapters[0]
          : null;
    }

    if (currentChapter == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: const Center(child: Text('장 정보를 찾을 수 없습니다.')),
      );
    }

    // Initialize keys for scrolling - do this here since it depends on the dynamic chapter
    _initKeys(currentChapter);

    // Find next chapter/book
    BibleBook? nextBook;
    BibleChapter? nextChapter;

    final currentChapterIndex = currentBook.chapters.indexWhere(
      (c) => c.chapterNumber == currentChapter!.chapterNumber,
    );

    if (currentChapterIndex < currentBook.chapters.length - 1) {
      nextBook = currentBook;
      nextChapter = currentBook.chapters[currentChapterIndex + 1];
    } else {
      final currentBookIndex = books.indexWhere((b) => b.id == currentBook!.id);
      if (currentBookIndex < books.length - 1) {
        nextBook = books[currentBookIndex + 1];
        if (nextBook.chapters.isNotEmpty) {
          nextChapter = nextBook.chapters[0];
        }
      }
    }

    // Colors determined by theme mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? Theme.of(context).scaffoldBackgroundColor
          : Theme.of(context).cardColor, // Paper color for light mode
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: Text(
          '${currentBook.name} ${currentChapter.chapterNumber}장',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              size: 22,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        backgroundColor: isDarkMode
            ? Theme.of(context).scaffoldBackgroundColor
            : Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ...currentChapter.verses.map((verse) {
              final isTarget = verse.verseNumber == widget.initialVerse;
              final userProvider = context.watch<UserProvider>();
              final isBookmarked = userProvider.isBookmarked(verse);

              return InkWell(
                onTap: () => _showBookmarkModal(context, verse),
                child: Container(
                  key: _verseKeys[verse.verseNumber],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isTarget
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
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
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (isBookmarked)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Icon(
                                  Icons.bookmark,
                                  size: 12,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          verse.text,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontSize: userProvider.preferences.fontSize,
                                height: 1.6,
                                decoration: isBookmarked
                                    ? TextDecoration.underline
                                    : null,
                                decorationColor: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.3),
                                decorationStyle: TextDecorationStyle.dashed,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Next Chapter Button
            if (nextBook != null && nextChapter != null)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _navigateToNext(
                      nextBook!.id,
                      nextChapter!.chapterNumber,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                      foregroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                      side: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nextBook.id == currentBook.id
                              ? '다음 장 (${nextChapter.chapterNumber}장)'
                              : '다음 책 (${nextBook.name} 1장)',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
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
      bottomNavigationBar: _isAdLoaded
          ? Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
    );
  }
}
