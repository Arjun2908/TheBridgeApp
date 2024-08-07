class Settings {
  bool darkMode;
  TextSizeOptions textSize;

  Settings({
    required this.darkMode,
    required this.textSize,
  });
}

enum TextSizeOptions {
  small,
  medium,
  large,
}
