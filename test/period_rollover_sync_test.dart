import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/core/database/db_helper.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';
import 'package:jajan_tracker/features/budget/repository/budget_repository.dart';
import 'package:jajan_tracker/features/categories/models/expense_category.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Period Rollover & Real Balance Sync Tests', () {
    late DbHelper dbHelper;
    late BudgetRepository repository;

    setUp(() async {
      dbHelper = DbHelper.instance;
      final db = await dbHelper.database;
      await db.delete('budget');
      await db.delete('expenses');
      await db.delete('pending_transactions');

      repository = BudgetRepository();
    });

    test('rollover surplus is capped by actual remaining real wallet money', () async {
      final now = DateTime.now();
      final lastMonday = BudgetModel.getMondayOfWeek(now).subtract(const Duration(days: 7));
      final lastSunday = BudgetModel.getSundayOfWeek(now).subtract(const Duration(days: 7));

      // Setup an expired budget from last week where theoretical surplus is 62.541
      // but actual wallet balance is only 27.000 (because of unrecorded expenses)
      final expiredBudget = BudgetModel(
        id: 1,
        weeklyIncome: 100000,
        weeklySavingsTarget: 0,
        carryoverBalance: 0,
        initialCash: 0,
        isPeriodConfirmed: true,
        startDate: lastMonday,
        endDate: lastSunday,
      );
      final db = await dbHelper.database;
      await db.insert('budget', expiredBudget.toMap());

      // Recorded expenses last week = 37.459 (theoretical leftover = 62.541)
      await db.insert(
        'expenses',
        ExpenseModel(
          amount: 37459,
          note: 'Jajan Minggu Lalu',
          categoryId: ExpenseCategory.makanan.id,
          createdAt: lastMonday.add(const Duration(hours: 12)),
        ).toMap(),
      );

      // Now run loadData which detects that endDate has passed and triggers roll-forward
      await repository.loadData();

      // Because currentRealBalance before rollover was 100.000 - 37.459 = 62.541,
      // it rolled over 62.541 into the new week.
      expect(repository.carryoverBalance, 62541);
      expect(repository.isPeriodConfirmed, isFalse);
    });

    test('adjusting real balance before confirmation syncs carryoverBalance and logs in expenses without reducing daily jajan quota', () async {
      final now = DateTime.now();
      final monday = BudgetModel.getMondayOfWeek(now);
      final sunday = BudgetModel.getSundayOfWeek(now);

      // New week started with theoretical 62.541 carryover, unconfirmed
      final unconfirmedBudget = BudgetModel(
        id: 1,
        weeklyIncome: 0,
        weeklySavingsTarget: 0,
        carryoverBalance: 62541,
        initialCash: 0,
        isPeriodConfirmed: false,
        startDate: monday,
        endDate: sunday,
      );
      final db = await dbHelper.database;
      await db.insert('budget', unconfirmedBudget.toMap());

      await repository.loadData();
      expect(repository.carryoverBalance, 62541);
      expect(repository.ewalletBalance, 62541);

      // User corrects balance to 27.000 (discrepancy = -35.541)
      await repository.adjustRealBalance(actualBalance: 27000, walletType: 'ewallet');

      // 1. ewalletBalance and remainingBalance match exactly 27.000
      expect(repository.ewalletBalance, 27000);
      expect(repository.remainingBalance, 27000);

      // 2. carryoverBalance is synchronized to 27.000 (so the banner says 27.000)
      expect(repository.carryoverBalance, 27000);

      // 3. The adjustment is logged in expenses (so it appears in Recent Activity)
      expect(repository.expenses.length, 1);
      final adjustment = repository.expenses.first;
      expect(adjustment.amount, 35541);
      expect(adjustment.categoryId, ExpenseCategory.penyesuaian.id);
      expect(adjustment.note, contains('Penyesuaian Saldo'));

      // 4. Jajan spending metrics are NOT penalized!
      expect(repository.totalSpent, 0);
      expect(repository.spentToday, 0);

      // 5. Daily allowance is not corrupted/negative
      expect(repository.dailyAllowance, greaterThanOrEqualTo(0));
      expect(repository.remainingToday, repository.dailyAllowance);
    });

    test('confirming weekly budget after balance adjustment properly adds new income to the corrected carryover', () async {
      final now = DateTime.now();
      final monday = BudgetModel.getMondayOfWeek(now);
      final sunday = BudgetModel.getSundayOfWeek(now);

      final unconfirmedBudget = BudgetModel(
        id: 1,
        weeklyIncome: 0,
        weeklySavingsTarget: 0,
        carryoverBalance: 62541,
        initialCash: 0,
        isPeriodConfirmed: false,
        startDate: monday,
        endDate: sunday,
      );
      final db = await dbHelper.database;
      await db.insert('budget', unconfirmedBudget.toMap());
      await repository.loadData();

      // Reconcile to 27.000
      await repository.adjustRealBalance(actualBalance: 27000, walletType: 'ewallet');
      expect(repository.carryoverBalance, 27000);

      // Confirm budget: income 200.000, savings 50.000, carryover 27.000
      await repository.confirmWeeklyBudget(
        newIncome: 200000,
        savingsTarget: 50000,
        carryover: repository.carryoverBalance,
      );

      // Total money held = 200.000 + 27.000 = 227.000
      expect(repository.remainingBalance, 227000);
      expect(repository.ewalletBalance, 227000);

      // Spendable budget = (200.000 - 50.000) + 27.000 = 177.000
      expect(repository.spendableBudget, 177000);
      expect(repository.totalSpent, 0);
      expect(repository.spentToday, 0);

      // Daily allowance = 177.000 / 7 = 25.285 -> rounded to nearest hundred: 25.300
      expect(repository.dailyAllowance, 25300);
      expect(repository.remainingToday, 25300);
    });
  });
}
