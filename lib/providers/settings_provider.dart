import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  bool _darkMode = false;
  double _textSize = 16.0;
  String _themeColor = 'green';

  bool get darkMode => _darkMode;
  double get textSize => _textSize;
  String get themeColor => _themeColor;

  void loadSettings() {
    final settings = _settingsService.loadSettings();
    _darkMode = settings[SettingsService.darkModeKey];
    _textSize = settings[SettingsService.textSizeKey];
    _themeColor = settings[SettingsService.themeColorKey];
    notifyListeners();
  }

  Future<void> updateSettings(bool darkMode, double textSize, String themeColor) async {
    _darkMode = darkMode;
    _textSize = textSize;
    _themeColor = themeColor;
    await _settingsService.saveSettings(darkMode, textSize, themeColor);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    await _settingsService.resetToDefault();
    loadSettings();
  }
}
