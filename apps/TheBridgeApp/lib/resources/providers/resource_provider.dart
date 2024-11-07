import 'package:flutter/material.dart';
import 'package:the_bridge_app/resources/models/resource.dart';
import 'package:the_bridge_app/services/firebase_service.dart';

class ResourceProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Resource> _resources = [];
  bool _isLoading = false;

  List<Resource> get videos => _resources
      .where((resource) => resource.type == ResourceType.video)
      .toList();

  List<Resource> get studyGuides => _resources
      .where((resource) => resource.type == ResourceType.studyGuide)
      .toList();

  bool get isLoading => _isLoading;

  Future<void> fetchResources() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _resources = await _firebaseService.getResources();
    } catch (e) {
      print('Error in ResourceProvider: $e');
      _resources = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
