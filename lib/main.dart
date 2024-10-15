import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:the_bridge_app/providers/feedback_provider.dart';
import 'package:the_bridge_app/providers/passage_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:the_bridge_app/providers/settings_provider.dart';

import 'package:the_bridge_app/settings-page.dart/settings_page.dart';
import 'package:the_bridge_app/about-page/about_page.dart';
import 'package:the_bridge_app/video-player/animation_page.dart';
import 'package:the_bridge_app/video/video_page.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await dotenv.load(fileName: ".env");

  // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]).then((value) => runApp(const MyApp()));
  runApp(const MyApp());
}

// Helper function to map color names to Color objects
Color getColorFromName(String colorName) {
  // 'blue', 'green', 'red', 'purple', 'orange'
  switch (colorName.toLowerCase()) {
    case 'green':
      return Colors.green;
    case 'blue':
      return Colors.blue;
    case 'red':
      return Colors.red;
    case 'purple':
      return Colors.purple;
    case 'orange':
      return Colors.orange;
    default:
      return Colors.green;
  }
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
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Bridge Diagram Tutorial',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: getColorFromName(settingsProvider.themeColor), brightness: settingsProvider.darkMode ? Brightness.dark : Brightness.light),
              textTheme: TextTheme(
                displayLarge: TextStyle(fontSize: settingsProvider.textSize + 4),
                displayMedium: TextStyle(fontSize: settingsProvider.textSize),
                displaySmall: TextStyle(fontSize: settingsProvider.textSize - 4),
                headlineLarge: TextStyle(fontSize: settingsProvider.textSize + 2),
                headlineMedium: TextStyle(fontSize: settingsProvider.textSize),
                headlineSmall: TextStyle(fontSize: settingsProvider.textSize - 2),
                titleLarge: TextStyle(fontSize: settingsProvider.textSize + 2),
                titleMedium: TextStyle(fontSize: settingsProvider.textSize),
                titleSmall: TextStyle(fontSize: settingsProvider.textSize - 2),
                bodyLarge: TextStyle(fontSize: settingsProvider.textSize + 2),
                bodyMedium: TextStyle(fontSize: settingsProvider.textSize),
                bodySmall: TextStyle(fontSize: settingsProvider.textSize - 2),
                labelLarge: TextStyle(fontSize: settingsProvider.textSize + 2),
                labelMedium: TextStyle(fontSize: settingsProvider.textSize),
                labelSmall: TextStyle(fontSize: settingsProvider.textSize - 2),
              ),
              useMaterial3: true,
            ),
            home: const HomePage(),
            routes: {
              '/main': (context) => const AnimationPage(),
              '/video': (context) => const VideoPage(),
              '/settings': (context) => const SettingsPage(),
              '/about': (context) => const AboutPage(),
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box settingsBox;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bridge Diagram Tutorial')),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/video');
                  },
                  child: const Text('Video Tutorial'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/main');
                  },
                  child: const Text('Walkthough'),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: IconButton(
              iconSize: 35,
              padding: const EdgeInsets.all(30),
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              iconSize: 35,
              padding: const EdgeInsets.all(30),
              icon: const Icon(Icons.info),
              onPressed: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
          ),
        ],
      ),
    );
  }
}
