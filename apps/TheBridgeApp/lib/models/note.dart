class Note {
  int? id;
  String content;
  int step;
  DateTime timestamp;

  Note({
    this.id,
    required this.content,
    required this.step,
    required this.timestamp,
  });

  // Convert a Note object into a map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'step': step,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Convert a map into a Note object.
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      content: map['content'],
      step: map['step'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
