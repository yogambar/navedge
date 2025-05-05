import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  // Private fields for settings
  bool _isDarkMode = false;
  double _brightness = 1.0;
  double _soundVolume = 1.0;

  // Public getters
  bool get isDarkMode => _isDarkMode;
  double get brightness => _brightness;
  double get soundVolume => _soundVolume;

  // Keys for SharedPreferences
  static const _darkModeKey = 'darkMode';
  static const _brightnessKey = 'brightness';
  static const _soundVolumeKey = 'soundVolume';

  /// Loads settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      _brightness = (prefs.getDouble(_brightnessKey) ?? 1.0).clamp(0.1, 1.0);
      _soundVolume = (prefs.getDouble(_soundVolumeKey) ?? 1.0).clamp(0.0, 1.0);

      debugPrint(
        "✅ Settings loaded: darkMode=$_isDarkMode, "
        "brightness=$_brightness, soundVolume=$_soundVolume",
      );

      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Error loading settings: $e");
      rethrow;
    }
  }

  /// Toggles dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _saveBool(_darkModeKey, _isDarkMode);
  }

  /// Sets dark mode manually
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _saveBool(_darkModeKey, value);
  }

  /// Sets brightness (range 0.1 - 1.0)
  Future<void> setBrightness(double value) async {
    _brightness = value.clamp(0.1, 1.0);
    await _saveDouble(_brightnessKey, _brightness);
  }

  /// Sets sound volume (range 0.0 - 1.0)
  Future<void> setSoundVolume(double value) async {
    _soundVolume = value.clamp(0.0, 1.0);
    await _saveDouble(_soundVolumeKey, _soundVolume);
  }

  /// Resets all settings to default values
  Future<void> resetSettings() async {
    _isDarkMode = false;
    _brightness = 1.0;
    _soundVolume = 1.0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _isDarkMode);
    await prefs.setDouble(_brightnessKey, _brightness);
    await prefs.setDouble(_soundVolumeKey, _soundVolume);

    debugPrint("🔄 Settings reset to default values.");
    notifyListeners();
  }

  /// Manual fetchers (optional)
  Future<bool> getDarkModeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<double> getBrightnessFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_brightnessKey)?.clamp(0.1, 1.0) ?? 1.0;
  }

  Future<double> getSoundVolumeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_soundVolumeKey)?.clamp(0.0, 1.0) ?? 1.0;
  }

  /// Private helper to save a boolean
  Future<void> _saveBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
      debugPrint("💾 Saved bool [$key]: $value");
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Error saving bool [$key]: $e");
    }
  }

  /// Private helper to save a double
  Future<void> _saveDouble(String key, double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(key, value);
      debugPrint("💾 Saved double [$key]: $value");
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Error saving double [$key]: $e");
    }
  }
}

