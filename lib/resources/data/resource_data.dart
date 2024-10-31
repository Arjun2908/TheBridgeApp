import '../models/resource.dart';

final List<Resource> resourceData = [
  Resource(
    id: 'v1',
    title: 'The Bridge Illustration Overview',
    description: 'A comprehensive guide to presenting the bridge illustration effectively',
    type: ResourceType.video,
    url: 'https://www.youtube.com/watch?v=plSNIwhAn5o&list=PLH0Szn1yYNedn4FbBMMtOlGN-BPLQ54IH',
  ),
  Resource(
    id: 'v2',
    title: 'Advanced Bridge Presentation Techniques',
    description: 'Learn advanced techniques for sharing the gospel using the bridge illustration',
    type: ResourceType.video,
    url: 'https://www.youtube.com/watch?v=ak06MSETeo4&list=PLH0Szn1yYNedn4FbBMMtOlGN-BPLQ54IH&index=2',
  ),
  Resource(
    id: 'sg1',
    title: 'Bridge Method Study Guide',
    description: 'Detailed study guide with scripture references and presentation tips',
    type: ResourceType.studyGuide,
    url: 'https://example.com/bridge-study-guide.pdf',
  ),
  Resource(
    id: 'sg2',
    title: 'Training Manual',
    description: 'Complete training manual for the bridge illustration method',
    type: ResourceType.studyGuide,
    url: 'https://example.com/training-manual.pdf',
  ),
];
