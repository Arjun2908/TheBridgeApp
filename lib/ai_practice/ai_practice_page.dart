import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_bridge_app/bottom_nav_bar.dart';
import 'package:the_bridge_app/global_helpers.dart';

import 'package:the_bridge_app/widgets/common_app_bar.dart';

import 'package:the_bridge_app/ai_practice/providers/ai_practice_provider.dart';
import 'package:the_bridge_app/ai_practice/widgets/onboarding_modal.dart';
import 'package:the_bridge_app/ai_practice/widgets/typing_indicator.dart';

import 'package:the_bridge_app/ai_practice/data/question_data.dart';

import 'package:the_bridge_app/providers/notes_provider.dart';
import 'package:the_bridge_app/models/note.dart';

class AIPracticePage extends StatefulWidget {
  const AIPracticePage({super.key});

  @override
  State<AIPracticePage> createState() => _AIPracticePageState();
}

class _AIPracticePageState extends State<AIPracticePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowOnboarding();
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final isAtBottom = _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100;
      if (_showScrollToBottom != !isAtBottom) {
        setState(() {
          _showScrollToBottom = !isAtBottom;
        });
      }
    }
  }

  Future<void> _checkAndShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenAIPracticeOnboarding') ?? false;

    if (!hasSeenOnboarding && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const OnboardingModal(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CommonAppBar(
          title: 'Practice',
          additionalActions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'Help',
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => const OnboardingModal(),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline),
                    SizedBox(width: 8),
                    Text('Practice Mode'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.library_books_outlined),
                    SizedBox(width: 8),
                    Text('Question Bank'),
                  ],
                ),
              ),
            ],
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            _buildPracticeMode(),
            _buildQuestionBank(),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: 2,
          onItemTapped: (index) => onItemTapped(index, context),
        ),
      ),
    );
  }

  Widget _buildPracticeMode() {
    return Consumer<AIPracticeProvider>(
      builder: (context, aiProvider, child) {
        if (aiProvider.isInitializing) {
          return const Center(child: CircularProgressIndicator());
        }

        if (aiProvider.currentSession == null) {
          return _buildPersonalitySelector(aiProvider);
        }

        return Stack(
          children: [
            Column(
              children: [
                // Compact chat header
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                    title: Row(
                      children: [
                        Icon(
                          _getPersonalityIcon(aiProvider.currentSession!.personality),
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          aiProvider.currentSession!.personality.capitalize(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    trailing: TextButton.icon(
                      onPressed: () => _showEndChatDialog(aiProvider),
                      icon: Icon(
                        Icons.stop,
                        size: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      label: Text(
                        'End Chat',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          _getPersonalityDescription(aiProvider.currentSession!.personality),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: aiProvider.currentSession!.messages.length + (aiProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == aiProvider.currentSession!.messages.length && aiProvider.isLoading) {
                        return const TypingIndicator();
                      }
                      final message = aiProvider.currentSession!.messages[index];
                      return Dismissible(
                        key: Key('message_${index}_${message.timestamp.millisecondsSinceEpoch}'),
                        direction: message.isUser ? DismissDirection.startToEnd : DismissDirection.endToStart,
                        background: Container(
                          alignment: message.isUser ? Alignment.centerLeft : Alignment.centerRight,
                          padding: EdgeInsets.only(
                            left: message.isUser ? 24.0 : 0,
                            right: message.isUser ? 0 : 24.0,
                          ),
                          color: Theme.of(context).colorScheme.surface,
                          child: AnimatedBuilder(
                            animation: DismissibleAnimation(ValueKey('message_${index}_${message.timestamp.millisecondsSinceEpoch}')),
                            builder: (context, child) {
                              return Row(
                                mainAxisAlignment: message.isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
                                children: [
                                  if (!message.isUser) ...[
                                    Icon(
                                      Icons.bookmark_outline,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Save as Note',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  if (message.isUser) ...[
                                    Text(
                                      'Save as Note',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.bookmark_outline,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                        dismissThresholds: const {
                          DismissDirection.endToStart: 0.3,
                          DismissDirection.startToEnd: 0.3,
                        },
                        confirmDismiss: (direction) async {
                          HapticFeedback.mediumImpact();
                          await _saveMessageAsNote(message.content);
                          return false;
                        },
                        child: Align(
                          alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: IntrinsicWidth(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.8,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: message.isUser ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(message.content),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(aiProvider),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          onPressed: () => _sendMessage(aiProvider),
                          child: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_showScrollToBottom)
              Positioned(
                right: 16,
                bottom: 80, // Above the input box
                child: FloatingActionButton.small(
                  onPressed: _scrollToBottom,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPersonalitySelector(AIPracticeProvider aiProvider) {
    final personalities = [
      {
        'type': 'skeptic',
        'icon': Icons.psychology,
        'description': 'Questions beliefs and seeks evidence',
      },
      {
        'type': 'seeker',
        'icon': Icons.search,
        'description': 'Curious and open to exploring faith',
      },
      {
        'type': 'atheist',
        'icon': Icons.not_interested,
        'description': 'Does not believe in any deity',
      },
      {
        'type': 'religious',
        'icon': Icons.church,
        'description': 'Has strong religious convictions',
      },
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Your Conversation Partner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a personality type to practice your conversations',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width > 900 ? 4 : (width > 600 ? 3 : 2);
                final aspectRatio = width > 600 ? 1.1 : 0.85;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: aspectRatio,
                    crossAxisSpacing: width > 600 ? 16 : 12,
                    mainAxisSpacing: width > 600 ? 16 : 12,
                  ),
                  itemCount: personalities.length,
                  itemBuilder: (context, index) {
                    final personality = personalities[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () => aiProvider.startNewSession(personality['type'] as String),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                personality['icon'] as IconData,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                (personality['type'] as String).capitalize(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                personality['description'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEndChatDialog(AIPracticeProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'End Chat Session?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This will end your current chat session. You can start a new one with the same or different personality.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      aiProvider.endCurrentSession();
                      Navigator.pop(context);
                    },
                    child: const Text('End Chat'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionBank() {
    return Consumer<AIPracticeProvider>(
      builder: (context, aiProvider, child) {
        return Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search questions...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                onChanged: aiProvider.setSearchQuery,
              ),
            ),

            // Tags Scrolling Section
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: availableTags.length,
                itemBuilder: (context, index) {
                  final tag = availableTags[index];
                  final isSelected = aiProvider.selectedTags.contains(tag);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (_) => aiProvider.toggleTag(tag),
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  );
                },
              ),
            ),

            // Active Chat Banner
            if (aiProvider.currentSession != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Material(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => DefaultTabController.of(context).animateTo(0),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Active Conversation',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Chatting with ${aiProvider.currentSession!.personality.capitalize()}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Questions List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: aiProvider.questions.length,
                itemBuilder: (context, index) {
                  final question = aiProvider.questions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        title: Text(
                          question.question,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    question.answer,
                                    style: const TextStyle(height: 1.5),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: question.tags
                                      .map((tag) => Chip(
                                            label: Text(
                                              tag,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ))
                                      .toList(),
                                ),
                                if (aiProvider.currentSession != null) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add_comment, size: 20),
                                    label: const Text('Use in Current Chat'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      aiProvider.useQuestionInChat(question);
                                      DefaultTabController.of(context).animateTo(0);
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _sendMessage(AIPracticeProvider aiProvider) async {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    try {
      await aiProvider.sendMessage(
        userMessage,
        onMessageSent: () {
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                _scrollToBottom();
              }
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _saveMessageAsNote(String content) async {
    final note = Note(
      content: content,
      step: -1,
      timestamp: DateTime.now(),
    );

    try {
      await context.read<NotesProvider>().addNote(note);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                const SizedBox(width: 8),
                const Text('Saved to notes'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                const Text('Failed to save note'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

IconData _getPersonalityIcon(String personality) {
  switch (personality.toLowerCase()) {
    case 'skeptic':
      return Icons.psychology;
    case 'seeker':
      return Icons.search;
    case 'atheist':
      return Icons.not_interested;
    case 'religious':
      return Icons.church;
    default:
      return Icons.person;
  }
}

String _getPersonalityDescription(String personality) {
  switch (personality.toLowerCase()) {
    case 'skeptic':
      return 'A critical thinker who questions beliefs and seeks evidence before accepting claims.';
    case 'seeker':
      return 'An open-minded individual exploring faith and spiritual matters with genuine curiosity.';
    case 'atheist':
      return 'Someone who does not believe in the existence of a god or divine beings.';
    case 'religious':
      return 'A person with strong religious convictions and established faith beliefs.';
    default:
      return 'A conversation partner for faith discussions.';
  }
}

class DismissibleAnimation extends Animation<double> with AnimationLazyListenerMixin {
  final Key dismissibleKey;

  DismissibleAnimation(this.dismissibleKey);

  @override
  void addListener(VoidCallback listener) {}

  @override
  double get value => 0.0;

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void addStatusListener(AnimationStatusListener listener) {}

  @override
  void didStartListening() {}

  @override
  void didStopListening() {}

  @override
  void removeStatusListener(AnimationStatusListener listener) {}

  @override
  AnimationStatus get status => throw UnimplementedError();
}
