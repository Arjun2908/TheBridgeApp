class Step {
  final String videoPath; // Path to the video file for this step
  final List<String>? verses; // List of related verses for this step
  final String info; // Additional information for this step
  final String additionalText; // Additional text for this step
  final String additionalDialogMessage; // Dialog message for this step
  final String audioPath; // Path to the audio file for this step

  Step({
    required this.videoPath,
    required this.verses,
    required this.info,
    required this.additionalText,
    required this.additionalDialogMessage,
    required this.audioPath,
  });
}

// List of steps with durations, verses, and additional information
final List<Step> steps = [
  Step(
    videoPath: 'assets/video/output_video_1.mp4',
    verses: ["Ephesians 1:5", "Galatians 4:4-5"],
    info:
        "The Bible is the story about the family of God. God’s desire is for humans to be a part of his family and throughout the Bible we see how God interacts with humans and how humans interact with God.",
    additionalText: "Welcome",
    additionalDialogMessage:
        "The Bible is the story about the family of God. God’s desire is for humans to be a part of his family and throughout the Bible we see how God interacts with humans and how humans interact with God.",
    audioPath: 'audio/audio_step_1.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_2.mp4',
    verses: ["Isaiah 40:28", "Jeremiah 10:10"],
    info: "But who is God? ",
    additionalText: "God",
    additionalDialogMessage: "But who is God? ",
    audioPath: 'audio/audio_step_2.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_3.mp4',
    verses: ["Genesis 1:1", "Isaiah 45:12"],
    info:
        "The first thing we learn about God is that He is the creator of the universe. Everything in the heavens and on the earth. The plants, animals, stars, planets, and even humans are all a part of his grand creation.",
    additionalText: "Creator",
    additionalDialogMessage:
        "The first thing we learn about God is that He is the creator of the universe. Everything in the heavens and on the earth. The plants, animals, stars, planets, and even humans are all a part of his grand creation.",
    audioPath: 'audio/audio_step_3.mp3',
  ),
  // startFrom and endAt are duration + endAt of the previous step
  Step(
    videoPath: 'assets/video/output_video_4.mp4',
    verses: ["Matthew 6:26", "1 John 4:8"],
    info:
        "He created everything, but we also see that God cares intimately about his creation. He pays attention to things as seemingly insignificant as birds and flowers, but He has a special love for humans. The Bible even says that God is love.",
    additionalText: "Loving",
    additionalDialogMessage:
        "He created everything, but we also see that God cares intimately about his creation. He pays attention to things as seemingly insignificant as birds and flowers, but He has a special love for humans. The Bible even says that God is love.",
    audioPath: 'audio/audio_step_4.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_5.mp4',
    verses: ["Psalm 18:30", "Deuteronomy 32:4"],
    info:
        "As we look closer we see that not only is God loving, but He is perfect. His actions are always good, He never does evil. He is perfect in everything He does. He is perfectly loving; he is perfect in his understanding; and he is perfectly just.",
    additionalText: "Perfect",
    additionalDialogMessage:
        "As we look closer we see that not only is God loving, but He is perfect. His actions are always good, He never does evil. He is perfect in everything He does. He is perfectly loving; he is perfect in his understanding; and he is perfectly just.",
    audioPath: 'audio/audio_step_5.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_6.mp4',
    verses: ["Isaiah 33:22", "Psalm 9:7-8"],
    info: "As the creator of everything He has ultimate authority over his creation and His perfect justice dictates that evil deserves punishment and goodness deserves reward.",
    additionalText: "Just",
    additionalDialogMessage: "As the creator of everything He has ultimate authority over his creation and His perfect justice dictates that evil deserves punishment and goodness deserves reward.",
    audioPath: 'audio/audio_step_6.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_7.mp4',
    verses: ["Genesis 1:26-27", "Psalm 8:4-5"],
    info: "There are many other aspects of who God is, but let’s take a moment to look at humans.",
    additionalText: "People",
    additionalDialogMessage: "There are many other aspects of who God is, but let’s take a moment to look at humans.",
    audioPath: 'audio/audio_step_7.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_8.mp4',
    verses: ["Genesis 1:27", "Jeremiah 1:5"],
    info:
        "Humans are part of God’s creation. God created us uniquely, He created us in His image. We are eternal beings and we have free will. He gives us the opportunity to choose to be in his family or to say no to his invitation.",
    additionalText: "Created",
    additionalDialogMessage:
        "Humans are part of God’s creation. God created us uniquely, He created us in His image. We are eternal beings and we have free will. He gives us the opportunity to choose to be in his family or to say no to his invitation.",
    audioPath: 'audio/audio_step_8.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_9.mp4',
    verses: ["Philippians 2:3-4", "James 4:1-2"],
    info:
        "When we look at our lives we see ourselves as more important than others. We are selfish. We look out for number one. We might also want others to have a good life, but we are MUCH more concerned about ourselves.",
    additionalText: "Selfish",
    additionalDialogMessage:
        "When we look at our lives we see ourselves as more important than others. We are selfish. We look out for number one. We might also want others to have a good life, but we are MUCH more concerned about ourselves.",
    audioPath: 'audio/audio_step_9.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_10.mp4',
    verses: ["Romans 3:23", "Isaiah 64:6"],
    info: "We see that unlike God we are imperfect. We often do wrong and hurt others, and we even do things that hurt ourselves. We have the capacity to do good, but we are not perfect.",
    additionalText: "Imperfect",
    additionalDialogMessage:
        "We see that unlike God we are imperfect. We often do wrong and hurt others, and we even do things that hurt ourselves. We have the capacity to do good, but we are not perfect.",
    audioPath: 'audio/audio_step_10.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_11.mp4',
    verses: ["Proverbs 17:15", "Romans 2:1"],
    info:
        "And when we compare ourselves to God’s just nature we see that we are not just. When we do something wrong we want others to give us the benefit of the doubt, but when someone does something wrong against us or someone that we love we want them to be punished for their actions.",
    additionalText: "Not Just",
    additionalDialogMessage:
        "And when we compare ourselves to God’s just nature we see that we are not just. When we do something wrong we want others to give us the benefit of the doubt, but when someone does something wrong against us or someone that we love we want them to be punished for their actions.",
    audioPath: 'audio/audio_step_11.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_12.mp4',
    verses: ["1 John 1:8-10", "Romans 3:23"],
    info: "These imperfect, selfish, and unjust pieces of us are called sin.",
    additionalText: "Sin",
    additionalDialogMessage: "These imperfect, selfish, and unjust pieces of us are called sin.",
    audioPath: 'audio/audio_step_12.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_13.mp4',
    verses: ["Isaiah 59:2", "Romans 6:23"],
    info: "",
    additionalText: "Separation",
    additionalDialogMessage:
        "Because of sin there is separation from God and we are broken apart from his family. When we decide to sin we are telling God that we would rather be a part of the Family of Sin rather than the Family of God. \n\nAnd remember that God is a Just God. All evil has a just punishment. The Bible says that the just punishment for sin is death. Yes we will all die physically, but if we are not in God’s family when we physically die there is also a spiritual death. An eternity separated from God.",
    audioPath: 'audio/audio_step_13.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_14.mp4',
    verses: ["Romans 8:20-22", "Ecclesiastes 1:14"],
    info: ".",
    additionalText: "Brokenness",
    additionalDialogMessage:
        "As humans we can feel the brokenness of life. We see it all around us. We see the brokenness on a grand scale in governments and social injustices, but we can also see the brokenness of our friends and families and even in ourselves. \n\nMost people are asking the question, “How can the brokenness I see be fixed?” We long for a perfect, loving, and just world. We are longing for who God is.",
    audioPath: 'audio/audio_step_14.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_15.mp4',
    verses: ["Ephesians 2:8-9", "Titus 3:5"],
    info:
        "So we try to cross the separation that sin created. Some try really hard to be a good person. Some people try to follow a moral code. And some even try going to church and being religious hoping that will get them across the gap. Unfortunately none of these things even begin to address the separation. It is like you are trying to long jump across the Grand Canyon. If you tried with all your might you wouldn’t even begin to start crossing the gap. And the gap caused by sin is WAY wider than the width of the Grand Canyon",
    additionalText: "Works",
    additionalDialogMessage:
        "So we try to cross the separation that sin created. Some try really hard to be a good person. Some people try to follow a moral code. And some even try going to church and being religious hoping that will get them across the gap. Unfortunately none of these things even begin to address the separation. It is like you are trying to long jump across the Grand Canyon. If you tried with all your might you wouldn’t even begin to start crossing the gap. And the gap caused by sin is WAY wider than the width of the Grand Canyon",
    audioPath: 'audio/audio_step_15.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_16.mp4',
    verses: ["John 3:16", "Romans 5:8"],
    info: "",
    additionalText: "Cross",
    additionalDialogMessage:
        "This is a bleak scenario, but luckily the story doesn’t end there. \n\nGod’s desire is for us to be back in His family, but He knows that we aren’t able to make it back on our own. So we see his Perfect Love and his Perfect Justice combine in a grand plan to bring us back. His grand plan was to send Jesus, who is fully God to earth and become fully man. Jesus lived a perfect, loving, and just life. And then He died on a cross. He died to pay the punishment that we deserved. The just punishment for our sins was death, and Jesus died to pay for it. And then he rose from the dead to show that He is more powerful than death itself. He built a bridge so you could cross the gap.",
    audioPath: 'audio/audio_step_16.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_17.mp4',
    verses: ["Acts 16:31", "Romans 10:9-10"],
    info:
        "His desire is that everyone would use this bridge. That we would be in the Family of God, but He doesn’t force anyone to cross. He already paid the ultimate cost to buy your freedom and he is ready to adopt you back into his family. All you need to do is 1. trust that He died on the cross to pay the death you deserved and 2. turn away from the Family of Sin and walk into the Family of God.",
    additionalText: "Trust and Turn",
    additionalDialogMessage:
        "His desire is that everyone would use this bridge. That we would be in the Family of God, but He doesn’t force anyone to cross. He already paid the ultimate cost to buy your freedom and he is ready to adopt you back into his family. All you need to do is 1. trust that He died on the cross to pay the death you deserved and 2. turn away from the Family of Sin and walk into the Family of God.",
    audioPath: 'audio/audio_step_17.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_18.mp4',
    verses: ["1 Corinthians 3:16", "Romans 8:17"],
    info: "And when we accept this adoption miraculous things happen.",
    additionalText: "God's Gift",
    additionalDialogMessage: """And when we accept this adoption miraculous things happen! God now dwells inside us, the Holy Spirit\n
    We are called Children of God and co-heirs of the kingdom with Jesus\n
    God gives us eternal life. When we die we will be with Him in heaven\n
    God says that when he looks at us He no longer sees our sin but sees Jesus’ perfection
    """,
    audioPath: 'audio/audio_step_18.mp3',
  ),
  Step(
    videoPath: 'assets/video/output_video_19.mp4',
    verses: ["1 John 3:1", "John 1:12-13"],
    info: """There are 3 types of people in the world.\n
People who don’t really care about the brokenness of the world\n
People who are asking the question How do I deal with the brokenness of the world? And exploring to see if Jesus is the answer.\n
People who have accepted God’s invitation to be adopted back into His family.\n

Which of these people describe you?
""",
    additionalText: "You",
    additionalDialogMessage: """There are 3 types of people in the world.\n
People who don’t really care about the brokenness of the world\n
People who are asking the question How do I deal with the brokenness of the world? And exploring to see if Jesus is the answer.\n
People who have accepted God’s invitation to be adopted back into His family.\n

Which of these people describe you?
""",
    audioPath: 'audio/audio_step_19.mp3',
  ),
];
