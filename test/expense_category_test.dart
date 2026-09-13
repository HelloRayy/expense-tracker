import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';
import 'package:jajan_tracker/features/categories/models/expense_category.dart';

void main() {
  group('ExpenseCategory Model & Normalizer Tests', () {
    test('all contains 3 canonical categories with expected ids', () {
      expect(ExpenseCategory.all.length, 3);
      expect(ExpenseCategory.all.map((c) => c.id).toList(), [
        'Makanan / Minuman',
        'Transportasi',
        'Lainnya',
      ]);
    });

    test('fromId normalizes aliases and casing accurately', () {
      expect(ExpenseCategory.fromId('Makanan'), ExpenseCategory.makananMinuman);
      expect(ExpenseCategory.fromId('makanan'), ExpenseCategory.makananMinuman);
      expect(ExpenseCategory.fromId('Kopi'), ExpenseCategory.makananMinuman);
      expect(ExpenseCategory.fromId('Kopi & Minum'), ExpenseCategory.makananMinuman);
      expect(ExpenseCategory.fromId('minum'), ExpenseCategory.makananMinuman);
      expect(ExpenseCategory.fromId('Transport'), ExpenseCategory.transportasi);
      expect(ExpenseCategory.fromId('transpor'), ExpenseCategory.transportasi);
      expect(ExpenseCategory.fromId('Belanja'), ExpenseCategory.lainnya);
      expect(ExpenseCategory.fromId('Belanja/QRIS'), ExpenseCategory.lainnya);
      expect(ExpenseCategory.fromId('qris'), ExpenseCategory.lainnya);
      expect(ExpenseCategory.fromId('Lainnya'), ExpenseCategory.lainnya);
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
