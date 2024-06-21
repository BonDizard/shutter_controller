import 'package:flutter/material.dart';

class UiProvider {
  static final darkTheme = ThemeData(
    primaryColor: Colors.black12,
    brightness: Brightness.dark,
    primaryColorDark: Colors.black12,
    shadowColor: Colors.white,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
    ),
  );

  //Custom light theme
  static final lightTheme = ThemeData(
    primaryColor: Colors.white,
    brightness: Brightness.light,
    primaryColorDark: Colors.white,
  );
}
