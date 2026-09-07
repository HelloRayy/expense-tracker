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
    test('BudgetModel daysRemaining calculation', () {
      final now = DateTime.now();
      final budget = BudgetModel(
        totalBudget: 1500000,
        paydayDay: 25,
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 20)),
      );

      expect(budget.daysRemaining, greaterThanOrEqualTo(19));
      expect(budget.daysRemaining, lessThanOrEqualTo(21));
    });

    test('Daily allowance calculation', () {
      final now = DateTime.now();
      final budget = BudgetModel(
        totalBudget: 1000000,
        paydayDay: 25,
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 10)),
      );

      // 500.000 remaining with ~10 days left -> ~50.000/day
      final daily = budget.calculateDailyAllowance(500000);
      expect(daily, greaterThan(40000));
      expect(daily, lessThan(60000));
    });

    test('Daily allowance returns 0 if remaining balance <= 0', () {
      final now = DateTime.now();
      final budget = BudgetModel(
        totalBudget: 1000000,
        paydayDay: 25,
        startDate: now,
        endDate: now.add(const Duration(days: 10)),
      );

      expect(budget.calculateDailyAllowance(0), 0);
      expect(budget.calculateDailyAllowance(-50000), 0);
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
      final budget = BudgetModel.createDefault(total: 2000000, payday: 25);
      expect(budget.totalBudget, 2000000);
      expect(budget.paydayDay, 25);
      expect(budget.endDate.isAfter(budget.startDate), isTrue);
      expect(budget.daysRemaining, greaterThan(0));
    });

    test('Budget period duration is approximately one month', () {
      final budget = BudgetModel.createDefault(payday: 1);
      final differenceInDays = budget.endDate.difference(budget.startDate).inDays;
      expect(differenceInDays, greaterThanOrEqualTo(28));
      expect(differenceInDays, lessThanOrEqualTo(32));
    });
  });
}

