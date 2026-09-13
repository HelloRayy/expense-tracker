import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central controller for app preferences and experimental features.
class AppSettingsController extends ChangeNotifier {
  static final AppSettingsController instance = AppSettingsController._internal();
  AppSettingsController._internal();

  static const String _prefAutoKilo = 'exp_auto_kilo_thousands';

  bool _autoKiloEnabled = false;

  /// Whether automatic thousand scaling (e.g. 72 -> 72.000) is enabled.
  bool get autoKiloEnabled => _autoKiloEnabled;

  /// Initialize settings from persistent storage.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoKiloEnabled = prefs.getBool(_prefAutoKilo) ?? false;
      notifyListeners();
    } catch (_) {
      _autoKiloEnabled = false;
    }
  }

  /// Toggle or set Auto-Kilo mode.
  Future<void> setAutoKiloEnabled(bool enabled) async {
    if (_autoKiloEnabled == enabled) return;
    _autoKiloEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefAutoKilo, enabled);
    } catch (_) {}
  }
}
