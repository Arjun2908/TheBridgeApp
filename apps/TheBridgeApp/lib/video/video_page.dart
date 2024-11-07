import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/providers/settings_provider.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (context, settingsProvider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Video Page'),
        ),
        body: const Center(
          child: Text(
            'Coming soon...',
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    });
  }
}
