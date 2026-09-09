import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';
import 'package:jajan_tracker/features/budget/repository/budget_repository.dart';
import 'package:jajan_tracker/features/quick_log/quick_log_dialog.dart';

class TestBudgetRepo extends ChangeNotifier implements BudgetRepository {
  final List<ExpenseModel> addedExpenses = [];

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
  int get spentUntilYesterday => 0;

  @override
  int get spentToday => totalSpent;

  @override
  int get remainingToday => dailyAllowance - spentToday;

  @override
  bool get isOverBudgetToday => remainingToday < 0;

  @override
  bool get isSavingsAtRisk => totalSpent > spendableBudget;

  @override
  Future<void> loadData() async {}

  @override
  Future<void> addExpense(int amount, {String note = 'Jajan'}) async {
    addedExpenses.add(ExpenseModel(
      id: addedExpenses.length + 1,
      amount: amount,
      note: note,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  @override
  Future<void> deleteExpense(int id) async {}

  @override
  Future<void> resetAllExpenses() async {}

  @override
  Future<void> updateBudget({
    int? weeklyIncome,
    int? weeklySavingsTarget,
    int? totalBudget,
    int? paydayDay,
  }) async {}
}

void main() {
  testWidgets('QuickLogDialog standard calculator multiplication and submission', (WidgetTester tester) async {
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

    Finder keyBtn(String text) => find.widgetWithText(InkWell, text);

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

    // Tap submit (=)
    await tester.tap(keyBtn('='));
    await tester.pumpAndSettle();

    expect(repo.addedExpenses.length, 1);
    expect(repo.addedExpenses.first.amount, 50000);
    expect(repo.addedExpenses.first.note, 'Jajan');
  });

  testWidgets('QuickLogDialog keypad typing and division test', (WidgetTester tester) async {
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

    Finder keyBtn(String text) => find.widgetWithText(InkWell, text);

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

    // Submit (=)
    await tester.tap(keyBtn('='));
    await tester.pumpAndSettle();

    expect(repo.addedExpenses.length, 1);
    expect(repo.addedExpenses.first.amount, 25000);
    expect(repo.addedExpenses.first.note, 'Jajan');
  });
}
