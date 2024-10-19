import 'package:flutter/material.dart';

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
