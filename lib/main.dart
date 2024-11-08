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
import 'package:the_bridge_app/resources/providers/resource_provider.dart';
import 'package:the_bridge_app/services/api_service.dart';

import 'package:the_bridge_app/settings/settings_page.dart';
import 'package:the_bridge_app/video-player/animation_page.dart';
import 'package:the_bridge_app/home/home_page.dart';
import 'package:the_bridge_app/resources/pages/resource_library_page.dart';
import 'package:the_bridge_app/ai_practice/ai_practice_page.dart';
import 'package:the_bridge_app/ai_practice/providers/ai_practice_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'models/passage.dart';
import 'models/cached_passage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await Hive.openBox('settings');
  await dotenv.load(fileName: ".env");

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(PassageAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(CachedPassageAdapter());
  }

  // Initialize ApiService
  final apiService = ApiService();
  await apiService.init();

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
        ChangeNotifierProvider(create: (_) => ResourceProvider()),
        ChangeNotifierProvider(create: (_) => AIPracticeProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            builder: FToastBuilder(),
            title: 'Bridge Diagram Tutorial',
            debugShowCheckedModeBanner: false,
            themeMode: settingsProvider.useSystemTheme
                ? ThemeMode.system
                : settingsProvider.darkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(int.parse(settingsProvider.themeColorHex.substring(1, 7), radix: 16) + 0xFF000000),
              ),
              textTheme: buildTextTheme(settingsProvider.textSize),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(int.parse(settingsProvider.themeColorHex.substring(1, 7), radix: 16) + 0xFF000000),
                brightness: Brightness.dark,
              ),
              textTheme: buildTextTheme(settingsProvider.textSize),
              useMaterial3: true,
            ),
            home: const HomePage(),
            routes: {
              '/main': (context) => const AnimationPage(),
              '/settings': (context) => const SettingsPage(),
              '/notes': (context) => const NotesPage(),
              '/resources': (context) => const ResourceLibraryPage(),
              '/ai_practice': (context) => const AIPracticePage(),
            },
          );
        },
      ),
    );
  }
}
