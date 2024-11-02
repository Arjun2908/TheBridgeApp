// lib/settings-page.dart/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/about/about_page.dart';
import 'package:the_bridge_app/feedback_page.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:the_bridge_app/providers/settings_provider.dart';
import 'package:the_bridge_app/settings/helpers.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Settings Cards
              Card(
                elevation: 3,
                child: ListTile(
                  title: const Text('About The Bridge App'),
                  leading: const Icon(Icons.info_outline),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AboutPage(),
                    ));
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: SwitchListTile(
                  title: const Text('Dark Mode'),
                  secondary: const Icon(Icons.dark_mode),
                  value: settingsProvider.darkMode,
                  onChanged: (bool value) {
                    settingsProvider.updateSettings(value, settingsProvider.textSize, settingsProvider.themeColorHex);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: const Text('Text Size'),
                  leading: const Icon(Icons.text_fields),
                  trailing: DropdownButton<String>(
                    value: getTextSizeString(settingsProvider.textSize),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        settingsProvider.updateSettings(settingsProvider.darkMode, getTextSize(newValue), settingsProvider.themeColorHex);
                      }
                    },
                    items: <String>['Small', 'Medium', 'Large'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: const Text('Theme Color'),
                  leading: const Icon(Icons.color_lens),
                  trailing: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Pick a color'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: Color(int.parse(settingsProvider.themeColorHex.substring(1, 7), radix: 16) + 0xFF000000),
                                onColorChanged: (Color color) {
                                  settingsProvider.updateSettings(
                                    settingsProvider.darkMode,
                                    settingsProvider.textSize,
                                    '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                                  );
                                },
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Got it'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(int.parse(settingsProvider.themeColorHex.substring(1, 7), radix: 16) + 0xFF000000),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: const Text('Feedback and Support'),
                  leading: const Icon(Icons.feedback),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const FeedbackPage(),
                    ));
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: const Text('Reset to defaults'),
                  leading: const Icon(Icons.restore),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Reset to Default'),
                          content: const Text('Are you sure you want to reset to default settings?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                settingsProvider.resetSettings();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Reset'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
