import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../data/resource_data.dart';

class ResourceProvider with ChangeNotifier {
  List<Resource> getResourcesByType(ResourceType type) {
    return resourceData.where((resource) => resource.type == type).toList();
  }

  List<Resource> get videos => getResourcesByType(ResourceType.video);
  List<Resource> get studyGuides => getResourcesByType(ResourceType.studyGuide);
}
