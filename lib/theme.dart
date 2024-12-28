import 'package:flutter/material.dart';

class AppTheme {
  static const deepBlue = Color(0xFF050B27);
  static const purple = Color(0xFF1A1B4B);
  static const neonBlue = Color(0xFF00BFFF);
  static const Color appBarBackground = Colors.white;
  static const Color cyan = Colors.cyan;

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      primaryColor: cyan,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: deepBlue),
        titleTextStyle: TextStyle(
            color: deepBlue, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      colorScheme: ColorScheme.light(
        primary: cyan,
        secondary: neonBlue,
        surface: Colors.white,
        background: Colors.grey[100]!,
        onPrimary: deepBlue,
        onSecondary: Colors.white,
        onSurface: deepBlue,
        onBackground: deepBlue,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: deepBlue, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: deepBlue, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: deepBlue),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: deepBlue,
          backgroundColor: cyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: cyan,
      scaffoldBackgroundColor: deepBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: deepBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: cyan),
        titleTextStyle:
            TextStyle(color: cyan, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      colorScheme: ColorScheme.dark(
        primary: cyan,
        secondary: neonBlue,
        surface: purple,
        background: deepBlue,
        onPrimary: deepBlue,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineMedium:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: deepBlue,
          backgroundColor: cyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  static BoxDecoration get glassomorphicDecoration {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 5,
        ),
      ],
    );
  }
}
