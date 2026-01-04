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
import '../../l10n/app_strings.dart';

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
    final adUnitId = AdService.getBannerAdUnitId(
      context.read<UserProvider>().isAdFree,
    );

    if (adUnitId == null) {
      setState(() {
        _isAdLoaded = false;
        _bannerAd = null;
      });
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
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
          setState(() {
            _isAdLoaded = false;
          });
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
    final bibleProvider = context.read<BibleProvider>();
    final currentBook = bibleProvider.books.firstWhere(
      (b) => b.id == widget.bookId,
      orElse: () => bibleProvider.books.firstWhere(
        (b) => b.name == verse.bookName || b.englishName == verse.bookName,
        orElse: () => bibleProvider.books.first,
      ),
    );
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
                '${currentBook.getDisplayName(userProvider.preferences.appLanguage)} ${verse.chapterNumber}:${verse.verseNumber}',
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
                decoration: InputDecoration(
                  hintText: AppStrings.get(
                    'bookmark_note_hint',
                    userProvider.preferences.appLanguage,
                  ),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(12),
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
                            builder: (context) {
                              final lang = userProvider.preferences.appLanguage;
                              return AlertDialog(
                                title: Text(
                                  AppStrings.get('delete_bookmark_title', lang),
                                ),
                                content: Text(
                                  AppStrings.get(
                                    'delete_bookmark_confirm',
                                    lang,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(AppStrings.get('cancel', lang)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(AppStrings.get('delete', lang)),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            userProvider.removeBookmark(verse);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppStrings.get(
                                      'bookmark_deleted',
                                      userProvider.preferences.appLanguage,
                                    ),
                                  ),
                                ),
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
                        child: Text(
                          AppStrings.get(
                            'delete',
                            userProvider.preferences.appLanguage,
                          ),
                        ),
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
                          SnackBar(
                            content: Text(
                              AppStrings.get(
                                'bookmark_saved',
                                userProvider.preferences.appLanguage,
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppStrings.get(
                          'save',
                          userProvider.preferences.appLanguage,
                        ),
                      ),
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
    final lang = context.watch<UserProvider>().preferences.appLanguage;
    try {
      currentBook = books.firstWhere((b) => b.id == widget.bookId);
    } catch (_) {
      // If book not found in current version, fallback or return error
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.get('error', lang))),
        body: Center(child: Text(AppStrings.get('bible_data_not_found', lang))),
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
        appBar: AppBar(title: Text(AppStrings.get('error', lang))),
        body: Center(
          child: Text(AppStrings.get('chapter_data_not_found', lang)),
        ),
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
          '${lang == 'ko' ? currentBook.name : currentBook.englishName} ${currentChapter.chapterNumber}',
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
                              ? '${AppStrings.get('next_chapter', lang)} (${nextChapter.chapterNumber})'
                              : '${AppStrings.get('next_book', lang)} (${nextBook.getDisplayName(lang)} 1)',
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
