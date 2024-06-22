import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';

class UiProvider {
  static final darkTheme = ThemeData(
    primaryColor: kPrimary,
    brightness: Brightness.dark,
    primaryColorDark: Colors.black12,
    shadowColor: Colors.white,
    scaffoldBackgroundColor: kPrimary,
    listTileTheme: ListTileThemeData(
      subtitleTextStyle: const TextStyle(
        color: Colors.white30,
        fontSize: 15,
      ),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
      tileColor: kSecondary,
    ),
    appBarTheme: AppBarTheme(
      titleSpacing: 60,
      backgroundColor: kSecondary,
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(2),
        shadowColor: WidgetStateProperty.all(Colors.white),
        backgroundColor: WidgetStateProperty.all(kTertiary),
      ),
    ),
    colorScheme: const ColorScheme(
      primary: Color(0xFF130F26), // second page - key/card/pinch - circle
      brightness: Brightness.dark,
      onPrimary: Color(0xFFE6ECF2), // slider background - inactive
      secondary: Color(0xFFAFCAFF), // slider color 2
      onSecondary: Color(0xFF00ecc2),
      error: Color(0xff750000),
      onError: Color(0xFF2B4485),
      surface:
          Color(0xFFAFCAFF), //second page, box-cup/key/pinch-box second color
      onSurface: Color(0xFFAFCAFF), // sky dark mode background color 2
      tertiary: Colors.grey,
      inversePrimary: Color(0xFF2B4485),
      inverseSurface: Color(0xFFAFCAFF),
    ),
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
