import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppOnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final String illustration;

  AppOnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.illustration,
  });
}

class AppOnboardingModal extends StatefulWidget {
  const AppOnboardingModal({super.key});

  @override
  State<AppOnboardingModal> createState() => _AppOnboardingModalState();
}

class _AppOnboardingModalState extends State<AppOnboardingModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<AppOnboardingStep> steps = [
    AppOnboardingStep(
      title: 'Welcome to The Bridge App',
      description: 'Share your faith using the Bridge illustration method.',
      icon: Icons.home,
      illustration: 'assets/illustrations/onboarding_welcome.svg',
    ),
    AppOnboardingStep(
      title: 'Practice with AI',
      description: 'Practice sharing your faith with our AI assistant in different scenarios.',
      icon: Icons.chat,
      illustration: 'assets/illustrations/onboarding_conversation.svg',
    ),
    AppOnboardingStep(
      title: 'Take Notes',
      description: 'Keep track of your conversations and insights as you share your faith and access them directly when you need them while sharing your faith.',
      icon: Icons.note,
      illustration: 'assets/illustrations/notes.svg',
    ),
    AppOnboardingStep(
      title: 'Access Resources',
      description: 'Find helpful materials, guides, and references to support your faith sharing journey.',
      icon: Icons.library_books,
      illustration: 'assets/illustrations/resources.svg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        step.description,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: SvgPicture.asset(
                          step.illustration,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 80,
                  child: TextButton(
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    child: const Text('Back'),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    steps.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextButton(
                    onPressed: () {
                      if (_currentPage < steps.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setBool('hasSeenAppOnboarding', true);
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(_currentPage < steps.length - 1 ? 'Next' : 'Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
