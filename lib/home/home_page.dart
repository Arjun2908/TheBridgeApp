import 'package:flutter/material.dart';

import 'package:the_bridge_app/global_helpers.dart';
import 'package:the_bridge_app/bottom_nav_bar.dart';
import 'package:the_bridge_app/widgets/common_app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildAnimatedCard({
    required Widget child,
    required VoidCallback onTap,
  }) {
    bool isPressed = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) {
            setState(() => isPressed = false);
            onTap();
          },
          onTapCancel: () => setState(() => isPressed = false),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: isPressed ? 0.95 : 1.0,
            child: Card(
              elevation: isPressed ? 5 : 10,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CommonAppBar(title: 'The Bridge App'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: isDarkMode
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          -1,
                          0,
                          0,
                          0,
                          255,
                          0,
                          -1,
                          0,
                          0,
                          255,
                          0,
                          0,
                          -1,
                          0,
                          255,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                        child: Image.asset(
                          'assets/home.png',
                          fit: BoxFit.contain,
                        ),
                      )
                    : Image.asset(
                        'assets/home.png',
                        fit: BoxFit.contain,
                      ),
              ),
              const SizedBox(height: 16),
              _buildAnimatedCard(
                onTap: () => onItemTapped(4, context),
                child: Column(
                  children: [
                    const Icon(Icons.play_circle_outline, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Start Bridge Diagram',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share the gospel using the Bridge illustration',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildAnimatedCard(
                      onTap: () => onItemTapped(2, context),
                      child: Column(
                        children: [
                          const Icon(Icons.chat_bubble_outline),
                          const SizedBox(height: 8),
                          Text(
                            'Practice with AI',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildAnimatedCard(
                      onTap: () => onItemTapped(3, context),
                      child: Column(
                        children: [
                          const Icon(Icons.library_books_outlined),
                          const SizedBox(height: 8),
                          Text(
                            'Resources',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildAnimatedCard(
                onTap: () => onItemTapped(1, context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.note_alt_outlined),
                    const SizedBox(width: 8),
                    Text(
                      'Your Notes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onItemTapped: (index) => onItemTapped(index, context),
      ),
    );
  }
}
