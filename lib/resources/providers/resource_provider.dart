import 'package:flutter/material.dart';

import 'package:the_bridge_app/resources/models/resource.dart';
import 'package:the_bridge_app/resources/data/resource_data.dart';

class ResourceProvider with ChangeNotifier {
  List<Resource> getResourcesByType(ResourceType type) {
    return resourceData.where((resource) => resource.type == type).toList();
  }

  List<Resource> get videos => getResourcesByType(ResourceType.video);
  List<Resource> get studyGuides => getResourcesByType(ResourceType.studyGuide);
}
