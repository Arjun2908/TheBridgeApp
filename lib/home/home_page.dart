import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
