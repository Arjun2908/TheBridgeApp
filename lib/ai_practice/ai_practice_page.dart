import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bottom_nav_bar.dart';
import '../global_helpers.dart';
import 'providers/ai_practice_provider.dart';
import 'data/question_data.dart';
import 'widgets/onboarding_modal.dart';
import '../widgets/common_app_bar.dart';

class AIPracticePage extends StatefulWidget {
  const AIPracticePage({super.key});

  @override
  State<AIPracticePage> createState() => _AIPracticePageState();
}

class _AIPracticePageState extends State<AIPracticePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowOnboarding();
    });
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
          title: 'AI Practice',
          additionalActions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
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
              Tab(text: 'Practice Mode'),
              Tab(text: 'Question Bank'),
            ],
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
        if (aiProvider.currentSession == null) {
          return _buildPersonalitySelector(aiProvider);
        }
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Talking to: ${aiProvider.currentSession!.personality.capitalize()}'),
                  TextButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text('End Chat'),
                    onPressed: () => _showEndChatDialog(aiProvider),
                  ),
                ],
              ),
            ),
            if (aiProvider.lastSession != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Text('Last chat: ${aiProvider.lastSession!.personality.capitalize()} - ${aiProvider.lastSession!.messages.length} messages'),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: aiProvider.currentSession!.messages.length,
                itemBuilder: (context, index) {
                  final message = aiProvider.currentSession!.messages[index];
                  return ListTile(
                    leading: Icon(
                      message.isUser ? Icons.person : Icons.computer,
                    ),
                    title: Text(message.content),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendMessage(aiProvider),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPersonalitySelector(AIPracticeProvider aiProvider) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a personality to start chatting',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['skeptic', 'seeker', 'atheist', 'religious'].map((personality) {
                  return ElevatedButton(
                    onPressed: () => aiProvider.startNewSession(personality),
                    child: Text(personality.capitalize()),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEndChatDialog(AIPracticeProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Chat Session?'),
        content: const Text('This will end your current chat session. You can start a new one with the same or different personality.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              aiProvider.endCurrentSession();
              Navigator.pop(context);
            },
            child: const Text('End Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBank() {
    return Consumer<AIPracticeProvider>(
      builder: (context, aiProvider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search questions...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: aiProvider.setSearchQuery,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: availableTags.map((tag) {
                    bool isSelected = aiProvider.selectedTags.contains(tag);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (_) => aiProvider.toggleTag(tag),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (aiProvider.currentSession != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Row(
                  children: [
                    const Icon(Icons.chat),
                    const SizedBox(width: 8),
                    Text('Active chat with: ${aiProvider.currentSession!.personality.capitalize()}'),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: aiProvider.questions.length,
                itemBuilder: (context, index) {
                  final question = aiProvider.questions[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: Text(
                        question.question,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(question.answer),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: question.tags.map((tag) => Chip(label: Text(tag))).toList(),
                              ),
                              if (aiProvider.currentSession != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.add_comment),
                                    label: const Text('Use in Current Chat'),
                                    onPressed: () {
                                      aiProvider.useQuestionInChat(question);
                                      DefaultTabController.of(context).animateTo(0); // Switch to chat tab
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
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
    setState(() {
      _chatHistory.add({
        'type': 'user',
        'message': userMessage,
      });
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await aiProvider.sendMessage(userMessage);
      setState(() {
        _chatHistory.add({
          'type': 'ai',
          'message': response,
        });
      });
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
