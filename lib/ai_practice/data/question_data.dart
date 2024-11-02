import '../models/question.dart';

final List<Question> questionData = [
  Question(
    id: 'q1',
    question: "How can you be sure God exists?",
    answer:
        "While we can't physically see God, we can observe His creation, moral law, and the historical evidence for Jesus. The complexity of the universe, our innate sense of right and wrong, and the historical reliability of the Bible all point to God's existence.",
    tags: ['existence', 'apologetics', 'basic'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q2',
    question: "Why does God allow suffering?",
    answer:
        "Suffering entered the world through human free will and sin. God doesn't cause suffering but allows it while working to bring good from it. Jesus himself suffered to save us, showing God's love and understanding of our pain.",
    tags: ['suffering', 'apologetics', 'common'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q3',
    question: "What about other religions?",
    answer:
        "While other religions contain some truth, Christianity uniquely claims salvation by grace through faith in Jesus Christ, not by works. Jesus claimed to be the only way to God, and His resurrection validates this claim.",
    tags: ['religions', 'apologetics', 'advanced'],
    createdAt: DateTime.now(),
  ),
  // Add more questions as needed
];

const List<String> availableTags = [
  'existence',
  'suffering',
  'religions',
  'apologetics',
  'basic',
  'common',
  'advanced',
];
