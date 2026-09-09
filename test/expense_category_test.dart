import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';
import 'package:jajan_tracker/features/categories/models/expense_category.dart';

void main() {
  group('ExpenseCategory Model & Normalizer Tests', () {
    test('all contains 4 canonical categories with expected ids', () {
      expect(ExpenseCategory.all.length, 4);
      expect(ExpenseCategory.all.map((c) => c.id).toList(), [
        'Makanan',
        'Kopi & Minum',
        'Transport',
        'Belanja',
      ]);
    });

    test('fromId normalizes aliases and casing accurately', () {
      expect(ExpenseCategory.fromId('Makanan'), ExpenseCategory.makanan);
      expect(ExpenseCategory.fromId('makanan'), ExpenseCategory.makanan);
      expect(ExpenseCategory.fromId('Kopi'), ExpenseCategory.kopi);
      expect(ExpenseCategory.fromId('Kopi & Minum'), ExpenseCategory.kopi);
      expect(ExpenseCategory.fromId('minum'), ExpenseCategory.kopi);
      expect(ExpenseCategory.fromId('Transport'), ExpenseCategory.transport);
      expect(ExpenseCategory.fromId('transpor'), ExpenseCategory.transport);
      expect(ExpenseCategory.fromId('Belanja'), ExpenseCategory.belanja);
      expect(ExpenseCategory.fromId('Belanja/QRIS'), ExpenseCategory.belanja);
      expect(ExpenseCategory.fromId('qris'), ExpenseCategory.belanja);
      expect(ExpenseCategory.fromId('Lainnya'), isNull);
      expect(ExpenseCategory.fromId(null), isNull);
    });
  });

  group('ExpenseModel Date Helpers', () {
    test('isToday and isYesterday return correct boolean based on createdAt', () {
      final now = DateTime.now();
      final todayExpense = ExpenseModel(
        id: 1,
        amount: 20000,
        createdAt: now,
      );
      final yesterdayExpense = ExpenseModel(
        id: 2,
        amount: 30000,
        createdAt: now.subtract(const Duration(days: 1)),
      );
      final twoDaysAgoExpense = ExpenseModel(
        id: 3,
        amount: 40000,
        createdAt: now.subtract(const Duration(days: 2)),
      );

      expect(todayExpense.isToday, isTrue);
      expect(todayExpense.isYesterday, isFalse);
      expect(todayExpense.formattedTime, startsWith('Hari ini,'));

      expect(yesterdayExpense.isToday, isFalse);
      expect(yesterdayExpense.isYesterday, isTrue);
      expect(yesterdayExpense.formattedTime, startsWith('Kemarin,'));

      expect(twoDaysAgoExpense.isToday, isFalse);
      expect(twoDaysAgoExpense.isYesterday, isFalse);
    });
  });
}
