import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final String illustration;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.illustration,
  });
}

class OnboardingModal extends StatefulWidget {
  const OnboardingModal({super.key});

  @override
  State<OnboardingModal> createState() => _OnboardingModalState();
}

class _OnboardingModalState extends State<OnboardingModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> steps = [
    OnboardingStep(
      title: 'Welcome to AI Practice',
      description: 'Practice sharing your faith with our AI assistant. Choose different personalities to simulate real conversations.',
      icon: Icons.chat,
      illustration: 'assets/illustrations/welcome.svg',
    ),
    OnboardingStep(
      title: 'Choose a Personality',
      description: 'Start by selecting a personality type (skeptic, seeker, atheist, or religious) to practice with different perspectives.',
      icon: Icons.person_outline,
      illustration: 'assets/illustrations/personality.svg',
    ),
    OnboardingStep(
      title: 'Practice Conversations',
      description: 'Have natural conversations about faith. The AI will respond based on the selected personality type.',
      icon: Icons.question_answer,
      illustration: 'assets/illustrations/conversation.svg',
    ),
    OnboardingStep(
      title: 'Use the Question Bank',
      description: 'Access common questions and answers to help guide your conversations. You can use these directly in your chat.',
      icon: Icons.library_books,
      illustration: 'assets/illustrations/question_bank.svg',
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
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),
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
                        color: _currentPage == index ? Theme.of(context).primaryColor : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_currentPage < steps.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setBool('hasSeenAIPracticeOnboarding', true);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(_currentPage < steps.length - 1 ? 'Next' : 'Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
