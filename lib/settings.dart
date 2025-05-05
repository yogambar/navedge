import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // Fields
  bool _darkMode = false;
  double _brightness = 1.0;
  bool _soundEnabled = true;

  // Getters
  bool get darkMode => _darkMode;
  double get brightness => _brightness;
  bool get soundEnabled => _soundEnabled;

  // Constructor - load saved settings
  SettingsProvider() {
    _loadSettings();
  }

  /// Loads settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _darkMode = prefs.getBool('darkMode') ?? false;
    _brightness = (prefs.getDouble('brightness') ?? 1.0).clamp(0.0, 1.0);
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;

    notifyListeners();
  }

  /// Sets dark mode on/off
  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  /// Toggles dark mode (for switch button support)
  Future<void> toggleDarkMode() async {
    await setDarkMode(!_darkMode);
  }

  /// Sets screen brightness level
  Future<void> setBrightness(double value) async {
    _brightness = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('brightness', _brightness);
    notifyListeners();
  }

  /// Enables/disables sound
  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
    notifyListeners();
  }

  /// Toggles sound setting
  Future<void> toggleSound() async {
    await setSoundEnabled(!_soundEnabled);
  }

  // Theme settings for dark mode with custom font
  ThemeData get currentTheme {
    return _darkMode
        ? ThemeData.dark().copyWith(
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontFamily: 'NotoEmoji'),
              bodyMedium: TextStyle(fontFamily: 'NotoEmoji'),
              bodySmall: TextStyle(fontFamily: 'NotoEmoji'),
              headlineLarge: TextStyle(fontFamily: 'NotoEmoji'),
              headlineMedium: TextStyle(fontFamily: 'NotoEmoji'),
              headlineSmall: TextStyle(fontFamily: 'NotoEmoji'),
              titleLarge: TextStyle(fontFamily: 'NotoEmoji'),
              titleMedium: TextStyle(fontFamily: 'NotoEmoji'),
              titleSmall: TextStyle(fontFamily: 'NotoEmoji'),
              labelLarge: TextStyle(fontFamily: 'NotoEmoji'),
              labelMedium: TextStyle(fontFamily: 'NotoEmoji'),
              labelSmall: TextStyle(fontFamily: 'NotoEmoji'),
            ),
            brightness: Brightness.dark,
          )
        : ThemeData.light().copyWith(
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontFamily: 'NotoEmoji'),
              bodyMedium: TextStyle(fontFamily: 'NotoEmoji'),
              bodySmall: TextStyle(fontFamily: 'NotoEmoji'),
              headlineLarge: TextStyle(fontFamily: 'NotoEmoji'),
              headlineMedium: TextStyle(fontFamily: 'NotoEmoji'),
              headlineSmall: TextStyle(fontFamily: 'NotoEmoji'),
              titleLarge: TextStyle(fontFamily: 'NotoEmoji'),
              titleMedium: TextStyle(fontFamily: 'NotoEmoji'),
              titleSmall: TextStyle(fontFamily: 'NotoEmoji'),
              labelLarge: TextStyle(fontFamily: 'NotoEmoji'),
              labelMedium: TextStyle(fontFamily: 'NotoEmoji'),
              labelSmall: TextStyle(fontFamily: 'NotoEmoji'),
            ),
            brightness: Brightness.light,
          );
  }
}

