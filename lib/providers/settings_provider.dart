// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  bool _darkMode = false;
  double _textSize = 16.0;
  String _themeColorHex = '#FFFFFF'; // Default to green

  bool get darkMode => _darkMode;
  double get textSize => _textSize;
  String get themeColorHex => _themeColorHex;

  void loadSettings() {
    final settings = _settingsService.loadSettings();
    _darkMode = settings[SettingsService.darkModeKey];
    _textSize = settings[SettingsService.textSizeKey];
    _themeColorHex = settings[SettingsService.themeColorHexKey];
    notifyListeners();
  }

  Future<void> updateSettings(bool darkMode, double textSize, String themeColorHex) async {
    _darkMode = darkMode;
    _textSize = textSize;
    _themeColorHex = themeColorHex;
    await _settingsService.saveSettings(darkMode, textSize, themeColorHex);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    await _settingsService.resetToDefault();
    loadSettings();
  }
}
