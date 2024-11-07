import '../models/question.dart';

final List<Question> questionData = [
  Question(
    id: 'q1',
    question: "How can you be sure God exists?",
    answer:
        "While we can't physically see God, we can observe His creation, moral law, and the historical evidence for Jesus. The complexity of the universe, our innate sense of right and wrong, and the historical reliability of the Bible all point to God's existence.",
    tags: ['foundations'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q2',
    question: "Why does God allow suffering?",
    answer:
        "Suffering entered the world through human free will and sin. God doesn't cause suffering but allows it while working to bring good from it. Jesus himself suffered to save us, showing God's love and understanding of our pain.",
    tags: ['suffering'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q3',
    question: "What about other religions?",
    answer:
        "While other religions contain some truth, Christianity uniquely claims salvation by grace through faith in Jesus Christ, not by works. Jesus claimed to be the only way to God, and His resurrection validates this claim.",
    tags: ['worldview'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q4',
    question: "How can a loving God send people to hell?",
    answer:
        "God doesn't 'send' people to hell; it's the natural consequence of rejecting His love and presence. Hell is essentially choosing to be separated from God. He respects our free will and doesn't force anyone to accept Him, though He deeply desires everyone to choose salvation.",
    tags: ['afterlife'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q5',
    question: "Hasn't science disproven God?",
    answer:
        "Science and faith aren't mutually exclusive. Science explains how the natural world works, while faith addresses why it exists. Many scientists throughout history were and are believers. The complexity and fine-tuning of the universe actually point many to God.",
    tags: ['science'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q6',
    question: "Why should I believe the Bible?",
    answer:
        "The Bible's historical reliability is supported by archaeology, manuscript evidence, and fulfilled prophecies. Its internal consistency despite multiple authors over centuries, its historical accuracy, and its profound impact on civilization make it uniquely trustworthy.",
    tags: ['bible'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q7',
    question: "What makes Christianity different from other religions?",
    answer:
        "Christianity uniquely offers salvation by grace through faith, not works. It's based on a historical event (Jesus's resurrection) and personal relationship with God, not just following rules. Jesus claimed to be God Himself, not just a prophet or teacher.",
    tags: ['foundations'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q8',
    question: "How can you believe in miracles in a scientific age?",
    answer:
        "Miracles aren't violations of natural law but interventions by a supernatural God who created those laws. If God exists and created the universe, He can certainly act within it. Historical evidence, especially for Jesus's resurrection, supports the reality of miracles.",
    tags: ['miracles', 'science'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q9',
    question: "Why does God seem hidden?",
    answer:
        "God has revealed Himself through creation, conscience, Scripture, and ultimately Jesus Christ. His partial hiddenness allows for genuine free will and faith. He's not hidden from those who genuinely seek Him, but He won't override our freedom to choose or reject Him.",
    tags: ['foundations'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q10',
    question: "How can Christianity be true if Christians have done bad things?",
    answer:
        "Christianity's truth isn't dependent on Christians' behavior. Jesus taught love and peace, while human failures reflect our imperfection, not Christianity's invalidity. Judge Christianity by Christ's teachings and character, not by imperfect followers.",
    tags: ['history'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q11',
    question: "What happens after death?",
    answer:
        "Christianity teaches that death isn't the end. Those who trust in Christ will experience eternal life in God's presence, while those who reject Him will experience separation from God. The resurrection of Jesus provides hope for our own resurrection.",
    tags: ['afterlife'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q12',
    question: "How can we trust the Gospel accounts of Jesus?",
    answer:
        "The Gospels were written within living memory of the events by eyewitnesses or their close associates. They show hallmarks of historical reliability: embarrassing details, multiple attestation, early dating, and archaeological confirmation. Their differences actually support their authenticity.",
    tags: ['bible', 'jesus'],
    createdAt: DateTime.now(),
  ),
  Question(
    id: 'q13',
    question: "Why does God allow natural disasters?",
    answer:
        "Natural disasters result from living in a fallen world where natural processes can have harmful effects. God often works through these events to bring about greater good, demonstrate our need for Him, and bring communities together in love and support.",
    tags: ['suffering'],
    createdAt: DateTime.now(),
  ),
];

const List<String> availableTags = [
  'foundations',
  'bible',
  'worldview',
  'suffering',
  'science',
  'afterlife',
  'history',
];
