import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/bible_provider.dart';
import '../../models/bookmark.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../l10n/app_strings.dart';
import '../home/bible_reading_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bookmarks = userProvider.bookmarks;
    final fontSize = userProvider.preferences.fontSize;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.get(
                      'no_bookmarks',
                      userProvider.preferences.appLanguage,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              itemCount: bookmarks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                return _BookmarkItem(bookmark: bookmark, fontSize: fontSize);
              },
            ),
    );
  }
}

class _BookmarkItem extends StatefulWidget {
  final Bookmark bookmark;
  final double fontSize;

  const _BookmarkItem({required this.bookmark, required this.fontSize});

  @override
  State<_BookmarkItem> createState() => _BookmarkItemState();
}

class _BookmarkItemState extends State<_BookmarkItem> {
  bool _isExpanded = false;

  bool get _isExpandable =>
      widget.bookmark.note!.length > 60 ||
      widget.bookmark.note!.split('\n').length > 3;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bibleProvider = context.watch<BibleProvider>();
    String displayVerseText = widget.bookmark.verseText;

    // Try to get text from current version
    final lang = context.watch<UserProvider>().preferences.appLanguage;
    String displayBookName = widget.bookmark.bookName;

    final currentVerse = bibleProvider.getVerse(
      widget.bookmark.bookName,
      widget.bookmark.chapterNumber,
      widget.bookmark.verseNumber,
    );

    if (currentVerse != null) {
      displayVerseText = currentVerse.text;

      // Also ensure book name is localized
      try {
        final book = bibleProvider.books.firstWhere(
          (b) =>
              b.name == widget.bookmark.bookName ||
              b.englishName == widget.bookmark.bookName,
        );
        displayBookName = book.getDisplayName(lang);
      } catch (_) {}
    }

    return Dismissible(
      key: Key(widget.bookmark.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        final lang = context.read<UserProvider>().preferences.appLanguage;
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppStrings.get('delete_bookmark_title', lang)),
            content: Text(AppStrings.get('delete_bookmark_confirm', lang)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppStrings.get('cancel', lang)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                child: Text(AppStrings.get('delete', lang)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<UserProvider>().deleteBookmarkById(widget.bookmark.id);
        final lang = context.read<UserProvider>().preferences.appLanguage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('bookmark_deleted', lang)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              _navigateToVerse(context);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Reference and Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$displayBookName ${widget.bookmark.chapterNumber}:${widget.bookmark.verseNumber}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Text(
                        _formatDate(widget.bookmark.createdAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Verse Text
                  Text(
                    displayVerseText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontSize: widget.fontSize,
                    ),
                  ),

                  // Note Section
                  if (widget.bookmark.note != null &&
                      widget.bookmark.note!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _isExpandable
                          ? () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            }
                          : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant.withOpacity(0.5)
                              : Theme.of(context).primaryColor.withOpacity(
                                  0.1,
                                ), // Match primary theme color tint
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'MEMO',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            AnimatedCrossFade(
                              firstChild: Text(
                                widget.bookmark.note!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: widget.fontSize * 0.9,
                                      height: 1.5,
                                    ),
                              ),
                              secondChild: Text(
                                widget.bookmark.note!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: widget.fontSize * 0.9,
                                      height: 1.5,
                                    ),
                              ),
                              crossFadeState: _isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 300),
                            ),
                            if (_isExpandable)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isExpanded
                                          ? AppStrings.get(
                                              'fold',
                                              context
                                                  .read<UserProvider>()
                                                  .preferences
                                                  .appLanguage,
                                            )
                                          : AppStrings.get(
                                              'view_all',
                                              context
                                                  .read<UserProvider>()
                                                  .preferences
                                                  .appLanguage,
                                            ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    AnimatedRotation(
                                      turns: _isExpanded ? 0.5 : 0,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToVerse(BuildContext context) {
    final lang = context.read<UserProvider>().preferences.appLanguage;
    try {
      final bibleProvider = context.read<BibleProvider>();
      final book = bibleProvider.books.firstWhere(
        (b) =>
            b.name == widget.bookmark.bookName ||
            b.englishName == widget.bookmark.bookName,
      );
      final chapter = book.chapters.firstWhere(
        (c) => c.chapterNumber == widget.bookmark.chapterNumber,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BibleReadingScreen(
            bookId: book.id,
            chapterNumber: chapter.chapterNumber,
            initialVerse: widget.bookmark.verseNumber,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('verse_not_found', lang))),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
