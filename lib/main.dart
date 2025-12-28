import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme/app_theme.dart';
import 'providers/bible_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_app.dart';
import 'services/bible_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BibleService()),
        ChangeNotifierProxyProvider<BibleService, BibleProvider>(
          create: (context) => BibleProvider(context.read<BibleService>()),
          update: (context, bibleService, previous) =>
              previous ?? BibleProvider(bibleService),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final bibleProvider = context.read<BibleProvider>();

      // 1. Load preferences first (to get selected language/version)
      userProvider.loadPreferences().then((_) {
        // Build correct provider based on loaded preferences
        context.read<ThemeProvider>().setDarkMode(
          userProvider.preferences.isDarkMode,
        );

        // 2. Load Bible data with the SAVED version
        bibleProvider
            .loadBibleData(
              version: userProvider.preferences.selectedBibleVersion,
            )
            .then((_) {
              // 3. Load user data (history/bookmarks) that depends on Bible data
              userProvider.loadUserData(bibleProvider);
            });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Bible App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(userProvider.preferences.appLanguage),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ko')],
      home: userProvider.hasCompletedOnboarding
          ? const MainApp()
          : const OnboardingScreen(),
    );
  }
}
