import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized ThemeController for managing and persisting App ThemeMode.
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._internal();
  ThemeController._internal();

  static const String _prefKey = 'app_theme_mode';
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  /// Returns whether dark mode is currently effective for the given context or setting.
  bool isDark(BuildContext context) {
    if (_themeMode == ThemeMode.light) return false;
    return true; // Default is Dark Mode
  }

  /// Initialize theme mode from SharedPreferences.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_prefKey);
      if (savedMode == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        // Default to dark mode
        _themeMode = ThemeMode.dark;
      }
      notifyListeners();
    } catch (_) {
      _themeMode = ThemeMode.dark;
    }
  }

  /// Set explicit ThemeMode and persist.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mode == ThemeMode.dark) {
        await prefs.setString(_prefKey, 'dark');
      } else if (mode == ThemeMode.light) {
        await prefs.setString(_prefKey, 'light');
      } else {
        await prefs.remove(_prefKey);
      }
    } catch (_) {}
  }

  /// Toggle dark mode on or off.
  Future<void> toggleDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }
}
