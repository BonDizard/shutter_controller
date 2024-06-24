import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';

class UiProvider {
  static final darkTheme = ThemeData(
    primaryColor: kPrimary,
    brightness: Brightness.dark,
    primaryColorDark: Colors.black12,
    shadowColor: kPrimaryLight,
    scaffoldBackgroundColor: kPrimary,
    drawerTheme: DrawerThemeData(
      elevation: 4,
      backgroundColor: kPrimary,
    ),
    listTileTheme: ListTileThemeData(
      subtitleTextStyle: const TextStyle(
        color: Colors.white30,
        fontSize: 15,
      ),
      titleTextStyle: TextStyle(
        color: kPrimaryLight,
        fontSize: 18,
      ),
      tileColor: kSecondary,
    ),
    appBarTheme: AppBarTheme(
      titleSpacing: 60,
      backgroundColor: kSecondary,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: kPrimaryLight,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(2),
        shadowColor: WidgetStateProperty.all(kPrimaryLight),
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
    primaryColor: kPrimaryLight,
    brightness: Brightness.light,
    primaryColorDark: kSecondary,
    shadowColor: kPrimary,
    scaffoldBackgroundColor: kPrimaryLight,
    drawerTheme: DrawerThemeData(
      elevation: 4,
      backgroundColor: kPrimaryLight,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kSecondaryLight,
      elevation: 2,
      selectedItemColor: kTertiaryLight,
      selectedLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      selectedIconTheme: IconThemeData(
        color: kTertiaryLight,
      ),
      unselectedIconTheme: IconThemeData(
        color: kSecondaryLight,
      ),
      unselectedItemColor: kSecondaryLight,
      unselectedLabelStyle: TextStyle(
        color: kPrimaryLight,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    ),
    listTileTheme: ListTileThemeData(
      subtitleTextStyle: TextStyle(
        color: kPrimary,
        fontSize: 15,
      ),
      titleTextStyle: TextStyle(
        color: kPrimary,
        fontSize: 18,
      ),
      tileColor: kSecondaryLight,
    ),
    appBarTheme: AppBarTheme(
      titleSpacing: 60,
      backgroundColor: kSecondaryLight,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: kPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(2),
        shadowColor: WidgetStateProperty.all(kPrimary),
        backgroundColor: WidgetStateProperty.all(kTertiaryLight),
      ),
    ),
    colorScheme: const ColorScheme(
      primary: Color(0xFF130F26), // second page - key/card/pinch - circle
      brightness: Brightness.light,
      onPrimary: Color(0xFFE6ECF2), // slider background - inactive
      secondary: Color(0xFFAFCAFF), // slider color 2
      onSecondary: Color(0xFF00ecc2),
      error: Colors.red,
      onError: Color(0xFF2B4485),
      surface:
          Color(0xFFAFCAFF), //second page, box-cup/key/pinch-box second color
      onSurface: Color(0xFFAFCAFF), // sky dark mode background color 2
      tertiary: Colors.grey,
      inversePrimary: Color(0xFF2B4485),
      inverseSurface: Color(0xFFAFCAFF),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        color: kPrimary,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        color: kPrimary,
      ),
    ),
  );
}
