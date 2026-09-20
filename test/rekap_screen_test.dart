import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/core/constants/ui_keys.dart';
import 'package:jajan_tracker/core/services/app_settings_controller.dart';
import 'package:jajan_tracker/core/utils/currency_formatter.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';
import 'package:jajan_tracker/features/budget/models/pending_transaction_model.dart';
import 'package:jajan_tracker/features/budget/repository/budget_repository.dart';
import 'package:jajan_tracker/features/dashboard/dashboard_screen.dart';
import 'package:jajan_tracker/features/rekap/screens/rekap_screen.dart';

class MockRekapBudgetRepo extends ChangeNotifier implements BudgetRepository {
  List<ExpenseModel> testExpenses;

  MockRekapBudgetRepo({required this.testExpenses});

  @override
  BudgetModel? get budget => BudgetModel.createDefault(income: 1500000, savings: 500000);

  @override
  List<ExpenseModel> get expenses => testExpenses;

  @override
  List<PendingTransactionModel> get pendingTransactions => [];

  @override
  int get pendingCount => 0;

  @override
  int get totalSpent => testExpenses.where((e) => !e.isIncome).fold(0, (sum, e) => sum + e.amount);

  @override
  bool get isLoading => false;

  @override
  int get remainingBalance => 1500000 - totalSpent;

  @override
  int get dailyAllowance => 50000;

  @override
  double get spendingPercentage => totalSpent / 1500000;

  @override
  int get weeklyIncome => 1500000;

  @override
  int get weeklySavingsTarget => 500000;

  @override
  int get spendableBudget => 1000000;

  @override
  int get remainingWeeklySpendable => spendableBudget - totalSpent;

  @override
  int get effectiveWeeklySpendable => remainingWeeklySpendable;

  @override
  int get carryoverBalance => 0;

  @override
  bool get isPeriodConfirmed => true;

  @override
  int get spentUntilYesterday => 0;

  @override
  int get spentToday => totalSpent;

  @override
  int get remainingToday => 50000;

  @override
  int get initialCash => 0;

  @override
  int get cashSpent => testExpenses.where((e) => !e.isIncome && e.walletType == 'cash').fold(0, (sum, e) => sum + e.amount);

  @override
  int get cashIncome => 0;

  @override
  int get cashBalance => 0;

  @override
  int get ewalletSpent => testExpenses.where((e) => !e.isIncome && e.walletType != 'cash').fold(0, (sum, e) => sum + e.amount);

  @override
  int get ewalletBalance => 1500000 - ewalletSpent;

  @override
  bool get isOverBudgetToday => false;

  @override
  bool get isSavingsAtRisk => false;

  @override
  Future<void> loadData() async {}

  @override
  Future<void> addExpense(int amount, {String note = 'Jajan', String? categoryId, bool isIncome = false, String walletType = 'ewallet'}) async {}

  @override
  Future<void> updateExpense(ExpenseModel expense) async {}

  @override
  Future<void> addTopUp(int amount, {bool allocateToSavings = false, String note = 'Top Up Saldo', String walletType = 'ewallet'}) async {}

  @override
  Future<void> adjustRealBalance({required int actualBalance, bool allocateToSavings = false, String walletType = 'ewallet'}) async {}

  @override
  Future<void> deleteExpense(int id) async {}

  @override
  Future<void> resetAllExpenses() async {}

  @override
  Future<void> confirmWeeklyBudget({required int newIncome, int? carryover, int? savingsTarget, int? initialCash}) async {}

  @override
  Future<void> updateBudget({int? weeklyIncome, int? weeklySavingsTarget, int? totalBudget, int? carryoverBalance, int? initialCash, bool? isPeriodConfirmed, int? paydayDay}) async {}

  @override
  Future<void> batchAssignCategory({required List<int> assignIds, required String targetCategoryId, required List<int> unassignIds}) async {}

  @override
  Future<void> batchAssignMultiCategories(Map<int, String?> categoryUpdates) async {}

  @override
  Future<void> resolvePendingTransaction(int pendingId, int amount, {String note = 'Jajan', String? categoryId}) async {}

  @override
  Future<void> dismissPendingTransaction(int pendingId) async {}

  @override
  Future<List<ExpenseModel>> getExpensesForPeriod(DateTime start, DateTime end) async {
    return testExpenses.where((e) {
      return (e.createdAt.isAfter(start) || e.createdAt.isAtSameMomentAs(start)) &&
          (e.createdAt.isBefore(end) || e.createdAt.isAtSameMomentAs(end));
    }).toList();
  }

  @override
  Future<List<ExpenseModel>> getAllExpensesHistory() async {
    return List.unmodifiable(testExpenses);
  }
}

void main() {
  final now = DateTime.now();
  final monday = BudgetModel.getMondayOfWeek(now);
  final sampleExpenses = [
    ExpenseModel(
      id: 1,
      amount: 45000,
      note: 'Nasi Padang Spesial',
      categoryId: 'Makanan / Minuman',
      walletType: 'ewallet',
      createdAt: monday.add(const Duration(minutes: 10)),
    ),
    ExpenseModel(
      id: 2,
      amount: 25000,
      note: 'Kopi Kenangan Mantan',
      categoryId: 'Makanan / Minuman',
      walletType: 'ewallet',
      createdAt: monday.add(const Duration(minutes: 20)),
    ),
    ExpenseModel(
      id: 3,
      amount: 20000,
      note: 'Bensin Pertalite',
      categoryId: 'Transportasi',
      walletType: 'cash',
      createdAt: monday.add(const Duration(minutes: 30)),
    ),
    ExpenseModel(
      id: 4,
      amount: 15000,
      note: 'Parkir & Lainnya',
      categoryId: 'Lainnya',
      walletType: 'cash',
      createdAt: monday.add(const Duration(minutes: 40)),
    ),
  ];

  group('RekapScreen Widget Tests', () {
    testWidgets('renders all summary, category, wallet, and top expense sections when cash wallet is enabled', (tester) async {
      AppSettingsController.instance.setCashWalletEnabledForTest(true);
      addTearDown(() => AppSettingsController.instance.setCashWalletEnabledForTest(false));

      final repo = MockRekapBudgetRepo(testExpenses: sampleExpenses);

      await tester.pumpWidget(
        MaterialApp(
          home: RekapScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Verify core components exist
      expect(find.byKey(UIKeys.rekapScreen), findsOneWidget);
      expect(find.byKey(UIKeys.rekapPeriodTabBar), findsOneWidget);
      expect(find.byKey(UIKeys.rekapSummaryCard), findsOneWidget);
      expect(find.byKey(UIKeys.rekapCategoryBreakdown), findsOneWidget);
      expect(find.byKey(UIKeys.rekapWalletBreakdown, skipOffstage: false), findsOneWidget);
      expect(find.byKey(UIKeys.rekapTopExpensesList, skipOffstage: false), findsOneWidget);

      // Verify Total Spent calculation (45000 + 25000 + 20000 + 15000 = 105.000)
      expect(find.text('Rp 105.000'), findsWidgets);
      expect(find.text('4 Transaksi'), findsOneWidget);

      // Scroll to bottom to verify wallet and top expenses
      await tester.scrollUntilVisible(find.byKey(UIKeys.rekapTopExpensesList), 200);
      await tester.pumpAndSettle();

      // Verify Top Expenses has 'Nasi Padang Spesial' as rank 1
      expect(find.text('Nasi Padang Spesial'), findsOneWidget);
      expect(find.text('Rp 45.000'), findsOneWidget);

      // Verify Wallet Distribution has E-Wallet and Cash
      expect(find.text('E-Wallet'), findsOneWidget);
      expect(find.text('Uang Tunai'), findsOneWidget);
      // E-Wallet total: 70.000 (45k + 25k)
      expect(find.text('Rp 70.000'), findsOneWidget);
      // Cash total: 35.000 (20k + 15k)
      expect(find.text('Rp 35.000'), findsOneWidget);
    });

    testWidgets('hides wallet distribution card when cash wallet is disabled in settings', (tester) async {
      AppSettingsController.instance.setCashWalletEnabledForTest(false);

      final repo = MockRekapBudgetRepo(testExpenses: sampleExpenses);

      await tester.pumpWidget(
        MaterialApp(
          home: RekapScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(UIKeys.rekapWalletBreakdown), findsNothing);
    });

    testWidgets('switching between period tabs updates data and period label', (tester) async {
      final repo = MockRekapBudgetRepo(testExpenses: sampleExpenses);

      await tester.pumpWidget(
        MaterialApp(
          home: RekapScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Bulan Ini'
      await tester.tap(find.text('Bulan Ini'));
      await tester.pumpAndSettle();
      expect(find.byKey(UIKeys.rekapSummaryCard), findsOneWidget);

      // Tap 'Semua'
      await tester.tap(find.text('Semua'));
      await tester.pumpAndSettle();
      expect(find.text('Seluruh Riwayat Transaksi'), findsOneWidget);
      expect(find.byKey(UIKeys.rekapSummaryCard), findsOneWidget);
    });

    testWidgets('displays empty state gracefully when no expenses recorded', (tester) async {
      final repo = MockRekapBudgetRepo(testExpenses: []);

      await tester.pumpWidget(
        MaterialApp(
          home: RekapScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Pengeluaran'), findsOneWidget);
      expect(find.byKey(UIKeys.rekapSummaryCard), findsNothing);
    });

    testWidgets('Dashboard navbar bar chart icon navigates to RekapScreen', (tester) async {
      final repo = MockRekapBudgetRepo(testExpenses: sampleExpenses);

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      // Find bar chart icon in FloatingCapsuleNavbar
      final rekapNavIcon = find.byIcon(Icons.bar_chart_rounded);
      expect(rekapNavIcon, findsOneWidget);

      await tester.tap(rekapNavIcon);
      await tester.pumpAndSettle();

      // Verify RekapScreen is pushed to navigation stack
      expect(find.byKey(UIKeys.rekapScreen), findsOneWidget);
      expect(find.text('Rekap Pengeluaran'), findsOneWidget);
    });
  });
}
