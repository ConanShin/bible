import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/bible_provider.dart';
import '../providers/user_provider.dart';

class TodayVerseCard extends StatelessWidget {
  const TodayVerseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bibleProvider = context.watch<BibleProvider>();
    final verse = bibleProvider.getTodayVerse();

    if (verse == null) {
      return const SizedBox.shrink();
    }

    final userProvider = context.watch<UserProvider>();
    final isBookmarked = userProvider.bookmarks.any(
      (v) =>
          v.text == verse.text &&
          v.bookName == verse.bookName &&
          v.chapterNumber == verse.chapterNumber &&
          v.verseNumber == verse.verseNumber,
    );

    return Container(
      width: double.infinity,
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/today_verse_bg.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Glassmorphism Overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '오늘의 말씀',
                          style: GoogleFonts.notoSansKr(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _ActionButton(
                            icon: isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_outline,
                            onTap: () => userProvider.toggleBookmark(verse),
                          ),
                          const SizedBox(width: 12),
                          _ActionButton(
                            icon: Icons.share_outlined,
                            onTap: () => Share.share(
                              '${verse.text}\n\n${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '“${verse.text}”',
                    style: GoogleFonts.nanumMyeongjo(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${verse.bookName} ${verse.chapterNumber}:${verse.verseNumber}',
                    style: GoogleFonts.notoSansKr(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
