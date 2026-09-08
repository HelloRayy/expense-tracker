import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/core/utils/currency_formatter.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('format produces standard Rupiah representation', () {
      expect(CurrencyFormatter.format(50000), contains('50.000'));
      expect(CurrencyFormatter.format(1500000), contains('1.500.000'));
    });

    test('formatCompact formats millions and thousands properly', () {
      expect(CurrencyFormatter.formatCompact(1500000), 'Rp 1.5jt');
      expect(CurrencyFormatter.formatCompact(2000000), 'Rp 2jt');
      expect(CurrencyFormatter.formatCompact(45000), 'Rp 45rb');
      expect(CurrencyFormatter.formatCompact(500), 'Rp 500');
    });

    test('parse correctly converts raw or formatted strings to int', () {
      expect(CurrencyFormatter.parse('50000'), 50000);
      expect(CurrencyFormatter.parse('Rp 1.500.000'), 1500000);
      expect(CurrencyFormatter.parse('abc'), 0);
    });
  });

  group('BudgetModel & Calculation Tests', () {
    test('BudgetModel daysRemainingInWeek calculation', () {
      final monday = DateTime(2026, 9, 7);
      final sunday = DateTime(2026, 9, 13, 23, 59, 59, 999);
      final budget = BudgetModel(
        weeklyIncome: 100000,
        weeklySavingsTarget: 30000,
        startDate: monday,
        endDate: sunday,
      );

      expect(budget.spendableBudget, 70000);
      expect(budget.daysRemainingInWeek, inInclusiveRange(1, 7));
    });

    test('Daily allowance calculation with rolling redistribution', () {
      final monday = DateTime(2026, 9, 7);
      final sunday = DateTime(2026, 9, 13, 23, 59, 59, 999);
      final budget = BudgetModel(
        weeklyIncome: 100000,
        weeklySavingsTarget: 30000,
        startDate: monday,
        endDate: sunday,
      );

      // On Monday (7 days left), spent = 0 -> 70.000 / 7 = 10.000
      final daily = budget.calculateDailyAllowance(0, targetDate: DateTime(2026, 9, 7));
      expect(daily, 10000);
    });

    test('Daily allowance returns 0 if remaining budget <= 0', () {
      final monday = DateTime(2026, 9, 7);
      final sunday = DateTime(2026, 9, 13, 23, 59, 59, 999);
      final budget = BudgetModel(
        weeklyIncome: 100000,
        weeklySavingsTarget: 30000,
        startDate: monday,
        endDate: sunday,
      );

      expect(budget.calculateDailyAllowance(70000, targetDate: DateTime(2026, 9, 9)), 0);
      expect(budget.calculateDailyAllowance(80000, targetDate: DateTime(2026, 9, 9)), 0);
      expect(budget.isSavingsAtRisk(75000), isTrue);
    });
  });

  group('ExpenseModel Tests', () {
    test('Serialization toMap and fromMap', () {
      final now = DateTime.now();
      final expense = ExpenseModel(
        id: 1,
        amount: 25000,
        note: 'Kopi Susu',
        createdAt: now,
      );

      final map = expense.toMap();
      expect(map['id'], 1);
      expect(map['amount'], 25000);
      expect(map['note'], 'Kopi Susu');

      final reconstructed = ExpenseModel.fromMap(map);
      expect(reconstructed.id, 1);
      expect(reconstructed.amount, 25000);
      expect(reconstructed.note, 'Kopi Susu');
    });

    test('Default note when empty is Jajan', () {
      final expense = ExpenseModel(
        amount: 15000,
        note: '   ',
        createdAt: DateTime.now(),
      );
      expect(expense.toMap()['note'], 'Jajan');
    });

    test('ExpenseModel handles ISO-8601 string parsing with or without milliseconds', () {
      final mapWithMs = {
        'id': 2,
        'amount': 30000,
        'note': 'Makan Siang',
        'created_at': '2026-09-07T21:15:30.123',
      };
      final exp1 = ExpenseModel.fromMap(mapWithMs);
      expect(exp1.createdAt.year, 2026);
      expect(exp1.createdAt.month, 9);
      expect(exp1.createdAt.day, 7);

      final mapWithoutMs = {
        'id': 3,
        'amount': 45000,
        'note': 'Bensin',
        'created_at': '2026-09-07T21:15:30',
      };
      final exp2 = ExpenseModel.fromMap(mapWithoutMs);
      expect(exp2.amount, 45000);
      expect(exp2.createdAt.year, 2026);
    });
  });

  group('BudgetModel Default Creation & Rollover Tests', () {
    test('createDefault produces valid start and end dates', () {
      final budget = BudgetModel.createDefault(income: 200000, savings: 50000);
      expect(budget.weeklyIncome, 200000);
      expect(budget.weeklySavingsTarget, 50000);
      expect(budget.spendableBudget, 150000);
      expect(budget.startDate.weekday, DateTime.monday);
      expect(budget.endDate.weekday, DateTime.sunday);
      expect(budget.endDate.isAfter(budget.startDate), isTrue);
      expect(budget.daysRemainingInWeek, inInclusiveRange(1, 7));
    });

    test('Budget period duration is exactly one week (Monday to Sunday)', () {
      final budget = BudgetModel.createDefault();
      final differenceInDays = budget.endDate.difference(budget.startDate).inDays;
      expect(differenceInDays, 6); // Monday to Sunday is 6 days apart
    });
  });
}

