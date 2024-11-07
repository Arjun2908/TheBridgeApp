class Question {
  final String id;
  final String question;
  final String answer;
  final List<String> tags;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.question,
    required this.answer,
    required this.tags,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
      tags: List<String>.from(map['tags']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
