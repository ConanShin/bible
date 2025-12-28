import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'bookmarks/bookmarks_screen.dart';
import 'settings/settings_screen.dart';
import '../providers/user_provider.dart';
import '../l10n/app_strings.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const BookmarksScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final lang = userProvider.preferences.appLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.get('app_title', lang),
          style: const TextStyle(fontWeight: FontWeight.w100),
        ),
        elevation: 1,
        // backgroundColor: Colors.white, // Removed to support dark mode
        // foregroundColor: AppColors.textPrimary, // Removed to support dark mode
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.4),
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book),
            label: AppStrings.get('nav_read', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: AppStrings.get('nav_search', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bookmark),
            label: AppStrings.get('bookmarks', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppStrings.get('settings', lang),
          ),
        ],
      ),
    );
  }
}
