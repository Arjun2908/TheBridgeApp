class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'role': isUser ? 'user' : 'assistant',
        'content': content,
      };
}

class ChatSession {
  final String personality;
  final List<ChatMessage> messages;
  final DateTime startTime;
  final DateTime? endTime;

  ChatSession({
    required this.personality,
    required this.messages,
    required this.startTime,
    this.endTime,
  });

  bool get isActive => endTime == null;
}
