import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';
import 'package:jajan_tracker/features/budget/repository/budget_repository.dart';
import 'package:jajan_tracker/features/expense_catalog/screens/expense_catalog_screen.dart';
import 'package:jajan_tracker/features/expense_catalog/widgets/catalog_preset_card.dart';

class MockBudgetRepo extends ChangeNotifier implements BudgetRepository {
  final List<ExpenseModel> added = [];

  @override
  BudgetModel? get budget => BudgetModel.createDefault(total: 1000000, payday: 25);

  @override
  List<ExpenseModel> get expenses => added;

  @override
  int get totalSpent => added.fold(0, (s, e) => s + e.amount);

  @override
  bool get isLoading => false;

  @override
  int get remainingBalance => 1000000 - totalSpent;

  @override
  int get dailyAllowance => 50000;

  @override
  double get spendingPercentage => totalSpent / 1000000;

  @override
  int get weeklyIncome => 1000000;

  @override
  int get weeklySavingsTarget => 300000;

  @override
  int get spendableBudget => 700000;

  @override
  int get remainingWeeklySpendable => 700000 - totalSpent;

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
    added.add(ExpenseModel(
      id: added.length + 1,
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

  @override
  Future<void> batchAssignCategory({
    required List<int> assignIds,
    required String targetCategoryId,
    required List<int> unassignIds,
  }) async {}
}

void main() {
  testWidgets('ExpenseCatalogScreen renders and logs expense on card tap without manual input', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: ExpenseCatalogScreen(repository: repo),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and starter cards are present
    expect(find.text('Katalog Jajan'), findsOneWidget);
    expect(find.text('Kopi Kenangan'), findsOneWidget);
    expect(find.text('Nasi Padang'), findsOneWidget);

    // Tap on Kopi Kenangan card
    final kopiCard = find.widgetWithText(CatalogPresetCard, 'Kopi Kenangan');
    await tester.tap(kopiCard);
    await tester.pumpAndSettle();

    // Verify expense is added immediately to repository
    expect(repo.added.length, 1);
    expect(repo.added.first.amount, 15000);
    expect(repo.added.first.note, 'Kopi Kenangan');

    // Verify feedback message
    expect(find.text('Kopi Kenangan berhasil dimasukkan!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('ExpenseCatalogScreen filters cards by category chip', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: ExpenseCatalogScreen(repository: repo),
      ),
    );
    await tester.pumpAndSettle();

    // Filter to 'Makanan'
    await tester.tap(find.widgetWithText(ChoiceChip, 'Makanan'));
    await tester.pumpAndSettle();

    // 'Nasi Padang' should be visible, 'Kopi Kenangan' should not
    expect(find.text('Nasi Padang'), findsOneWidget);
    expect(find.text('Kopi Kenangan'), findsNothing);
  });
}
