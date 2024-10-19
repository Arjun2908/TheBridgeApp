// lib/services/settings_service.dart
import 'package:hive/hive.dart';

class SettingsService {
  static const String darkModeKey = 'darkMode';
  static const String textSizeKey = 'textSize';
  static const String themeColorHexKey = 'themeColorHex';
  final Box settingsBox = Hive.box('settings');

  Future<void> saveSettings(bool darkMode, double textSize, String themeColorHex) async {
    await settingsBox.put(darkModeKey, darkMode);
    await settingsBox.put(textSizeKey, textSize);
    await settingsBox.put(themeColorHexKey, themeColorHex);
  }

  Map<String, dynamic> loadSettings() {
    return {
      darkModeKey: settingsBox.get(darkModeKey, defaultValue: false),
      textSizeKey: settingsBox.get(textSizeKey, defaultValue: 16.0),
      themeColorHexKey: settingsBox.get(themeColorHexKey, defaultValue: '#00FF00'),
    };
  }

  Future<void> resetToDefault() async {
    await saveSettings(false, 16.0, '#00FF00');
  }
}
