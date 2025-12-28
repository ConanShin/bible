import '../../widgets/download_progress_dialog.dart';
import '../main_app.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/bible_provider.dart';
import '../../theme/spacing.dart';
import 'step_1_welcome.dart';
import 'step_0_language_selection.dart';
import 'step_2_bible_selection.dart';
import 'step_3_settings.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final userProvider = context.read<UserProvider>();
    final selectedVersion = userProvider.preferences.selectedBibleVersion;

    // Show download dialog
    final success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          DownloadProgressDialog(bibleVersion: selectedVersion),
    );

    if (success == true && mounted) {
      await userProvider.completeOnboarding();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainApp()),
          (route) => false,
        );
      }
    } else {
      // Handle failure or cancellation?
      // For now, if cancelled, stay on onboarding.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  Step1Welcome(onNext: _nextPage),
                  Step0LanguageSelection(
                    onLanguageSelected: (lang) {
                      context.read<BibleProvider>().updateLanguageFilter(lang);
                      _nextPage();
                    },
                  ),
                  Step2BibleSelection(onNext: _nextPage, onBack: _prevPage),
                  Step3Settings(
                    onBack: _prevPage,
                    onComplete: _completeOnboarding,
                  ),
                ],
              ),
            ),

            // Page Indicator
            if (_currentPage < 3)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
