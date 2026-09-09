import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NativeBridge {
  static const MethodChannel _widgetChannel =
      MethodChannel('com.hellorayy.jajan_tracker/widget');
  static const MethodChannel _shopeeChannel =
      MethodChannel('com.hellorayy.jajan_tracker/shopee_watcher');

  static final NativeBridge instance = NativeBridge._internal();
  factory NativeBridge() => instance;
  NativeBridge._internal();

  /// Updates balance data in SharedPreferences and notifies native Home Screen AppWidget
  Future<void> syncBalanceToNative({
    required int remainingBalance,
    required int totalBudget,
    required int dailySafe,
    int? weeklyIncome,
    int dailyAllowance = 0,
    int remainingToday = 0,
    int spentToday = 0,
    int totalSpent = 0,
    String userName = 'Username',
    String formattedPeriod = '',
  }) async {
    try {
      final effectiveWeeklyIncome = weeklyIncome ?? totalBudget;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('remaining_balance', remainingBalance);
      await prefs.setInt('total_budget', totalBudget);
      await prefs.setInt('weekly_income', effectiveWeeklyIncome);
      await prefs.setInt('daily_safe', dailySafe);
      await prefs.setInt('daily_allowance', dailyAllowance);
      await prefs.setInt('remaining_today', remainingToday);
      await prefs.setInt('spent_today', spentToday);
      await prefs.setInt('total_spent', totalSpent);
      await prefs.setString('user_name', userName);
      await prefs.setString('formatted_period', formattedPeriod);
      await prefs.setString('last_updated', DateTime.now().toIso8601String());

      // Notify native widget manager to refresh
      await _widgetChannel.invokeMethod('updateWidget', {
        'remaining_balance': remainingBalance,
        'total_budget': totalBudget,
        'weekly_income': effectiveWeeklyIncome,
        'daily_safe': dailySafe,
        'daily_allowance': dailyAllowance,
        'remaining_today': remainingToday,
        'spent_today': spentToday,
        'total_spent': totalSpent,
        'user_name': userName,
        'formatted_period': formattedPeriod,
      });
    } catch (e) {
      // Ignored on non-android platforms or if native channel not ready
    }
  }

  /// Check if Overlay (Draw over other apps) permission is granted
  Future<bool> checkOverlayPermission() async {
    try {
      final bool granted =
          await _shopeeChannel.invokeMethod('checkOverlayPermission') ?? false;
      return granted;
    } catch (_) {
      return false;
    }
  }

  /// Open Overlay permission settings screen
  Future<void> openOverlaySettings() async {
    try {
      await _shopeeChannel.invokeMethod('openOverlaySettings');
    } catch (_) {}
  }

  /// Check if Accessibility Service is active
  Future<bool> checkAccessibilityPermission() async {
    try {
      final bool enabled =
          await _shopeeChannel.invokeMethod('checkAccessibilityPermission') ?? false;
      return enabled;
    } catch (_) {
      return false;
    }
  }

  /// Open Accessibility Settings screen
  Future<void> openAccessibilitySettings() async {
    try {
      await _shopeeChannel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  /// Triggers a test floating reminder on screen
  Future<void> showShopeeFloatingTest(int balance) async {
    try {
      await _shopeeChannel.invokeMethod('showFloatingReminder', {
        'balance': balance,
      });
    } catch (_) {}
  }

  /// Toggle floating bubble service
  Future<void> toggleFloatingBubble(bool enabled) async {
    try {
      await _shopeeChannel.invokeMethod('toggleFloatingBubble', {
        'enabled': enabled,
      });
    } catch (_) {}
  }

  /// Check if floating bubble is currently active
  Future<bool> isFloatingBubbleRunning() async {
    try {
      final bool running =
          await _shopeeChannel.invokeMethod('isFloatingBubbleRunning') ?? false;
      return running;
    } catch (_) {
      return false;
    }
  }

  /// Check if app was opened via Widget Quick-Log action
  Future<String?> getInitialAction() async {
    try {
      final String? action = await _widgetChannel.invokeMethod('getInitialAction');
      return action;
    } catch (_) {
      return null;
    }
  }

  /// Check if Notification Listener (Akses Notifikasi) permission is granted
  Future<bool> checkNotificationListenerPermission() async {
    try {
      final bool enabled =
          await _shopeeChannel.invokeMethod('checkNotificationListenerPermission') ?? false;
      return enabled;
    } catch (_) {
      return false;
    }
  }

  /// Open Notification Listener Settings screen
  Future<void> openNotificationListenerSettings() async {
    try {
      await _shopeeChannel.invokeMethod('openNotificationListenerSettings');
    } catch (_) {}
  }

  /// Simulate payment notification for testing
  Future<void> simulatePaymentNotification({int amount = 35000, String note = 'ShopeePay'}) async {
    try {
      await _shopeeChannel.invokeMethod('simulatePaymentNotification', {
        'amount': amount,
        'note': note,
      });
    } catch (_) {}
  }
}
