import 'package:the_bridge_app/resources/models/resource.dart';

final List<Resource> resourceData = [
  Resource(
    id: 'v1',
    title: 'The Bridge Illustration Training',
    description: 'Learn how to effectively share the gospel using the Bridge Illustration method',
    type: ResourceType.video,
    url: 'https://www.youtube.com/watch?v=yv7KJQHWcqo',
  ),
  Resource(
    id: 'v2',
    title: 'Navigators Bridge Illustration',
    description: 'The classic Bridge presentation by the Navigators ministry',
    type: ResourceType.video,
    url: 'https://www.youtube.com/watch?v=_Yf7VUo8YyY',
  ),
  Resource(
    id: 'v3',
    title: 'Practice Presentation Example',
    description: 'Watch a real-world example of sharing the Bridge Illustration',
    type: ResourceType.video,
    url: 'https://www.youtube.com/watch?v=vZkYxwZMRUk',
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
  Resource(
    id: 'sg3',
    title: 'Scripture Reference Sheet',
    description: 'Quick reference guide for all Bible verses used in the Bridge Illustration',
    type: ResourceType.studyGuide,
    url: 'https://www.navigators.org/resource/bridge-illustration/',
  ),
];
