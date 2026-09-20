import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/core/services/app_settings_controller.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';
import 'package:jajan_tracker/features/budget/models/pending_transaction_model.dart';
import 'package:jajan_tracker/features/budget/repository/budget_repository.dart';
import 'package:jajan_tracker/features/quick_log/quick_log_dialog.dart';

class TestBudgetRepo extends ChangeNotifier implements BudgetRepository {
  final List<ExpenseModel> addedExpenses = [];
  final List<PendingTransactionModel> _pendingTransactions = [];

  @override
  List<PendingTransactionModel> get pendingTransactions => _pendingTransactions;

  @override
  int get pendingCount => _pendingTransactions.length;

  @override
  Future<void> resolvePendingTransaction(int pendingId, int amount, {String note = 'Jajan', String? categoryId}) async {
    await addExpense(amount, note: note, categoryId: categoryId);
    _pendingTransactions.removeWhere((p) => p.id == pendingId);
    notifyListeners();
  }

  @override
  Future<void> dismissPendingTransaction(int pendingId) async {
    _pendingTransactions.removeWhere((p) => p.id == pendingId);
    notifyListeners();
  }

  @override
  BudgetModel? get budget => BudgetModel.createDefault(total: 1500000, payday: 25);

  @override
  List<ExpenseModel> get expenses => addedExpenses;

  @override
  int get totalSpent => addedExpenses.fold(0, (sum, e) => sum + e.amount);

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
  int get remainingWeeklySpendable => 1000000 - totalSpent;

  @override
  int get effectiveWeeklySpendable => 1000000;

  @override
  int get carryoverBalance => 0;

  @override
  bool get isPeriodConfirmed => true;

  @override
  int get spentUntilYesterday => 0;

  @override
  int get spentToday => totalSpent;

  @override
  int get remainingToday => dailyAllowance - spentToday;

  @override
  int get initialCash => 0;

  @override
  int get cashSpent => 0;

  @override
  int get cashIncome => 0;

  @override
  int get cashBalance => 0;

  @override
  int get ewalletSpent => totalSpent;

  @override
  int get ewalletBalance => remainingBalance;

  @override
  bool get isOverBudgetToday => remainingToday < 0;

  @override
  bool get isSavingsAtRisk => totalSpent > spendableBudget;

  @override
  Future<void> loadData() async {}

  @override
  Future<void> addExpense(int amount, {String note = 'Jajan', String? categoryId, bool isIncome = false, String walletType = 'ewallet'}) async {
    addedExpenses.add(ExpenseModel(
      id: addedExpenses.length + 1,
      amount: amount,
      note: note,
      categoryId: categoryId,
      isIncome: isIncome,
      walletType: walletType,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

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
  Future<void> confirmWeeklyBudget({
    required int newIncome,
    int? carryover,
    int? savingsTarget,
    int? initialCash,
  }) async {}

  @override
  Future<void> updateBudget({
    int? weeklyIncome,
    int? weeklySavingsTarget,
    int? totalBudget,
    int? carryoverBalance,
    int? initialCash,
    bool? isPeriodConfirmed,
    int? paydayDay,
  }) async {}

  @override
  Future<void> batchAssignCategory({
    required List<int> assignIds,
    required String targetCategoryId,
    required List<int> unassignIds,
  }) async {}

  @override
  Future<void> batchAssignMultiCategories(Map<int, String?> categoryUpdates) async {}
}

void main() {
  testWidgets('QuickLogDialog standard calculator multiplication and submission', (WidgetTester tester) async {
    AppSettingsController.instance.setCashWalletEnabledForTest(true);
    addTearDown(() => AppSettingsController.instance.setCashWalletEnabledForTest(false));

    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = TestBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: QuickLogDialog(repository: repo),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Finder keyBtn(String text) => text == '='
        ? find.byIcon(Icons.check_rounded)
        : find.widgetWithText(InkWell, text);

    // 25.000 × 2 = 50.000
    await tester.tap(keyBtn('2'));
    await tester.pumpAndSettle();
    await tester.tap(keyBtn('5'));
    await tester.pumpAndSettle();
    await tester.tap(keyBtn('000'));
    await tester.pumpAndSettle();
    await tester.tap(keyBtn('×'));
    await tester.pumpAndSettle();
    await tester.tap(keyBtn('2'));
    await tester.pumpAndSettle();

    // Verify preview shows 50.000
    expect(find.text('50.000'), findsOneWidget);

    // Select E-Wallet
    await tester.tap(find.text('E-Wallet'));
    await tester.pumpAndSettle();

    // Tap submit (=)
    await tester.tap(keyBtn('='));
    await tester.pumpAndSettle();

    expect(repo.addedExpenses.length, 1);
    expect(repo.addedExpenses.first.amount, 50000);
    expect(repo.addedExpenses.first.note, 'Makanan / Minuman');
    expect(repo.addedExpenses.first.walletType, 'ewallet');
  });

  testWidgets('QuickLogDialog keypad typing and division test with Cash selection', (WidgetTester tester) async {
    AppSettingsController.instance.setCashWalletEnabledForTest(true);
    addTearDown(() => AppSettingsController.instance.setCashWalletEnabledForTest(false));

    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = TestBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: QuickLogDialog(repository: repo),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Finder keyBtn(String text) => text == '='
        ? find.byIcon(Icons.check_rounded)
        : find.widgetWithText(InkWell, text);

    // Type 50.000 ÷ 2
    await tester.tap(keyBtn('5'));
    await tester.pumpAndSettle();
    await tester.tap(keyBtn('0'));
    await tester.pumpAndSettle();
    await tester.tap(keyBtn('000'));
    await tester.pumpAndSettle();

    // Tap division ÷ 2
    await tester.tap(keyBtn('÷'));
    await tester.pumpAndSettle();
    await tester.tap(keyBtn('2'));
    await tester.pumpAndSettle();

    expect(find.text('25.000'), findsOneWidget);

    // Select Tunai
    await tester.tap(find.text('Tunai'));
    await tester.pumpAndSettle();

    // Submit (=)
    await tester.tap(keyBtn('='));
    await tester.pumpAndSettle();

    expect(repo.addedExpenses.length, 1);
    expect(repo.addedExpenses.first.amount, 25000);
    expect(repo.addedExpenses.first.note, 'Makanan / Minuman');
    expect(repo.addedExpenses.first.walletType, 'cash');
  });

  testWidgets('QuickLogDialog blocks submit and triggers validation error when wallet is unselected', (WidgetTester tester) async {
    AppSettingsController.instance.setCashWalletEnabledForTest(true);
    addTearDown(() => AppSettingsController.instance.setCashWalletEnabledForTest(false));

    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = TestBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: QuickLogDialog(repository: repo),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Finder keyBtn(String text) => text == '='
        ? find.byIcon(Icons.check_rounded)
        : find.widgetWithText(InkWell, text);

    // Type 35.000
    await tester.tap(keyBtn('3'));
    await tester.pumpAndSettle();
    await tester.tap(keyBtn('5'));
    await tester.pumpAndSettle();
    await tester.tap(keyBtn('000'));
    await tester.pumpAndSettle();

    // Do NOT select wallet yet. Attempt submit (=)
    await tester.tap(keyBtn('='));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Submit should be blocked, no expense recorded
    expect(repo.addedExpenses.isEmpty, isTrue);

    // Error helper text should be visible
    expect(find.text('Pilih metode pembayaran (E-Wallet / Tunai)'), findsOneWidget);

    // Now user selects Tunai
    await tester.tap(find.text('Tunai'));
    await tester.pumpAndSettle();

    // Submit again (=)
    await tester.tap(keyBtn('='));
    await tester.pumpAndSettle();

    // Now it should succeed
    expect(repo.addedExpenses.length, 1);
    expect(repo.addedExpenses.first.amount, 35000);
    expect(repo.addedExpenses.first.walletType, 'cash');
  });

  testWidgets('QuickLogDialog automatically logs as ewallet when cash wallet is disabled', (WidgetTester tester) async {
    AppSettingsController.instance.setCashWalletEnabledForTest(false);

    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = TestBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: QuickLogDialog(repository: repo),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Finder keyBtn(String text) => text == '='
        ? find.byIcon(Icons.check_rounded)
        : find.widgetWithText(InkWell, text);

    // Wallet selector should not be present
    expect(find.text('E-Wallet'), findsNothing);
    expect(find.text('Tunai'), findsNothing);

    // Type 20.000 and submit immediately
    await tester.tap(keyBtn('2'));
    await tester.pumpAndSettle();
    await tester.tap(keyBtn('0'));
    await tester.pumpAndSettle();
    await tester.tap(keyBtn('000'));
    await tester.pumpAndSettle();

    await tester.tap(keyBtn('='));
    await tester.pumpAndSettle();

    expect(repo.addedExpenses.length, 1);
    expect(repo.addedExpenses.first.amount, 20000);
    expect(repo.addedExpenses.first.walletType, 'ewallet');
  });
}
