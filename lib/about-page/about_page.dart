import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/feedback_page.dart';
import 'package:the_bridge_app/providers/settings_provider.dart';

// our medium text on this page is 24, 20, and 16. The large text is 32, 28, and 24. The small text is 16, 12, and 8.

double getHeaderTextSize(double textSize) {
  if (textSize == 12.0) {
    return 16;
  } else if (textSize == 16.0) {
    return 24;
  } else if (textSize == 20.0) {
    return 32;
  } else {
    return 24;
  }
}

double getTitleTextSize(double textSize) {
  if (textSize == 12.0) {
    return 12;
  } else if (textSize == 16.0) {
    return 20;
  } else if (textSize == 20.0) {
    return 28;
  } else {
    return 20;
  }
}

double getBodyTextSize(double textSize) {
  if (textSize == 12.0) {
    return 8;
  } else if (textSize == 16.0) {
    return 16;
  } else if (textSize == 20.0) {
    return 24;
  } else {
    return 16;
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (context, settingsProvider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('About'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About The Bridge App',
                  style: TextStyle(fontSize: getHeaderTextSize(settingsProvider.textSize), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'The Bridge App is designed to help Christians share the gospel with others. It provides a visual tool to help explain the gospel message in a clear and engaging way.',
                  style: TextStyle(fontSize: getBodyTextSize(settingsProvider.textSize)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Features:',
                  style: TextStyle(fontSize: getTitleTextSize(settingsProvider.textSize), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '- Interactive video tutorial (coming soon)\n'
                  '- Step-by-step walkthroughs\n'
                  '- Drawing canvas for annotations (coming soon) \n'
                  '- Export and share features',
                  style: TextStyle(fontSize: getBodyTextSize(settingsProvider.textSize)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Team:',
                  style: TextStyle(fontSize: getTitleTextSize(settingsProvider.textSize), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our team is composed of people who are passionate about sharing the gospel of Jesus and equipping others to do the same. We are committed to creating tools that are both effective and easy to use.',
                  style: TextStyle(fontSize: getBodyTextSize(settingsProvider.textSize)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Team Members:',
                  style: TextStyle(fontSize: getBodyTextSize(settingsProvider.textSize), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '- Arjun Gupta: Developer\n'
                  '- Bradley Hicks: Script and Content Creator\n'
                  '- Rachel Hicks: Graphics designer',
                  style: TextStyle(fontSize: getBodyTextSize(settingsProvider.textSize)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Contact Us:',
                  style: TextStyle(fontSize: getTitleTextSize(settingsProvider.textSize), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text:
                        'We want to keep making improvements to the app and make it a reliable tool of God to reach people all over the world, and we are super eager for any feedback and improvements we can make to reach our goal. If you have any questions or feedback, feel free to reach out to us at support@arjungupta.dev, or fill out our ',
                    style: TextStyle(fontSize: getBodyTextSize(settingsProvider.textSize), color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'feedback form',
                        style: TextStyle(fontSize: getBodyTextSize(settingsProvider.textSize), color: Colors.blue, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FeedbackPage()),
                            );
                          },
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(fontSize: getBodyTextSize(settingsProvider.textSize), color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
