// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/core/constants/app_colors.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';
import 'package:jajan_tracker/features/budget/repository/budget_repository.dart';
import 'package:jajan_tracker/features/dashboard/dashboard_screen.dart';
import 'package:jajan_tracker/features/quick_log/quick_log_dialog.dart';
import 'package:jajan_tracker/features/expense_catalog/screens/expense_catalog_screen.dart';
import 'package:jajan_tracker/features/settings/screens/budget_settings_detail_screen.dart';
import 'package:jajan_tracker/features/settings/screens/settings_screen.dart';
import 'package:jajan_tracker/features/categories/screens/category_assignment_screen.dart';

class MockBudgetRepo extends ChangeNotifier implements BudgetRepository {
  @override
  BudgetModel? get budget => BudgetModel.createDefault(total: 1500000, payday: 25);

  @override
  List<ExpenseModel> get expenses => [
    ExpenseModel(id: 1, amount: 25000, note: 'Kopi Kenangan', categoryId: 'Kopi & Minum', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    ExpenseModel(id: 2, amount: 35000, note: 'Nasi Padang Siang', categoryId: 'Makanan', createdAt: DateTime.now().subtract(const Duration(hours: 5))),
    ExpenseModel(id: 3, amount: 18000, note: 'Gojek Stasiun', categoryId: 'Transpor', createdAt: DateTime.now().subtract(const Duration(hours: 8))),
    ExpenseModel(id: 4, amount: 42000, note: 'ShopeePay Minimarket', categoryId: 'Belanja', createdAt: DateTime.now().subtract(const Duration(days: 1))),
    ExpenseModel(id: 5, amount: 50000, note: 'Bensin Motor', categoryId: 'Transpor', createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4))),
    ExpenseModel(id: 6, amount: 15000, note: 'Es Teh Manis', categoryId: 'Kopi & Minum', createdAt: DateTime.now().subtract(const Duration(days: 2))),
    ExpenseModel(id: 7, amount: 28000, note: 'Mie Ayam Bakso', categoryId: 'Makanan', createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3))),
    ExpenseModel(id: 8, amount: 20000, note: 'Cemilan Mart', categoryId: null, createdAt: DateTime.now().subtract(const Duration(days: 3))),
  ];

  @override
  int get totalSpent => 120000;

  @override
  bool get isLoading => false;

  @override
  int get remainingBalance => 1380000;

  @override
  int get dailyAllowance => 57500;

  @override
  double get spendingPercentage => 120000 / 1500000;

  @override
  int get weeklyIncome => 1500000;

  @override
  int get weeklySavingsTarget => 500000;

  @override
  int get spendableBudget => 1000000;

  @override
  int get remainingWeeklySpendable => 880000;

  @override
  int get spentUntilYesterday => 60000;

  @override
  int get spentToday => 60000;

  @override
  int get remainingToday => 30000;

  @override
  bool get isOverBudgetToday => false;

  @override
  bool get isSavingsAtRisk => false;

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
  }) async {}
}

Future<void> loadFonts() async {
  try {
    final regularData = File('/usr/share/fonts/rsms-inter-fonts/Inter-Regular.ttf').readAsBytesSync();
    final boldData = File('/usr/share/fonts/rsms-inter-fonts/Inter-Bold.ttf').readAsBytesSync();
    final semiBoldData = File('/usr/share/fonts/rsms-inter-fonts/Inter-SemiBold.ttf').readAsBytesSync();
    final fontLoader = FontLoader('Inter')
      ..addFont(Future.value(ByteData.view(regularData.buffer)))
      ..addFont(Future.value(ByteData.view(boldData.buffer)))
      ..addFont(Future.value(ByteData.view(semiBoldData.buffer)));
    await fontLoader.load();

    final matData = File('/home/rayhan/development/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf').readAsBytesSync();
    final matLoader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.view(matData.buffer)));
    await matLoader.load();
  } catch (e) {
    print('Font load error: $e');
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadFonts();
  });

  testWidgets('Capture QuickLogDialog real screenshot with Pirsch styling', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: PirschColors.darkBg,
        ),
        home: Scaffold(
          backgroundColor: PirschColors.darkBg,
          body: RepaintBoundary(
            key: boundaryKey,
            child: QuickLogDialog(repository: repo),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Type 5 000 + 3 000 to match Gambar 2 exactly
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('000'));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_pirsch_quick_log.png';
      File(outPath).writeAsBytesSync(bytes);
      print('PIRSCH QUICK LOG CAPTURE SAVED: $outPath');
    });

    // Clear and enter overbudget amount (70.000 > 57.500)
    await tester.tap(find.text('C'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('7'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('000'));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_pirsch_quick_log_warning.png';
      File(outPath).writeAsBytesSync(bytes);
      print('PIRSCH QUICK LOG WARNING CAPTURE SAVED: $outPath');
    });
  });

  testWidgets('Capture DashboardScreen real screenshot in Pirsch Dark Mode', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: PirschColors.darkBg,
        ),
        home: RepaintBoundary(
          key: boundaryKey,
          child: DashboardScreen(
            repository: repo,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_pirsch_dashboard_dark.png';
      File(outPath).writeAsBytesSync(bytes);
      print('PIRSCH DARK DASHBOARD SAVED: $outPath');
    });
  });

  testWidgets('Capture DashboardScreen real screenshot in Pirsch Light Mode', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.light,
          scaffoldBackgroundColor: PirschColors.lightBg,
        ),
        home: RepaintBoundary(
          key: boundaryKey,
          child: DashboardScreen(
            repository: repo,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_pirsch_dashboard_light.png';
      File(outPath).writeAsBytesSync(bytes);
      print('PIRSCH LIGHT DASHBOARD SAVED: $outPath');
    });
  });

  testWidgets('Verify DashboardScreen on narrow 360dp phone has zero overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0; // exactly 360dp width
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: PirschColors.darkBg,
        ),
        home: DashboardScreen(repository: repo),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Verify capping at 5 transactions and toggling expand/collapse', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = MockBudgetRepo();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: PirschColors.darkBg,
        ),
        home: DashboardScreen(repository: repo),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    // Verify 5 items shown initially
    expect(find.text('5 dari 8'), findsOneWidget);
    expect(find.text('Kopi Kenangan'), findsOneWidget);
    expect(find.text('Bensin Motor'), findsOneWidget); // 5th item
    expect(find.text('Es Teh Manis'), findsNothing); // 6th item not shown

    // Tap badge to expand
    await tester.tap(find.text('5 dari 8'));
    await tester.pumpAndSettle();

    // Now all 8 items shown
    expect(find.text('8 Transaksi'), findsOneWidget);
  });

  testWidgets('Capture SettingsScreen real screenshot', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: PirschColors.darkBg,
        ),
        home: RepaintBoundary(
          key: boundaryKey,
          child: SettingsScreen(repository: repo),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_settings_screen.png';
      File(outPath).writeAsBytesSync(bytes);
      print('SETTINGS SCREEN SAVED: $outPath');
    });
  });

  testWidgets('Capture BudgetSettingsDetailScreen real screenshot', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: PirschColors.darkBg,
        ),
        home: RepaintBoundary(
          key: boundaryKey,
          child: BudgetSettingsDetailScreen(repository: repo),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_budget_settings_detail.png';
      File(outPath).writeAsBytesSync(bytes);
      print('BUDGET SETTINGS DETAIL SAVED: $outPath');
    });
  });

  testWidgets('Capture SettingsScreen Light Mode real screenshot', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.light,
          scaffoldBackgroundColor: PirschColors.lightBg,
        ),
        home: RepaintBoundary(
          key: boundaryKey,
          child: SettingsScreen(repository: repo),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_settings_screen_light.png';
      File(outPath).writeAsBytesSync(bytes);
      print('SETTINGS SCREEN LIGHT SAVED: $outPath');
    });
  });

  testWidgets('Capture BudgetSettingsDetailScreen Light Mode real screenshot', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.light,
          scaffoldBackgroundColor: PirschColors.lightBg,
        ),
        home: RepaintBoundary(
          key: boundaryKey,
          child: BudgetSettingsDetailScreen(repository: repo),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_budget_settings_detail_light.png';
      File(outPath).writeAsBytesSync(bytes);
      print('BUDGET SETTINGS DETAIL LIGHT SAVED: $outPath');
    });
  });

  testWidgets('Capture ExpenseCatalogScreen Dark Mode real screenshot', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: PirschColors.darkBg,
        ),
        home: RepaintBoundary(
          key: boundaryKey,
          child: ExpenseCatalogScreen(repository: repo),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_expense_catalog_dark.png';
      File(outPath).writeAsBytesSync(bytes);
      print('EXPENSE CATALOG DARK SAVED: $outPath');
    });
  });

  testWidgets('Capture ExpenseCatalogScreen Light Mode real screenshot', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.light,
          scaffoldBackgroundColor: PirschColors.lightBg,
        ),
        home: RepaintBoundary(
          key: boundaryKey,
          child: ExpenseCatalogScreen(repository: repo),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_expense_catalog_light.png';
      File(outPath).writeAsBytesSync(bytes);
      print('EXPENSE CATALOG LIGHT SAVED: $outPath');
    });
  });

  testWidgets('Capture CategoryAssignmentScreen Dark Mode real screenshot', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: PirschColors.darkBg,
        ),
        home: RepaintBoundary(
          key: boundaryKey,
          child: CategoryAssignmentScreen(
            repository: repo,
            selectedCategoryId: 'Makanan',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_category_assignment_dark.png';
      File(outPath).writeAsBytesSync(bytes);
      print('CATEGORY ASSIGNMENT DARK SAVED: $outPath');
    });
  });

  testWidgets('Capture CategoryAssignmentScreen Light Mode real screenshot', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.light,
          scaffoldBackgroundColor: PirschColors.lightBg,
        ),
        home: RepaintBoundary(
          key: boundaryKey,
          child: CategoryAssignmentScreen(
            repository: repo,
            selectedCategoryId: 'Makanan',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_category_assignment_light.png';
      File(outPath).writeAsBytesSync(bytes);
      print('CATEGORY ASSIGNMENT LIGHT SAVED: $outPath');
    });
  });

  testWidgets('Capture CategoryAssignmentScreen Pending Changes real screenshot', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GlobalKey boundaryKey = GlobalKey();
    final repo = MockBudgetRepo();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: PirschColors.darkBg,
        ),
        home: RepaintBoundary(
          key: boundaryKey,
          child: CategoryAssignmentScreen(
            repository: repo,
            selectedCategoryId: 'Makanan',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Kopi Kenangan to reassign from Kopi & Minum -> Makanan
    await tester.tap(find.text('Kopi Kenangan'));
    await tester.pumpAndSettle();

    // Tap Nasi Padang Siang to unassign from Makanan
    await tester.tap(find.text('Nasi Padang Siang'));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_category_assignment_pending.png';
      File(outPath).writeAsBytesSync(bytes);
      print('CATEGORY ASSIGNMENT PENDING SAVED: $outPath');
    });
  });
}
