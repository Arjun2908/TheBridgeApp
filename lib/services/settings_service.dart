import 'package:hive/hive.dart';

class SettingsService {
  static const String darkModeKey = 'darkMode';
  static const String textSizeKey = 'textSize';
  static const String themeColorKey = 'themeColor';

  final Box settingsBox = Hive.box('settings');

  Future<void> saveSettings(bool darkMode, double textSize, String themeColor) async {
    await settingsBox.put(darkModeKey, darkMode);
    await settingsBox.put(textSizeKey, textSize);
    await settingsBox.put(themeColorKey, themeColor);
  }

  Map<String, dynamic> loadSettings() {
    return {
      darkModeKey: settingsBox.get(darkModeKey, defaultValue: false),
      textSizeKey: settingsBox.get(textSizeKey, defaultValue: 16.0),
      themeColorKey: settingsBox.get(themeColorKey, defaultValue: 'green'),
    };
  }

  Future<void> resetToDefault() async {
    await saveSettings(false, 16.0, 'green');
  }
}
