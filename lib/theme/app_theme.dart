import 'package:flutter/material.dart';

// Global State for Dark Mode
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

class AppTheme {
  static const Color primaryTeal = Color(0xFF009688);
  static const Color darkTeal = Color(0xFF00796B);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color backgroundLight = Color(0xFFF4F4F9);

  static ThemeData get lightTheme => ThemeData(
        primaryColor: primaryTeal,
        scaffoldBackgroundColor: backgroundLight,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        primaryColor: primaryTeal,
        scaffoldBackgroundColor: const Color(0xFF121212),
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardColor: const Color(0xFF1E1E1E),
      );
}