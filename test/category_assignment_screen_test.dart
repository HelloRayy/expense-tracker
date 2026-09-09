import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';
import 'package:jajan_tracker/features/budget/repository/budget_repository.dart';
import 'package:jajan_tracker/features/categories/screens/category_assignment_screen.dart';

class MockCategoryBudgetRepo extends ChangeNotifier implements BudgetRepository {
  List<ExpenseModel> testExpenses;
  List<int>? lastAssignIds;
  String? lastTargetCategoryId;
  List<int>? lastUnassignIds;
  int batchAssignCallCount = 0;

  MockCategoryBudgetRepo({required this.testExpenses});

  @override
  BudgetModel? get budget => BudgetModel.createDefault(total: 1500000, payday: 25);

  @override
  List<ExpenseModel> get expenses => testExpenses;

  @override
  int get totalSpent => testExpenses.fold(0, (sum, e) => sum + e.amount);

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
  Future<void> addExpense(int amount, {String note = 'Jajan'}) async {}

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
  }) async {
    batchAssignCallCount++;
    lastAssignIds = List.from(assignIds);
    lastTargetCategoryId = targetCategoryId;
    lastUnassignIds = List.from(unassignIds);
  }
}

void main() {
  late List<ExpenseModel> sampleExpenses;

  setUp(() {
    sampleExpenses = [
      ExpenseModel(
        id: 1,
        amount: 25000,
        note: 'Nasi Padang',
        categoryId: 'Makanan',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ExpenseModel(
        id: 2,
        amount: 18000,
        note: 'Kopi Kenangan',
        categoryId: 'Kopi & Minum',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ExpenseModel(
        id: 3,
        amount: 30000,
        note: 'Bensin Motor',
        categoryId: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  });

  testWidgets('CategoryAssignmentScreen renders initial transactions with correct pre-checked status', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = MockCategoryBudgetRepo(testExpenses: sampleExpenses);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: CategoryAssignmentScreen(
          repository: repo,
          selectedCategoryId: 'Makanan',
        ),
      ),
    );

    // Header checks
    expect(find.text('Makanan'), findsOneWidget);
    expect(find.text('Centang transaksi untuk memasukkan ke kategori ini.'), findsOneWidget);
    expect(find.text('Total: Rp 25rb'), findsOneWidget);

    // Transaction rows
    expect(find.text('Nasi Padang'), findsOneWidget);
    expect(find.text('Kopi Kenangan'), findsOneWidget);
    expect(find.text('• Kopi & Minum'), findsOneWidget);
    expect(find.text('Bensin Motor'), findsOneWidget);

    // Save bar initial state
    expect(find.text('Belum ada perubahan'), findsOneWidget);
    final saveButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Simpan'));
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('Toggling check/uncheck updates pending diff without triggering DB calls', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = MockCategoryBudgetRepo(testExpenses: sampleExpenses);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: CategoryAssignmentScreen(
          repository: repo,
          selectedCategoryId: 'Makanan',
        ),
      ),
    );

    // Tap 'Kopi Kenangan' to check it
    await tester.tap(find.text('Kopi Kenangan'));
    await tester.pumpAndSettle();

    // Reassign badge should appear
    expect(find.text('Pindah dari Kopi & Minum'), findsOneWidget);
    expect(find.text('1 perubahan belum disimpan'), findsOneWidget);
    expect(find.text('Total: Rp 43rb'), findsOneWidget); // 25k + 18k
    expect(repo.batchAssignCallCount, 0); // zero auto-save!

    // Tap 'Nasi Padang' to uncheck it
    await tester.tap(find.text('Nasi Padang'));
    await tester.pumpAndSettle();

    // Unassign badge should appear
    expect(find.text('Akan dicabut'), findsOneWidget);
    expect(find.text('2 perubahan belum disimpan'), findsOneWidget);
    expect(find.text('Total: Rp 18rb'), findsOneWidget);
    expect(repo.batchAssignCallCount, 0);

    // Revert 'Nasi Padang' (check again) and 'Kopi Kenangan' (uncheck again)
    await tester.tap(find.text('Nasi Padang'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kopi Kenangan'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada perubahan'), findsOneWidget);
    expect(find.text('Total: Rp 25rb'), findsOneWidget);
  });

  testWidgets('Tapping Simpan executes batchAssignCategory with computed minimal diff and pops', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = MockCategoryBudgetRepo(testExpenses: sampleExpenses);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryAssignmentScreen(
                        repository: repo,
                        selectedCategoryId: 'Makanan',
                      ),
                    ),
                  );
                },
                child: const Text('Open Assignment'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open screen
    await tester.tap(find.text('Open Assignment'));
    await tester.pumpAndSettle();

    // Assign 'Bensin Motor' (id: 3) to 'Makanan'
    await tester.tap(find.text('Bensin Motor'));
    await tester.pumpAndSettle();

    // Unassign 'Nasi Padang' (id: 1) from 'Makanan'
    await tester.tap(find.text('Nasi Padang'));
    await tester.pumpAndSettle();

    expect(find.text('2 perubahan belum disimpan'), findsOneWidget);

    // Tap 'Simpan'
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
    await tester.pumpAndSettle();

    // Verify repository was called with exact minimal diff
    expect(repo.batchAssignCallCount, 1);
    expect(repo.lastAssignIds, [3]);
    expect(repo.lastTargetCategoryId, 'Makanan');
    expect(repo.lastUnassignIds, [1]);

    // Verify screen popped back to root
    expect(find.text('Open Assignment'), findsOneWidget);
    expect(find.text('2 transaksi berhasil dimasukkan ke Makanan!'), findsOneWidget);
  });

  testWidgets('Tapping back button discards all pending changes without repository call', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = MockCategoryBudgetRepo(testExpenses: sampleExpenses);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryAssignmentScreen(
                        repository: repo,
                        selectedCategoryId: 'Makanan',
                      ),
                    ),
                  );
                },
                child: const Text('Open Assignment'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open screen
    await tester.tap(find.text('Open Assignment'));
    await tester.pumpAndSettle();

    // Select 'Bensin Motor'
    await tester.tap(find.text('Bensin Motor'));
    await tester.pumpAndSettle();
    expect(find.text('1 perubahan belum disimpan'), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Verify popped and zero repo calls
    expect(find.text('Open Assignment'), findsOneWidget);
    expect(repo.batchAssignCallCount, 0);
  });
}
