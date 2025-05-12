import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  // Method to get current theme mode
  Future<Brightness> getCurrentThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0; // 0 = Light, 1 = Dark
    return themeModeIndex == 1 ? Brightness.dark : Brightness.light;
  }

  // Method to set theme mode
  Future<void> setThemeMode(Brightness brightness) async {
    final prefs = await SharedPreferences.getInstance();
    int themeModeIndex = brightness == Brightness.dark ? 1 : 0;
    await prefs.setInt('themeMode', themeModeIndex);
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final currentThemeMode = prefs.getInt('themeMode') ?? 0;
    final newThemeMode = currentThemeMode == 0 ? 1 : 0;
    await prefs.setInt('themeMode', newThemeMode);
  }
}

