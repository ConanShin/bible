import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bible_book.dart';
import '../../models/bible_chapter.dart';
import '../../providers/bible_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'bible_reading_screen.dart';

class BibleSelectionScreen extends StatefulWidget {
  const BibleSelectionScreen({super.key});

  @override
  State<BibleSelectionScreen> createState() => _BibleSelectionScreenState();
}

class _BibleSelectionScreenState extends State<BibleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  int _step = 0; // 0: Book, 1: Chapter, 2: Verse
  BibleBook? _selectedBook;
  BibleChapter? _selectedChapter;
  bool _isExpanding = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _nextStep() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
    );
  }

  void _prevStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
    );
  }

  void _onBookSelected(BibleBook book) {
    setState(() {
      _selectedBook = book;
    });
    _nextStep();
  }

  void _onChapterSelected(BibleChapter chapter) {
    setState(() {
      _selectedChapter = chapter;
    });
    _nextStep();
  }

  void _onVerseSelected(int verseNumber) async {
    if (_selectedBook != null && _selectedChapter != null) {
      // Save to reading history
      context.read<UserProvider>().addToHistory(
        _selectedBook!,
        _selectedChapter!.chapterNumber,
        verseNumber,
      );

      setState(() {
        _isExpanding = true;
      });

      // Wait for expansion animation
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      // Close modal WITHOUT animation (since we already expanded to full screen)
      Navigator.of(context).pop();

      // Navigate to reading screen with zero animation
      // Navigate to reading screen with vertical slide-down support
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              BibleReadingScreen(
                bookId: _selectedBook!.id,
                chapterNumber: _selectedChapter!.chapterNumber,
                initialVerse: verseNumber,
              ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // For reverse transition (pop), slide down
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bibleProvider = context.watch<BibleProvider>();
    final books = bibleProvider.books;

    double screenHeight = MediaQuery.of(context).size.height;
    double currentHeight = _isExpanding ? screenHeight : screenHeight * 0.95;
    double currentRadius = _isExpanding ? 0 : 28;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
      height: currentHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(currentRadius),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _getTitle(),
              key: ValueKey(_step),
              style: AppTextStyles.heading3.copyWith(fontSize: 18),
            ),
          ),
          leading: _step > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: _prevStep,
                )
              : null,
          actions: [
            if (!_isExpanding)
              IconButton(
                icon: const Icon(Icons.close, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            const SizedBox(width: 8),
          ],
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: Column(
          children: [
            if (!_isExpanding) _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _step = index;
                  });
                },
                children: [
                  _buildBookStep(books),
                  _buildChapterStep(),
                  _buildVerseStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_step) {
      case 0:
        return '성경 선택';
      case 1:
        return _selectedBook?.name ?? '장 선택';
      case 2:
        return '${_selectedBook?.name} ${_selectedChapter?.chapterNumber}장';
      default:
        return '성경 선택';
    }
  }

  Widget _buildProgressBar() {
    // Decide color based on selected book or current step context
    Color activeColor = Theme.of(context).primaryColor;
    if (_selectedBook != null) {
      activeColor = _selectedBook!.testament == 'old'
          ? AppColors.oldTestament
          : AppColors.newTestament;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = _step >= index;
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor
                    : Theme.of(
                        index < 0 ? context : context,
                      ).dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBookStep(List<BibleBook> books) {
    final filteredBooks = books.where((book) {
      final query = _searchQuery.toLowerCase();
      return book.name.toLowerCase().contains(query) ||
          book.englishName.toLowerCase().contains(query);
    }).toList();

    final oldBooks = filteredBooks.where((b) => b.testament == 'old').toList();
    final newBooks = filteredBooks.where((b) => b.testament == 'new').toList();

    return Column(
      children: [
        _buildSearchBar(books),
        Expanded(
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '구약성경'),
                  Tab(text: '신약성경'),
                ],
                labelColor: Theme.of(context).colorScheme.onSurface,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.4),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookListView(oldBooks, AppColors.oldTestament),
                    _buildBookListView(newBooks, AppColors.newTestament),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(List<BibleBook> allBooks) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(fontSize: 14),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;

                    // Auto-switch tabs based on the first match
                    if (value.isNotEmpty) {
                      try {
                        final firstMatch = allBooks.firstWhere((book) {
                          final query = value.toLowerCase();
                          return book.name.toLowerCase().contains(query) ||
                              book.englishName.toLowerCase().contains(query);
                        });

                        final targetIndex = firstMatch.testament == 'old'
                            ? 0
                            : 1;
                        if (_tabController.index != targetIndex) {
                          _tabController.animateTo(targetIndex);
                        }
                      } catch (_) {
                        // No match found
                      }
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: '성경 검색 (예: 창세, Gen)',
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.35),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.cancel,
                    size: 20,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookListView(List<BibleBook> books, Color testamentColor) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return InkWell(
          onTap: () => _onBookSelected(book),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: testamentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    book.name.substring(0, 1),
                    style: TextStyle(
                      color: testamentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        book.englishName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChapterStep() {
    if (_selectedBook == null) return const SizedBox.shrink();

    return _buildGridStep(
      items: _selectedBook!.chapters,
      labelBuilder: (chapter) => '${chapter.chapterNumber}',
      onSelected: (chapter) => _onChapterSelected(chapter),
      subtitle: '몇 장을 읽으시겠어요?',
    );
  }

  Widget _buildVerseStep() {
    if (_selectedChapter == null) return const SizedBox.shrink();

    return _buildGridStep(
      items: _selectedChapter!.verses,
      labelBuilder: (verse) => '${verse.verseNumber}',
      onSelected: (verse) => _onVerseSelected(verse.verseNumber),
      subtitle: '몇 절부터 읽으시겠어요?',
    );
  }

  Widget _buildGridStep<T>({
    required List<T> items,
    required String Function(T) labelBuilder,
    required void Function(T) onSelected,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () => onSelected(item),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labelBuilder(item),
                    style: AppTextStyles.bodyNormal.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
