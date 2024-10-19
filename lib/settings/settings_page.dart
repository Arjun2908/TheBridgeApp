// lib/settings-page.dart/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: settingsProvider.darkMode,
                      onChanged: (bool value) {
                        settingsProvider.updateSettings(value, settingsProvider.textSize, settingsProvider.themeColorHex);
                      },
                    ),
                    ListTile(
                      title: const Text('Text Size'),
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
                    ListTile(
                      title: const Text('Theme Color'),
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
                    ListTile(
                      title: const Text('Feedback and Support'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const FeedbackPage(),
                        ));
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListTile(
                  title: const Text('Reset to defaults'),
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
