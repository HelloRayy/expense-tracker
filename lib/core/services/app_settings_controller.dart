import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central controller for app preferences and experimental features.
class AppSettingsController extends ChangeNotifier {
  static final AppSettingsController instance = AppSettingsController._internal();
  AppSettingsController._internal();

  static const String _prefAutoKilo = 'exp_auto_kilo_thousands';
  static const String _prefCashWallet = 'feature_cash_wallet_enabled';

  bool _autoKiloEnabled = false;
  bool _cashWalletEnabled = false;

  /// Whether automatic thousand scaling (e.g. 72 -> 72.000) is enabled.
  bool get autoKiloEnabled => _autoKiloEnabled;

  /// Whether cash wallet (tracking physical cash alongside e-wallet) is enabled.
  bool get cashWalletEnabled => _cashWalletEnabled;

  /// Initialize settings from persistent storage.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoKiloEnabled = prefs.getBool(_prefAutoKilo) ?? false;
      _cashWalletEnabled = prefs.getBool(_prefCashWallet) ?? false;
      notifyListeners();
    } catch (_) {
      _autoKiloEnabled = false;
      _cashWalletEnabled = false;
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

  /// Toggle or set Cash Wallet mode.
  Future<void> setCashWalletEnabled(bool enabled) async {
    if (_cashWalletEnabled == enabled) return;
    _cashWalletEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefCashWallet, enabled);
    } catch (_) {}
  }

  /// Synchronous setter for unit tests without awaiting SharedPreferences.
  void setCashWalletEnabledForTest(bool enabled) {
    _cashWalletEnabled = enabled;
    notifyListeners();
  }
}
