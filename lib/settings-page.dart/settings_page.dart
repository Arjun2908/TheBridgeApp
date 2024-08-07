import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/feedback_page.dart';
import '../providers/settings_provider.dart';

double getTextSize(String textSize) {
  switch (textSize) {
    case 'Small':
      return 12.0;
    case 'Medium':
      return 16.0;
    case 'Large':
      return 20.0;
    default:
      return 16.0;
  }
}

String getTextSizeString(double textSize) {
  if (textSize == 12.0) {
    return 'Small';
  } else if (textSize == 16.0) {
    return 'Medium';
  } else if (textSize == 20.0) {
    return 'Large';
  } else {
    return 'Medium';
  }
}

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
                        settingsProvider.updateSettings(value, settingsProvider.textSize, settingsProvider.themeColor);
                      },
                    ),
                    ListTile(
                      title: const Text('Text Size'),
                      trailing: DropdownButton<String>(
                        value: getTextSizeString(settingsProvider.textSize),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            settingsProvider.updateSettings(settingsProvider.darkMode, getTextSize(newValue), settingsProvider.themeColor);
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
                      trailing: DropdownButton<String>(
                        value: settingsProvider.themeColor,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            settingsProvider.updateSettings(settingsProvider.darkMode, settingsProvider.textSize, newValue);
                          }
                        },
                        items: <String>['blue', 'green', 'red', 'purple', 'orange'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
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
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: const Text('Reset to Default'),
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
