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
  void startNewSession(String personality) {
    _currentSession = ChatSession(
      personality: personality,
      messages: [],
      startTime: DateTime.now(),
    );
    notifyListeners();
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

    _currentSession!.messages.add(ChatMessage(
      content: question.question,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _currentSession!.messages.add(ChatMessage(
      content: question.answer,
      isUser: false,
      timestamp: DateTime.now(),
    ));

    notifyListeners();
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
