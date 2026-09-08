import 'package:flutter/foundation.dart';
import '../../../core/database/db_helper.dart';
import '../../../core/services/native_bridge.dart';
import '../models/budget_model.dart';
import '../models/expense_model.dart';

class BudgetRepository extends ChangeNotifier {
  final DbHelper _db = DbHelper.instance;
  final NativeBridge _nativeBridge = NativeBridge.instance;

  BudgetModel? _budget;
  List<ExpenseModel> _expenses = [];
  int _totalSpent = 0;
  int _spentUntilYesterday = 0;
  int _spentToday = 0;
  bool _isLoading = true;

  BudgetModel? get budget => _budget;
  List<ExpenseModel> get expenses => _expenses;
  int get totalSpent => _totalSpent;
  int get spentUntilYesterday => _spentUntilYesterday;
  int get spentToday => _spentToday;
  bool get isLoading => _isLoading;

  int get weeklyIncome => _budget?.weeklyIncome ?? 0;
  int get weeklySavingsTarget => _budget?.weeklySavingsTarget ?? 0;
  int get spendableBudget => _budget?.spendableBudget ?? 0;

  /// Sisa seluruh uang yang dipegang (termasuk tabungan)
  int get remainingBalance {
    return weeklyIncome - _totalSpent;
  }

  /// Sisa budget belanja mingguan yang boleh dipakai jajan
  int get remainingWeeklySpendable {
    return spendableBudget - _totalSpent;
  }

  /// Batas jajan harian hari ini (dihitung dari sisa budget belanja s.d. kemarin dibagi sisa hari)
  int get dailyAllowance {
    if (_budget == null) return 0;
    return _budget!.calculateDailyAllowance(_spentUntilYesterday);
  }

  /// Sisa batas kuota jajan hari ini yang boleh dihabiskan
  int get remainingToday {
    return dailyAllowance - _spentToday;
  }

  /// Status apakah jajan hari ini sudah melampaui batas hari ini
  bool get isOverBudgetToday {
    return remainingToday < 0;
  }

  /// Status apakah total jajan seminggu sudah memakan porsi target tabungan
  bool get isSavingsAtRisk {
    return _totalSpent > spendableBudget;
  }

  double get spendingPercentage {
    if (spendableBudget == 0) return 0.0;
    final pct = _totalSpent / spendableBudget;
    return pct > 1.0 ? 1.0 : (pct < 0.0 ? 0.0 : pct);
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _budget = await _db.getBudget();

      // Check if weekly period needs roll-forward (if current date has passed Sunday 23:59:59)
      final now = DateTime.now();
      if (now.isAfter(_budget!.endDate)) {
        _budget = BudgetModel(
          id: 1,
          weeklyIncome: _budget!.weeklyIncome,
          weeklySavingsTarget: _budget!.weeklySavingsTarget,
          startDate: BudgetModel.getMondayOfWeek(now),
          endDate: BudgetModel.getSundayOfWeek(now),
        );
        await _db.updateBudget(_budget!);
      }

      _totalSpent = await _db.getTotalSpentForPeriod(
        _budget!.startDate,
        _budget!.endDate,
      );
      _spentUntilYesterday = await _db.getSpentUntilYesterday(_budget!.startDate);
      _spentToday = await _db.getSpentToday();
      _expenses = await _db.getExpensesForPeriod(
        _budget!.startDate,
        _budget!.endDate,
      );

      await _syncNative();
    } catch (e) {
      debugPrint('Error loading budget data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(int amount, {String note = 'Jajan'}) async {
    final expense = ExpenseModel(
      amount: amount,
      note: note,
      createdAt: DateTime.now(),
    );
    await _db.insertExpense(expense);
    await loadData();
  }

  Future<void> deleteExpense(int id) async {
    await _db.deleteExpense(id);
    await loadData();
  }

  Future<void> updateBudget({
    int? weeklyIncome,
    int? weeklySavingsTarget,
    int? totalBudget,
    int? paydayDay,
  }) async {
    final now = DateTime.now();
    final income = weeklyIncome ?? totalBudget ?? 0;
    final savings = weeklySavingsTarget ?? (income > 0 ? (income * 0.3).round() : 0);
    final newBudget = BudgetModel(
      id: 1,
      weeklyIncome: income,
      weeklySavingsTarget: savings,
      startDate: BudgetModel.getMondayOfWeek(now),
      endDate: BudgetModel.getSundayOfWeek(now),
    );
    await _db.updateBudget(newBudget);
    await loadData();
  }

  Future<void> _syncNative() async {
    if (_budget == null) return;
    // In native floating widget/overlay:
    // daily_safe represents today's remaining jajan allowance
    await _nativeBridge.syncBalanceToNative(
      remainingBalance: remainingBalance,
      totalBudget: _budget!.weeklyIncome,
      dailySafe: remainingToday,
      totalSpent: totalSpent,
      formattedPeriod: _budget!.formattedPeriod,
    );
  }
}
