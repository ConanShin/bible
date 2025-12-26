import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/bible_provider.dart';
import '../../models/bookmark.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../home/bible_reading_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bookmarks = userProvider.bookmarks;
    final fontSize = userProvider.preferences.fontSize;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Very light grey for background depth
      body: bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: AppColors.textTertiary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '저장된 북마크가 없습니다.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
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
                return _BookmarkItem(
                  bookmark: bookmark,
                  fontSize: fontSize,
                );
              },
            ),
    );
  }
}

class _BookmarkItem extends StatefulWidget {
  final Bookmark bookmark;
  final double fontSize;

  const _BookmarkItem({
    required this.bookmark,
    required this.fontSize,
  });

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
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) {
        context.read<UserProvider>().deleteBookmarkById(widget.bookmark.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('북마크가 삭제되었습니다.'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                              color: AppColors.primaryBrand,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.bookmark.bookName} ${widget.bookmark.chapterNumber}:${widget.bookmark.verseNumber}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatDate(widget.bookmark.createdAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Verse Text
                  Text(
                    widget.bookmark.verseText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyNormal.copyWith(
                      color: AppColors.textSecondary,
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
                          : null, // Let parent InkWell handle it if not expandable?? No, if null, it passes through. Correct.
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA), // Very light grey
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.edit_note,
                                    size: 16,
                                    color:
                                        AppColors.primaryBrand.withOpacity(0.7)),
                                const SizedBox(width: 6),
                                Text(
                                  'MEMO',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primaryBrand
                                        .withOpacity(0.7),
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
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: widget.fontSize *
                                      0.9, // Slightly smaller than verse
                                  height: 1.5,
                                ),
                              ),
                              secondChild: Text(
                                widget.bookmark.note!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
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
                                      _isExpanded ? '접기' : '전체 보기',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textTertiary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    AnimatedRotation(
                                      turns: _isExpanded ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 300),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: AppColors.textTertiary,
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
    try {
      final bibleProvider = context.read<BibleProvider>();
      final book = bibleProvider.books.firstWhere(
        (b) => b.name == widget.bookmark.bookName,
      );
      final chapter = book.chapters.firstWhere(
        (c) => c.chapterNumber == widget.bookmark.chapterNumber,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BibleReadingScreen(
            book: book,
            chapter: chapter,
            initialVerse: widget.bookmark.verseNumber,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('해당 구절을 찾을 수 없습니다.')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
