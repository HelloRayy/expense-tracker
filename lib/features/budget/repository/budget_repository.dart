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
  bool _isLoading = true;

  BudgetModel? get budget => _budget;
  List<ExpenseModel> get expenses => _expenses;
  int get totalSpent => _totalSpent;
  bool get isLoading => _isLoading;

  int get remainingBalance {
    if (_budget == null) return 0;
    return _budget!.totalBudget - _totalSpent;
  }

  int get dailyAllowance {
    if (_budget == null) return 0;
    return _budget!.calculateDailyAllowance(remainingBalance);
  }

  double get spendingPercentage {
    if (_budget == null || _budget!.totalBudget == 0) return 0.0;
    final pct = _totalSpent / _budget!.totalBudget;
    return pct > 1.0 ? 1.0 : (pct < 0.0 ? 0.0 : pct);
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _budget = await _db.getBudget();

      // Check if period needs roll-forward (if current date has passed endDate)
      final now = DateTime.now();
      if (now.isAfter(_budget!.endDate)) {
        _budget = BudgetModel.createDefault(
          total: _budget!.totalBudget,
          payday: _budget!.paydayDay,
        );
        await _db.updateBudget(_budget!);
      }

      _totalSpent = await _db.getTotalSpentForPeriod(
        _budget!.startDate,
        _budget!.endDate,
      );
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

  Future<void> updateBudget({required int totalBudget, required int paydayDay}) async {
    final newBudget = BudgetModel.createDefault(
      total: totalBudget,
      payday: paydayDay,
    );
    await _db.updateBudget(newBudget);
    await loadData();
  }

  Future<void> _syncNative() async {
    if (_budget == null) return;
    await _nativeBridge.syncBalanceToNative(
      remainingBalance: remainingBalance,
      totalBudget: _budget!.totalBudget,
      dailySafe: dailyAllowance,
    );
  }
}
