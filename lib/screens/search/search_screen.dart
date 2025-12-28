import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bible_verse.dart';
import '../../providers/bible_provider.dart';
import '../../providers/user_provider.dart';
import '../../l10n/app_strings.dart';
import '../home/bible_reading_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  List<BibleVerse> _searchResults = [];
  bool _hasSearched = false;
  String? _lastVersionId;

  List<InlineSpan> _buildHighlightedText(String text, String query) {
    if (query.trim().isEmpty) return [TextSpan(text: text)];

    final terms = query.trim().toLowerCase().split(RegExp(r'\s+'));
    final children = <InlineSpan>[];
    final lowerText = text.toLowerCase();
    int currentIndex = 0;

    // Use a simple approach: Find the first occurrence of any term, highlight it, then continue.
    // However, for multiple terms, they might overlap or be out of order.
    // A robust way is to find all ranges of all terms and merge overlapping ones.
    // For simplicity given the requirement, let's just highlight exact matches of terms.

    // Actually, splitting by regex keeping delimiters might be easier if we only had one term.
    // With multiple terms, let's use a simpler heuristic:
    // Split text by space, check each word if it contains any of the search terms.

    // Better approach:
    // 1. Create a simplified version of text for matching (lowercase).
    // 2. Iterate through the text character by character or word by word?
    // Let's stick to a basic logic: Regex replace? No, Custom parser.

    // Let's try matching all terms.
    // Create a regular expression from terms
    final sortedTerms = terms.toList()
      ..sort(
        (a, b) => b.length.compareTo(a.length),
      ); // match longer terms first
    final pattern = RegExp(
      sortedTerms.map((t) => RegExp.escape(t)).join('|'),
      caseSensitive: false,
    );

    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        children.add(
          TextSpan(
            text: match.group(0),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
            ),
          ),
        );
        return '';
      },
      onNonMatch: (String nonMatch) {
        children.add(TextSpan(text: nonMatch));
        return '';
      },
    );

    return children;
  }

  void _openChapter(BuildContext context, BibleVerse verse) {
    // 1. Find BibleBook object
    final bibleProvider = Provider.of<BibleProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final lang = userProvider.preferences.appLanguage;

    try {
      // Find by bookName (which might be Korean or English depending on how it was stored/parsed)
      // Actually, BibleVerse.bookName usually comes from the parser.
      // A more robust way is to match by name or englishName.
      final book = bibleProvider.books.firstWhere(
        (b) => b.name == verse.bookName || b.englishName == verse.bookName,
      );

      // 2. Add to History
      userProvider.addToHistory(book, verse.chapterNumber, verse.verseNumber);

      // 3. Show Reader Screen
      // Find the specific chapter object
      final chapter = book.chapters.firstWhere(
        (c) => c.chapterNumber == verse.chapterNumber,
        orElse: () => book.chapters.first,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BibleReadingScreen(
            bookId: book.id,
            chapterNumber: chapter.chapterNumber,
            initialVerse: verse.verseNumber,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('error_loading_bible', lang))),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text;
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    final provider = Provider.of<BibleProvider>(context, listen: false);
    final results = provider.searchVerses(query);

    setState(() {
      _searchResults = results;
      _hasSearched = true;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Reset search results if Bible version changed
    final userProvider = context.watch<UserProvider>();
    final currentVersionId = userProvider.preferences.selectedBibleVersion;
    if (_lastVersionId != null && _lastVersionId != currentVersionId) {
      // Version changed! Reset search results.
      _searchResults = [];
      _hasSearched = false;
      _searchController.clear();
    }
    _lastVersionId = currentVersionId;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: AppStrings.get(
                  'search_hint',
                  userProvider.preferences.appLanguage,
                ),
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Expanded(
            child: _hasSearched
                ? _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            AppStrings.get(
                              'no_search_results',
                              userProvider.preferences.appLanguage,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final verse = _searchResults[index];
                            final fontSize = context
                                .watch<UserProvider>()
                                .preferences
                                .fontSize;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              color: Theme.of(context).cardColor,
                              child: ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Consumer<BibleProvider>(
                                      builder: (context, bibleProvider, _) {
                                        final lang = userProvider
                                            .preferences
                                            .appLanguage;
                                        String bookDisplay = verse.bookName;
                                        try {
                                          final book = bibleProvider.books
                                              .firstWhere(
                                                (b) =>
                                                    b.name == verse.bookName ||
                                                    b.englishName ==
                                                        verse.bookName,
                                              );
                                          bookDisplay = book.getDisplayName(
                                            lang,
                                          );
                                        } catch (_) {}
                                        return Text(
                                          '$bookDisplay ${verse.chapterNumber}:${verse.verseNumber}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: fontSize,
                                            height: 1.5,
                                          ),
                                      children: _buildHighlightedText(
                                        verse.text,
                                        _searchController.text,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _openChapter(context, verse);
                                },
                              ),
                            );
                          },
                        )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.get(
                            'search_initial_message',
                            userProvider.preferences.appLanguage,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
