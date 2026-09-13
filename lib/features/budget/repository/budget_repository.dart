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
  int get carryoverBalance => _budget?.carryoverBalance ?? 0;
  bool get isPeriodConfirmed => _budget?.isPeriodConfirmed ?? true;
  int get spendableBudget => _budget?.spendableBudget ?? 0;

  /// Sisa seluruh uang yang dipegang (termasuk tabungan + uang carryover)
  int get remainingBalance {
    return (_budget?.totalBudget ?? 0) - _totalSpent;
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

    if (kIsWeb) {
      _budget ??= BudgetModel.createDefault(income: 150000, savings: 50000);
      if (_expenses.isEmpty) {
        _expenses = [
          ExpenseModel(
            id: 1,
            amount: 15000,
            note: 'Kopi Kenangan',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ExpenseModel(
            id: 2,
            amount: 25000,
            note: 'Nasi Padang',
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          ),
        ];
        _totalSpent = 40000;
        _spentToday = 40000;
        _spentUntilYesterday = 0;
      }
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _budget = await _db.getBudget();

      // Check if weekly period needs roll-forward (if current date has passed Sunday 23:59:59)
      final now = DateTime.now();
      if (now.isAfter(_budget!.endDate)) {
        // Calculate leftover surplus from the period that just ended
        final oldExpenses = await _db.getExpensesForPeriod(
          _budget!.startDate,
          _budget!.endDate,
        );
        final oldTotalSpent = oldExpenses.fold<int>(0, (sum, e) => sum + e.amount);
        // Only positive surplus is carried over; if overbudget, carryover is 0
        final surplus = (_budget!.spendableBudget - oldTotalSpent).clamp(0, _budget!.spendableBudget);

        _budget = BudgetModel(
          id: 1,
          weeklyIncome: 0, // Reset to 0 until user confirms/inputs new weekly budget
          weeklySavingsTarget: 0,
          carryoverBalance: surplus,
          isPeriodConfirmed: false, // Flag that user input is needed
          startDate: BudgetModel.getMondayOfWeek(now),
          endDate: BudgetModel.getSundayOfWeek(now),
        );
        await _db.updateBudget(_budget!);
      }

      // Single query for period expenses; aggregates are derived in-memory for speed and consistency
      _expenses = await _db.getExpensesForPeriod(
        _budget!.startDate,
        _budget!.endDate,
      );
      _totalSpent = _expenses.fold<int>(0, (sum, e) => sum + e.amount);
      _spentToday = _expenses.where((e) => e.isToday).fold<int>(0, (sum, e) => sum + e.amount);
      _spentUntilYesterday = _totalSpent - _spentToday;

      await _syncNative();
    } catch (e) {
      debugPrint('Error loading budget data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(int amount, {String note = 'Jajan'}) async {
    if (kIsWeb) {
      final expense = ExpenseModel(
        id: DateTime.now().millisecondsSinceEpoch,
        amount: amount,
        note: note,
        createdAt: DateTime.now(),
      );
      _expenses.insert(0, expense);
      _totalSpent += amount;
      _spentToday += amount;
      notifyListeners();
      return;
    }
    final expense = ExpenseModel(
      amount: amount,
      note: note,
      createdAt: DateTime.now(),
    );
    await _db.insertExpense(expense);
    await loadData();
  }

  Future<void> deleteExpense(int id) async {
    if (kIsWeb) {
      final item = _expenses.firstWhere((e) => e.id == id, orElse: () => ExpenseModel(amount: 0, note: '', createdAt: DateTime.now()));
      _totalSpent -= item.amount;
      _spentToday -= item.amount;
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
      return;
    }
    await _db.deleteExpense(id);
    await loadData();
  }

  Future<void> resetAllExpenses() async {
    if (kIsWeb) {
      _expenses.clear();
      _totalSpent = 0;
      _spentToday = 0;
      _spentUntilYesterday = 0;
      notifyListeners();
      return;
    }
    final db = await _db.database;
    await db.delete('expenses');
    await loadData();
  }

  /// Batch update multiple categories across various expenses atomically.
  Future<void> batchAssignMultiCategories(Map<int, String?> categoryUpdates) async {
    if (categoryUpdates.isEmpty) return;

    if (kIsWeb) {
      for (int i = 0; i < _expenses.length; i++) {
        final exp = _expenses[i];
        if (exp.id != null && categoryUpdates.containsKey(exp.id)) {
          final newCat = categoryUpdates[exp.id];
          _expenses[i] = exp.copyWith(
            categoryId: newCat,
            clearCategory: newCat == null,
          );
        }
      }
      notifyListeners();
      return;
    }

    await _db.batchUpdateMultiCategories(categoryUpdates);
    await loadData();
  }

  /// Batch assign category to transactions and unassign deselected ones.
  Future<void> batchAssignCategory({
    required List<int> assignIds,
    required String targetCategoryId,
    required List<int> unassignIds,
  }) async {
    final Map<int, String?> updates = {};
    for (final id in assignIds) {
      updates[id] = targetCategoryId;
    }
    for (final id in unassignIds) {
      updates[id] = null;
    }
    await batchAssignMultiCategories(updates);
  }

  /// Confirm / set weekly budget with optional carryover balance and savings target.
  Future<void> confirmWeeklyBudget({
    required int newIncome,
    int? carryover,
    int? savingsTarget,
  }) async {
    final now = DateTime.now();
    final effectiveCarryover = carryover ?? (_budget?.carryoverBalance ?? 0);
    final income = newIncome;
    final savings = savingsTarget ?? (income > 0 ? (income * 0.3).round() : 0);

    final newBudget = BudgetModel(
      id: 1,
      weeklyIncome: income,
      weeklySavingsTarget: savings,
      carryoverBalance: effectiveCarryover,
      isPeriodConfirmed: true,
      startDate: BudgetModel.getMondayOfWeek(now),
      endDate: BudgetModel.getSundayOfWeek(now),
    );

    if (kIsWeb) {
      _budget = newBudget;
      notifyListeners();
      return;
    }
    await _db.updateBudget(newBudget);
    await loadData();
  }

  Future<void> updateBudget({
    int? weeklyIncome,
    int? weeklySavingsTarget,
    int? totalBudget,
    int? carryoverBalance,
    bool? isPeriodConfirmed,
    int? paydayDay,
  }) async {
    final now = DateTime.now();
    final income = weeklyIncome ?? totalBudget ?? _budget?.weeklyIncome ?? 0;
    final savings = weeklySavingsTarget ?? (income > 0 ? (income * 0.3).round() : 0);
    final carryover = carryoverBalance ?? _budget?.carryoverBalance ?? 0;
    final confirmed = isPeriodConfirmed ?? _budget?.isPeriodConfirmed ?? true;

    final newBudget = BudgetModel(
      id: 1,
      weeklyIncome: income,
      weeklySavingsTarget: savings,
      carryoverBalance: carryover,
      isPeriodConfirmed: confirmed,
      startDate: BudgetModel.getMondayOfWeek(now),
      endDate: BudgetModel.getSundayOfWeek(now),
    );
    if (kIsWeb) {
      _budget = newBudget;
      notifyListeners();
      return;
    }
    await _db.updateBudget(newBudget);
    await loadData();
  }

  Future<void> _syncNative() async {
    if (kIsWeb || _budget == null) return;
    // In native floating widget/overlay:
    // daily_safe represents today's remaining jajan allowance
    await _nativeBridge.syncBalanceToNative(
      remainingBalance: remainingBalance,
      totalBudget: _budget!.totalBudget,
      weeklyIncome: _budget!.weeklyIncome,
      dailySafe: remainingToday,
      dailyAllowance: dailyAllowance,
      remainingToday: remainingToday,
      spentToday: spentToday,
      totalSpent: totalSpent,
      userName: 'Raditya Rayhan',
      formattedPeriod: _budget!.formattedPeriod,
    );
  }
}
