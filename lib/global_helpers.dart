import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:the_bridge_app/home/home_page.dart';
import 'package:the_bridge_app/notes/notes_page.dart';
import 'package:the_bridge_app/resources/pages/resource_library_page.dart';
import 'package:the_bridge_app/settings/settings_page.dart';

TextTheme buildTextTheme(double textSize) {
  return TextTheme(
    displayLarge: TextStyle(fontSize: textSize + 4),
    displayMedium: TextStyle(fontSize: textSize),
    displaySmall: TextStyle(fontSize: textSize - 4),
    headlineLarge: TextStyle(fontSize: textSize + 2),
    headlineMedium: TextStyle(fontSize: textSize),
    headlineSmall: TextStyle(fontSize: textSize - 2),
    titleLarge: TextStyle(fontSize: textSize + 2),
    titleMedium: TextStyle(fontSize: textSize),
    titleSmall: TextStyle(fontSize: textSize - 2),
    bodyLarge: TextStyle(fontSize: textSize + 2),
    bodyMedium: TextStyle(fontSize: textSize),
    bodySmall: TextStyle(fontSize: textSize - 2),
    labelLarge: TextStyle(fontSize: textSize + 2),
    labelMedium: TextStyle(fontSize: textSize),
    labelSmall: TextStyle(fontSize: textSize - 2),
  );
}

String formatTimestamp(DateTime dateTime) {
  // Format the DateTime object to a human-readable string
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

  return formattedDate;
}

// Navigation functionality
void onItemTapped(int index, BuildContext context) {
  Widget page;
  switch (index) {
    case 0:
      page = const HomePage();
      break;
    case 1:
      page = const NotesPage();
      break;
    case 2:
      page = const SettingsPage();
      break;
    case 3:
      page = const ResourceLibraryPage();
      break;
    case 4:
      Navigator.pushNamed(context, '/video');
      return;
    case 5:
      Navigator.pushNamed(context, '/main');
      return;
    default:
      return;
  }

  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}
