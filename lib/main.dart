import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(int.parse(settingsProvider.themeColorHex.substring(1, 7), radix: 16) + 0xFF000000),
                brightness: settingsProvider.darkMode ? Brightness.dark : Brightness.light,
              ),
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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('The Bridge App')),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.5,
              child: isDarkMode
                  ? ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        -1, 0, 0, 0, 255, // Red
                        0, -1, 0, 0, 255, // Green
                        0, 0, -1, 0, 255, // Blue
                        0, 0, 0, 1, 0, // Alpha
                      ]),
                      child: Image.asset(
                        'assets/home.png',
                        fit: BoxFit.contain,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    )
                  : Image.asset(
                      'assets/home.png',
                      fit: BoxFit.contain,
                      height: double.infinity,
                      width: double.infinity,
                    ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 128),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(),
                    onPressed: () {
                      Navigator.pushNamed(context, '/video');
                    },
                    child: const Text('Video Tutorial'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/main');
                    },
                    child: const Text('Walkthough'),
                  ),
                ],
              ),
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
