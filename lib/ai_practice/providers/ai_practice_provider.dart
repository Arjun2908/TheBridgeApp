import 'package:flutter/material.dart';
import 'package:the_bridge_app/ai_practice/models/chat_session.dart';
import 'package:the_bridge_app/ai_practice/services/openai_service.dart';
import 'package:the_bridge_app/ai_practice/models/question.dart';
import 'package:the_bridge_app/ai_practice/data/question_data.dart';

class AIPracticeProvider with ChangeNotifier {
  final OpenAIService _openAIService = OpenAIService();
  ChatSession? _currentSession;
  ChatSession? _lastSession;
  final List<Question> _questions = questionData;
  List<Question> _filteredQuestions = questionData;
  final Set<String> _selectedTags = {};
  String _searchQuery = '';
  bool _isLoading = false;

  // Chat Session getters
  ChatSession? get currentSession => _currentSession;
  ChatSession? get lastSession => _lastSession;
  bool get isLoading => _isLoading;

  // Question Bank getters
  List<Question> get questions => _filteredQuestions;
  Set<String> get selectedTags => _selectedTags;
  String get searchQuery => _searchQuery;

  // Chat Session methods
  Future<void> startNewSession(String personality) async {
    _isLoading = true;
    _currentSession = ChatSession(
      personality: personality,
      messages: [],
      startTime: DateTime.now(),
    );
    notifyListeners();

    // Create initial message based on personality
    String initialPrompt;
    switch (personality.toLowerCase()) {
      case 'skeptic':
        initialPrompt = "I've always found religious claims hard to believe without concrete evidence. What makes you so sure Christianity is true?";
        break;
      case 'seeker':
        initialPrompt = "I've been thinking a lot about spiritual things lately. What drew you to Christianity?";
        break;
      case 'atheist':
        initialPrompt = "I don't believe in any gods or supernatural things. It's all just myths and stories to me. Why do you believe?";
        break;
      case 'religious':
        initialPrompt = "I follow a different faith tradition, but I'm curious about Christianity. What makes it different from other religions?";
        break;
      default:
        initialPrompt = "Hi, I'm interested in hearing about your faith. Can you tell me more?";
    }

    try {
      _currentSession!.messages.add(ChatMessage(
        content: initialPrompt,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> endCurrentSession() async {
    if (_currentSession != null) {
      final endedSession = ChatSession(
        personality: _currentSession!.personality,
        messages: _currentSession!.messages,
        startTime: _currentSession!.startTime,
        endTime: DateTime.now(),
      );
      _lastSession = endedSession;
      _currentSession = null;
      notifyListeners();
    }
  }

  Future<void> useQuestionInChat(Question question) async {
    if (_currentSession == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentSession!.messages.add(ChatMessage(
        content: question.answer,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      notifyListeners();

      final response = await _openAIService.getChatResponse(
        _currentSession!.messages.map((m) => m.toMap()).toList(),
        _currentSession!.personality,
      );

      _currentSession!.messages.add(ChatMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Question Bank methods
  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    _filterQuestions();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterQuestions();
    notifyListeners();
  }

  void _filterQuestions() {
    _filteredQuestions = _questions.where((question) {
      bool matchesSearch = question.question.toLowerCase().contains(_searchQuery.toLowerCase()) || question.answer.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesTags = _selectedTags.isEmpty || question.tags.any((tag) => _selectedTags.contains(tag));

      return matchesSearch && matchesTags;
    }).toList();
  }

  Future<String> sendMessage(String message) async {
    if (_currentSession == null) return '';
    _isLoading = true;
    notifyListeners();

    try {
      _currentSession!.messages.add(ChatMessage(
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      notifyListeners();

      final response = await _openAIService.getChatResponse(
        _currentSession!.messages.map((m) => m.toMap()).toList(),
        _currentSession!.personality,
      );

      _currentSession!.messages.add(ChatMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
