import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Brightness get themeBrightness => _isDarkMode ? Brightness.dark : Brightness.light;

  ThemeData get themeData {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: themeBrightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _isDarkMode ? Colors.deepPurple : Colors.lightBlue,
        brightness: themeBrightness,
      ),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: _isDarkMode ? Colors.black87 : Colors.white,
      textTheme: baseTheme.textTheme.copyWith(
        headlineMedium: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: _isDarkMode ? Colors.white : Colors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.0,
          color: _isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _isDarkMode ? Colors.deepPurple[700] : Colors.lightBlue,
        elevation: 4,
        iconTheme: IconThemeData(
          color: _isDarkMode ? Colors.white : Colors.black,
        ),
        titleTextStyle: TextStyle(
          color: _isDarkMode ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      iconTheme: IconThemeData(
        color: _isDarkMode ? Colors.white70 : Colors.black87,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isDarkMode ? Colors.deepPurpleAccent : Colors.lightBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

