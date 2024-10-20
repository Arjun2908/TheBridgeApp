import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/global_helpers.dart';
import 'package:the_bridge_app/notes/notes_page.dart';

import 'package:the_bridge_app/providers/feedback_provider.dart';
import 'package:the_bridge_app/providers/notes_provider.dart';
import 'package:the_bridge_app/providers/passage_provider.dart';
import 'package:the_bridge_app/providers/settings_provider.dart';

import 'package:the_bridge_app/settings/settings_page.dart';
import 'package:the_bridge_app/about/about_page.dart';
import 'package:the_bridge_app/video-player/animation_page.dart';
import 'package:the_bridge_app/video/video_page.dart';
import 'package:the_bridge_app/home/home_page.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PassagesProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            builder: FToastBuilder(),
            title: 'Bridge Diagram Tutorial',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(int.parse(settingsProvider.themeColorHex.substring(1, 7), radix: 16) + 0xFF000000),
                brightness: settingsProvider.darkMode ? Brightness.dark : Brightness.light,
              ),
              textTheme: buildTextTheme(settingsProvider.textSize),
              useMaterial3: true,
            ),
            home: const HomePage(),
            routes: {
              '/main': (context) => const AnimationPage(),
              '/video': (context) => const VideoPage(),
              '/settings': (context) => const SettingsPage(),
              '/about': (context) => const AboutPage(),
              '/notes': (context) => const NotesPage(),
            },
          );
        },
      ),
    );
  }
}
