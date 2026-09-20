import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/core/constants/ui_keys.dart';
import 'package:jajan_tracker/core/utils/currency_formatter.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';
import 'package:jajan_tracker/features/budget/models/pending_transaction_model.dart';
import 'package:jajan_tracker/features/budget/repository/budget_repository.dart';
import 'package:jajan_tracker/features/dashboard/widgets/balance_adjustment_sheet.dart';
import 'package:jajan_tracker/features/dashboard/widgets/edit_expense_sheet.dart';
import 'package:jajan_tracker/features/dashboard/widgets/weekly_budget_input_sheet.dart';
import 'package:jajan_tracker/features/expense_catalog/widgets/create_preset_card_dialog.dart';

class TestMockBudgetRepo extends ChangeNotifier implements BudgetRepository {
  int testEwalletBalance = 62541;
  int testCashBalance = 10000;
  int? adjustedBalance;
  int? topUpAmount;

  @override
  int get ewalletBalance => testEwalletBalance;

  @override
  int get cashBalance => testCashBalance;

  @override
  BudgetModel? get budget => BudgetModel.createDefault(total: 1500000, payday: 25);

  @override
  List<ExpenseModel> get expenses => [];

  @override
  List<PendingTransactionModel> get pendingTransactions => [];

  @override
  int get pendingCount => 0;

  @override
  int get totalSpent => 0;

  @override
  bool get isLoading => false;

  @override
  int get remainingBalance => 1500000;

  @override
  int get dailyAllowance => 50000;

  @override
  int get tomorrowDailyAllowance => 50000;

  @override
  void setForTest({BudgetModel? budget, List<ExpenseModel>? expenses, int? totalSpent, int? spentUntilYesterday, int? spentToday}) {}

  @override
  double get spendingPercentage => 0.0;

  @override
  int get weeklyIncome => 1500000;

  @override
  int get weeklySavingsTarget => 500000;

  @override
  int get spendableBudget => 1000000;

  @override
  int get remainingWeeklySpendable => 1000000;

  @override
  int get effectiveWeeklySpendable => 1000000;

  @override
  int get carryoverBalance => 0;

  @override
  bool get isPeriodConfirmed => true;

  @override
  int get spentUntilYesterday => 0;

  @override
  int get spentToday => 0;

  @override
  int get remainingToday => 50000;

  @override
  int get initialCash => 0;

  @override
  int get cashSpent => 0;

  @override
  int get cashIncome => 0;

  @override
  int get ewalletSpent => 0;

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
  Future<void> addTopUp(int amount, {bool allocateToSavings = false, String note = 'Top Up Saldo', String walletType = 'ewallet'}) async {
    topUpAmount = amount;
  }

  @override
  Future<void> adjustRealBalance({required int actualBalance, bool allocateToSavings = false, String walletType = 'ewallet'}) async {
    adjustedBalance = actualBalance;
  }

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
  Future<List<ExpenseModel>> getExpensesForPeriod(DateTime start, DateTime end) async => expenses;

  @override
  Future<List<ExpenseModel>> getAllExpensesHistory() async => expenses;
}

void main() {
  group('ThousandsSeparatorInputFormatter Unit Tests', () {
    late ThousandsSeparatorInputFormatter formatter;

    setUp(() {
      formatter = ThousandsSeparatorInputFormatter();
    });

    test('formats thousands input with dot (27000 -> 27.000)', () {
      final oldValue = const TextEditingValue(text: '2700', selection: TextSelection.collapsed(offset: 4));
      final newValue = const TextEditingValue(text: '27000', selection: TextSelection.collapsed(offset: 5));
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '27.000');
      expect(result.selection.end, 6);
    });

    test('formats tens of thousands (150000 -> 150.000)', () {
      final oldValue = const TextEditingValue(text: '15000', selection: TextSelection.collapsed(offset: 5));
      final newValue = const TextEditingValue(text: '150000', selection: TextSelection.collapsed(offset: 6));
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '150.000');
      expect(result.selection.end, 7);
    });

    test('formats millions (1000000 -> 1.000.000)', () {
      final oldValue = const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
      final newValue = const TextEditingValue(text: '1000000', selection: TextSelection.collapsed(offset: 7));
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '1.000.000');
      expect(result.selection.end, 9);
    });

    test('handles small numbers below a thousand without dots (500 -> 500)', () {
      final oldValue = const TextEditingValue(text: '50', selection: TextSelection.collapsed(offset: 2));
      final newValue = const TextEditingValue(text: '500', selection: TextSelection.collapsed(offset: 3));
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '500');
      expect(result.selection.end, 3);
    });

    test('handles empty input', () {
      final oldValue = const TextEditingValue(text: '10', selection: TextSelection.collapsed(offset: 2));
      final newValue = const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '');
    });

    test('handles backspace after dot smoothly (27.|000 -> 2.000)', () {
      final oldValue = const TextEditingValue(text: '27.000', selection: TextSelection.collapsed(offset: 3));
      final newValue = const TextEditingValue(text: '27000', selection: TextSelection.collapsed(offset: 2));
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '2.000');
      expect(result.selection.end, 1);
    });

    test('handles backspace on regular digit (27.000 -> 2.700)', () {
      final oldValue = const TextEditingValue(text: '27.000', selection: TextSelection.collapsed(offset: 6));
      final newValue = const TextEditingValue(text: '27.00', selection: TextSelection.collapsed(offset: 5));
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '2.700');
      expect(result.selection.end, 5);
    });

    test('CurrencyFormatter.parse correctly parses formatted strings with dots', () {
      expect(CurrencyFormatter.parse('27.000'), 27000);
      expect(CurrencyFormatter.parse('150.000'), 150000);
      expect(CurrencyFormatter.parse('1.000.000'), 1000000);
      expect(CurrencyFormatter.parse('Rp 35.541'), 35541);
      expect(CurrencyFormatter.parse(''), 0);
    });
  });

  group('Widget Tests - Formatted Currency Input Across App', () {
    testWidgets('BalanceAdjustmentSheet formats real balance input with dot (27000 -> 27.000)', (tester) async {
      final repo = TestMockBudgetRepo();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceAdjustmentSheet(repository: repo),
          ),
        ),
      );

      // Switch to Real Balance tab ("Koreksi Saldo")
      await tester.tap(find.text('Koreksi Saldo'));
      await tester.pumpAndSettle();

      final realBalanceInput = find.byKey(UIKeys.balanceSheetRealBalanceInput);
      expect(realBalanceInput, findsOneWidget);

      // Enter '27000'
      await tester.enterText(realBalanceInput, '27000');
      await tester.pumpAndSettle();

      // Verify text in the field is now '27.000'
      expect(find.text('27.000'), findsOneWidget);

      // Verify diff calculation: 27000 - 62541 = -35541
      expect(find.text('Kurang -Rp 35.541'), findsOneWidget);
    });

    testWidgets('BalanceAdjustmentSheet formats Top Up input with dot (50000 -> 50.000)', (tester) async {
      final repo = TestMockBudgetRepo();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceAdjustmentSheet(repository: repo),
          ),
        ),
      );

      final topUpInput = find.byKey(UIKeys.balanceSheetTopUpInput);
      expect(topUpInput, findsOneWidget);

      await tester.enterText(topUpInput, '50000');
      await tester.pumpAndSettle();

      expect(find.text('50.000'), findsOneWidget);
    });

    testWidgets('WeeklyBudgetInputSheet formats income and savings with dot', (tester) async {
      final repo = TestMockBudgetRepo();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklyBudgetInputSheet(repository: repo),
          ),
        ),
      );

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      // Enter income '150000'
      await tester.enterText(textFields.first, '150000');
      await tester.pumpAndSettle();

      // Income field has '150.000'
      expect(find.text('150.000'), findsOneWidget);
      // Auto-calculated savings (30% of 150.000 = 45.000)
      expect(find.text('45.000'), findsOneWidget);
    });

    testWidgets('EditExpenseSheet initializes with dot format and formats on edit', (tester) async {
      final repo = TestMockBudgetRepo();
      final expense = ExpenseModel(
        id: 1,
        amount: 25000,
        note: 'Kopi Kenangan',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditExpenseSheet(
              expense: expense,
              repository: repo,
            ),
          ),
        ),
      );

      // Should display initial amount formatted as '25.000'
      expect(find.text('25.000'), findsOneWidget);

      // Change amount to 35000
      final amountField = find.widgetWithText(TextField, '25.000');
      await tester.enterText(amountField, '35000');
      await tester.pumpAndSettle();

      expect(find.text('35.000'), findsOneWidget);
    });

    testWidgets('CreatePresetCardDialog formats amount with dot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreatePresetCardDialog(
              onCreated: (_) {},
            ),
          ),
        ),
      );

      final textFields = find.byType(TextField);
      final amountField = textFields.at(1);

      await tester.enterText(amountField, '25000');
      await tester.pumpAndSettle();

      expect(find.text('25.000'), findsOneWidget);
    });
  });
}
