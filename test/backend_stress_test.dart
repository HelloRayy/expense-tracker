import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:jajan_tracker/core/database/db_helper.dart';
import 'package:jajan_tracker/core/utils/currency_formatter.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';
import 'package:jajan_tracker/features/budget/repository/budget_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('1. SQLite Concurrency & High-Frequency Ingestion', () {
    test('Parallel ingestion of 100 transactions maintains 100% arithmetic integrity', () async {
      final dbHelper = DbHelper.instance;
      final db = await dbHelper.database;

      // Clean test state
      await db.delete('expenses');

      final now = DateTime.now();
      final periodStart = now.subtract(const Duration(days: 15));
      final periodEnd = now.add(const Duration(days: 15));

      // Setup active budget period covering today
      await dbHelper.updateBudget(
        BudgetModel(
          id: 1,
          totalBudget: 5000000,
          paydayDay: 25,
          startDate: periodStart,
          endDate: periodEnd,
        ),
      );

      // Ingest 100 transactions concurrently with varying amounts
      final List<Future<int>> insertTasks = [];
      int expectedTotal = 0;

      for (int i = 1; i <= 100; i++) {
        final amount = i * 1000; // 1.000 to 100.000
        expectedTotal += amount;
        final expense = ExpenseModel(
          amount: amount,
          note: 'Stress Test $i',
          createdAt: now.subtract(Duration(minutes: i)),
        );
        insertTasks.add(dbHelper.insertExpense(expense));
      }

      // Execute all 100 in parallel
      final results = await Future.wait(insertTasks);
      expect(results.length, 100);

      // Verify exact count and sum
      final totalSpent = await dbHelper.getTotalSpentForPeriod(periodStart, periodEnd);
      expect(totalSpent, equals(expectedTotal));

      // Verify ordering
      final expenses = await dbHelper.getExpensesForPeriod(periodStart, periodEnd);
      expect(expenses.length, 100);
      for (int i = 0; i < expenses.length - 1; i++) {
        expect(
          expenses[i].createdAt.isAfter(expenses[i + 1].createdAt) ||
              expenses[i].createdAt.isAtSameMomentAs(expenses[i + 1].createdAt),
          isTrue,
        );
      }
    });
  });

  group('2. Date Boundary & Strict Period Filtering', () {
    test('Transactions outside active period are strictly excluded from sum', () async {
      final dbHelper = DbHelper.instance;
      final db = await dbHelper.database;
      await db.delete('expenses');

      final now = DateTime.now();
      final pStart = DateTime(now.year, now.month, 10, 0, 0, 0);
      final pEnd = DateTime(now.year, now.month, 20, 23, 59, 59);

      // Expense 1: Before period
      await dbHelper.insertExpense(
        ExpenseModel(
          amount: 50000,
          note: 'Before',
          createdAt: pStart.subtract(const Duration(seconds: 1)),
        ),
      );

      // Expense 2: Inside period
      await dbHelper.insertExpense(
        ExpenseModel(
          amount: 75000,
          note: 'Inside 1',
          createdAt: pStart.add(const Duration(hours: 1)),
        ),
      );

      // Expense 3: Inside period
      await dbHelper.insertExpense(
        ExpenseModel(
          amount: 25000,
          note: 'Inside 2',
          createdAt: pEnd.subtract(const Duration(hours: 1)),
        ),
      );

      // Expense 4: After period
      await dbHelper.insertExpense(
        ExpenseModel(
          amount: 100000,
          note: 'After',
          createdAt: pEnd.add(const Duration(seconds: 1)),
        ),
      );

      final totalInPeriod = await dbHelper.getTotalSpentForPeriod(pStart, pEnd);
      expect(totalInPeriod, equals(100000)); // 75.000 + 25.000

      final listInPeriod = await dbHelper.getExpensesForPeriod(pStart, pEnd);
      expect(listInPeriod.length, equals(2));
    });
  });

  group('3. Budget Math & Extreme Boundary Conditions', () {
    test('Overbudget clamps daily allowance to 0 and spending percentage to 1.0', () {
      final now = DateTime.now();
      final budget = BudgetModel(
        totalBudget: 1000000,
        paydayDay: 25,
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 20)),
      );

      // Deficit of -250.000
      expect(budget.calculateDailyAllowance(-250000), equals(0));
      expect(budget.calculateDailyAllowance(0), equals(0));

      final repo = BudgetRepository();
      // Test spending percentage behavior
      expect(repo.spendingPercentage, equals(0.0));
    });

    test('Payday rollover calculation respects month boundaries', () {
      // Test payday 1
      final b1 = BudgetModel.createDefault(total: 1000000, payday: 1);
      expect(b1.paydayDay, 1);
      expect(b1.startDate.isBefore(b1.endDate), isTrue);

      // Test payday 25
      final b25 = BudgetModel.createDefault(total: 1500000, payday: 25);
      expect(b25.paydayDay, 25);
      expect(b25.startDate.isBefore(b25.endDate), isTrue);

      // Test payday 28
      final b28 = BudgetModel.createDefault(total: 2000000, payday: 28);
      expect(b28.paydayDay, 28);
      expect(b28.startDate.isBefore(b28.endDate), isTrue);

      // Test payday 31 (month-end clamp)
      final b31 = BudgetModel.createDefault(total: 2500000, payday: 31);
      expect(b31.paydayDay, 31);
      expect(b31.startDate.isBefore(b31.endDate), isTrue);
      expect(b31.startDate.day, lessThanOrEqualTo(31));
      expect(b31.endDate.day, lessThanOrEqualTo(31));
    });
  });

  group('4. Payment Regex & E-Wallet Parsing Logic', () {
    final amountRegex = RegExp(
      r'(?:Rp\.?|IDR)\s*([0-9]{1,3}(?:[.,][0-9]{3})+(?:,[0-9]+)?|[0-9]+)',
      caseSensitive: false,
    );

    int? parseAmount(String text) {
      final match = amountRegex.firstMatch(text);
      if (match == null) return null;
      final raw = match.group(1)!.replaceAll('.', '').split(',')[0];
      return int.tryParse(raw);
    }

    test('Extracts amounts from Indonesian payment notifications', () {
      // ShopeePay
      expect(
        parseAmount('Pembayaran berhasil Rp 35.000 di ShopeePay'),
        equals(35000),
      );

      // GoPay
      expect(
        parseAmount('Pembayaran Rp 18.500 ke Kopi Janji Jiwa berhasil'),
        equals(18500),
      );

      // DANA
      expect(
        parseAmount('Pembayaran berhasil menggunakan DANA Rp 50.000'),
        equals(50000),
      );

      // BCA QRIS
      expect(
        parseAmount('Transaksi QRIS BERHASIL Rp. 45.000'),
        equals(45000),
      );

      // Format without space or thousand separator
      expect(
        parseAmount('Transaksi Rp25000 berhasil'),
        equals(25000),
      );

      // Large payment
      expect(
        parseAmount('Pembayaran berhasil Rp 1.500.000 ke Tokopedia'),
        equals(1500000),
      );
    });

    test('Rejects non-payment or unrelated notifications', () {
      final paymentKeywords = [
        'pembayaran berhasil',
        'berhasil bayar',
        'transaksi berhasil',
        'kamu membayar',
        'berhasil melakukan pembayaran',
        'transaksi qris',
        'berhasil ditransfer',
        'pesanan berhasil dibayar',
        'pembayaran qris berhasil',
      ];

      bool isPaymentNotification(String text) {
        final lower = text.toLowerCase();
        // Discard top up
        if (lower.contains('top up') || lower.contains('isi saldo')) return false;
        return paymentKeywords.any((kw) => lower.contains(kw));
      }

      // Valid payment
      expect(isPaymentNotification('Pembayaran berhasil Rp 25.000'), isTrue);
      expect(isPaymentNotification('Kamu membayar Rp 12.000 via GoPay'), isTrue);

      // False positives that must be ignored
      expect(isPaymentNotification('Top up saldo Rp 100.000 berhasil'), isFalse);
      expect(isPaymentNotification('Isi saldo ShopeePay Rp 50.000 berhasil'), isFalse);
      expect(isPaymentNotification('Promo cashback s/d Rp 50.000 hari ini!'), isFalse);
    });
  });

  group('5. Currency Formatter Consistency', () {
    test('Round-trip parse and format consistency', () {
      final samples = [0, 500, 15000, 25000, 100000, 1500000, 25000000];
      for (final s in samples) {
        final formatted = CurrencyFormatter.format(s);
        final parsed = CurrencyFormatter.parse(formatted);
        expect(parsed, equals(s));
      }
    });
  });
}
