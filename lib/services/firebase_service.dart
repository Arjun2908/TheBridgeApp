import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_bridge_app/resources/models/resource.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Resource>> getResources() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('resources').orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Resource(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          type: _parseResourceType(data['type'] ?? ''),
          url: data['url'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching resources: $e');
      return [];
    }
  }

  ResourceType _parseResourceType(String type) {
    switch (type) {
      case 'video':
        return ResourceType.video;
      case 'studyGuide':
        return ResourceType.studyGuide;
      default:
        return ResourceType.video;
    }
  }
}
