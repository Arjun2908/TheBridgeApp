// providers/passage_provider.dart
import 'package:flutter/material.dart';
import '../models/passage.dart';
import '../services/api_service.dart';

class PassagesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Passage> _passages = [];
  bool _isLoading = false;

  PassagesProvider() {
    _initApiService();
  }

  Future<void> _initApiService() async {
    await _apiService.init();
  }

  List<Passage>? get passages => _passages;
  bool get isLoading => _isLoading;

  Future<void> fetchPassages(String passages) async {
    _isLoading = true;
    notifyListeners();

    _passages = await _apiService.fetchPassages(passages);
    _isLoading = false;
    notifyListeners();
  }
}
