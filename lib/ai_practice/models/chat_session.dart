class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      content: map['content'],
      isUser: map['role'] == 'user',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() => {
        'role': isUser ? 'user' : 'assistant',
        'content': content,
        'timestamp': timestamp.toIso8601String(),
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

  Map<String, dynamic> toMap() {
    return {
      'personality': personality,
      'messages': messages.map((m) => m.toMap()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      personality: map['personality'],
      messages: (map['messages'] as List)
          .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>))
          .toList(),
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
    );
  }
}
