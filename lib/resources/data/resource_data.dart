import 'package:the_bridge_app/resources/models/resource.dart';

// How to read the Bible - https://youtu.be/plSNIwhAn5o?si=lMCEmyouNdXl1Bo_
// If You’re Struggling With What to Pray About, Watch This
//  - https://www.youtube.com/watch?v=3-YlqQfKkKk
// How Can You Know What’s Right? Here’s What Jesus Thought. - https://www.youtube.com/watch?v=KUil1m3P2iI
// The Gospel - https://youtu.be/xrzq_X1NNaA?si=3SdDIvqiaKCDkAQu

final List<Resource> resourceData = [
  Resource(
    id: 'v1',
    title: 'How to read the Bible',
    description: 'Learn how to read the Bible for yourself',
    type: ResourceType.video,
    url: 'https://youtu.be/plSNIwhAn5o?si=lMCEmyouNdXl1Bo_',
  ),
  Resource(
    id: 'v2',
    title: 'The Gospel',
    description: 'Learn the basics of the Christian faith',
    type: ResourceType.video,
    url: 'https://youtu.be/xrzq_X1NNaA?si=3SdDIvqiaKCDkAQu',
  ),
  Resource(
    id: 'v3',
    title: 'If You’re Struggling With What to Pray About, Watch This',
    description: 'Exploring the most well-known collection of Jesus’ teachings, the Sermon on the Mount',
    type: ResourceType.video,
    url: 'https://youtu.be/3-YlqQfKkKk?si=SGII-rGFYTgScV5m',
  ),
  Resource(
    id: 'sg1',
    title: 'Bridge Illustration Guide',
    description: 'Comprehensive PDF guide with scripture references and presentation tips',
    type: ResourceType.studyGuide,
    url: 'https://navigators.org/wp-content/uploads/2017/08/navtool-bridge.pdf',
  ),
  Resource(
    id: 'sg2',
    title: 'Training Workbook',
    description: 'Interactive workbook for practicing and memorizing the Bridge presentation',
    type: ResourceType.studyGuide,
    url: 'https://www.navigators.org/resource/the-bridge-to-life/',
  ),
];
