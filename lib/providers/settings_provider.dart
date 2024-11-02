// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsProvider with ChangeNotifier {
  final Box _settingsBox = Hive.box('settings');

  bool get darkMode => _settingsBox.get('darkMode', defaultValue: false);
  bool get useSystemTheme => _settingsBox.get('useSystemTheme', defaultValue: true);
  double get textSize => _settingsBox.get('textSize', defaultValue: 16.0);
  String get themeColorHex => _settingsBox.get('themeColorHex', defaultValue: '#2196F3');

  Future<void> loadSettings() async {
    // No need to load explicitly with Hive as it's already persistent
    notifyListeners();
  }

  Future<void> setLightMode() async {
    await _settingsBox.put('darkMode', false);
    await _settingsBox.put('useSystemTheme', false);
    notifyListeners();
  }

  Future<void> setDarkMode() async {
    await _settingsBox.put('darkMode', true);
    await _settingsBox.put('useSystemTheme', false);
    notifyListeners();
  }

  Future<void> toggleSystemTheme() async {
    await _settingsBox.put('useSystemTheme', !useSystemTheme);
    notifyListeners();
  }

  Future<void> setTextSize(double size) async {
    await _settingsBox.put('textSize', size);
    notifyListeners();
  }

  Future<void> setThemeColor(String colorHex) async {
    await _settingsBox.put('themeColorHex', colorHex);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    await _settingsBox.clear();
    notifyListeners();
  }
}
