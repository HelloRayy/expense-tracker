import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';

void main() {
  group('Weekly Budget Rollover & Carryover Logic', () {
    test('BudgetModel correctly sums weeklyIncome + carryoverBalance for totalBudget and spendableBudget', () {
      final monday = DateTime(2026, 9, 14);
      final sunday = DateTime(2026, 9, 20, 23, 59, 59, 999);

      final budget = BudgetModel(
        weeklyIncome: 100000,
        weeklySavingsTarget: 30000,
        carryoverBalance: 25000,
        isPeriodConfirmed: true,
        startDate: monday,
        endDate: sunday,
      );

      // Total money held = 100.000 + 25.000 = 125.000
      expect(budget.totalBudget, 125000);

      // Spendable budget = (100.000 - 30.000) + 25.000 = 95.000
      expect(budget.spendableBudget, 95000);

      // Daily allowance on Monday (7 days left) = 95.000 / 7 = 13.571 -> 13.600 rounded
      final allowanceDay1 = budget.calculateDailyAllowance(0, targetDate: monday);
      expect(allowanceDay1, 13600);
    });

    test('BudgetModel toMap and fromMap preserve carryoverBalance and isPeriodConfirmed', () {
      final monday = DateTime(2026, 9, 14);
      final sunday = DateTime(2026, 9, 20, 23, 59, 59, 999);

      final original = BudgetModel(
        weeklyIncome: 150000,
        weeklySavingsTarget: 45000,
        carryoverBalance: 40000,
        isPeriodConfirmed: false,
        startDate: monday,
        endDate: sunday,
      );

      final map = original.toMap();
      expect(map['carryover_balance'], 40000);
      expect(map['is_period_confirmed'], 0);

      final restored = BudgetModel.fromMap(map);
      expect(restored.weeklyIncome, 150000);
      expect(restored.weeklySavingsTarget, 45000);
      expect(restored.carryoverBalance, 40000);
      expect(restored.isPeriodConfirmed, false);
      expect(restored.spendableBudget, (150000 - 45000) + 40000);
    });

    test('Zero carryover retains baseline budget behaviors', () {
      final monday = DateTime(2026, 9, 14);
      final sunday = DateTime(2026, 9, 20, 23, 59, 59, 999);

      final budget = BudgetModel(
        weeklyIncome: 70000,
        weeklySavingsTarget: 0,
        carryoverBalance: 0,
        isPeriodConfirmed: true,
        startDate: monday,
        endDate: sunday,
      );

      expect(budget.totalBudget, 70000);
      expect(budget.spendableBudget, 70000);

      final allowance = budget.calculateDailyAllowance(0, targetDate: monday);
      expect(allowance, 10000);
    });
  });
}
