// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:jajan_tracker/features/budget/models/expense_model.dart';
import 'package:jajan_tracker/features/budget/repository/budget_repository.dart';
import 'package:jajan_tracker/features/dashboard/dashboard_screen.dart';
import 'package:jajan_tracker/features/quick_log/quick_log_dialog.dart';

class MockBudgetRepo extends ChangeNotifier implements BudgetRepository {
  @override
  BudgetModel? get budget => BudgetModel.createDefault(total: 1500000, payday: 25);
  @override
  List<ExpenseModel> get expenses => [
    ExpenseModel(id: 1, amount: 25000, note: 'Kopi Kenangan', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    ExpenseModel(id: 2, amount: 15000, note: 'Gorengan Kasir', createdAt: DateTime.now().subtract(const Duration(hours: 5))),
  ];
  @override
  int get totalSpent => 40000;
  @override
  bool get isLoading => false;
  @override
  int get remainingBalance => 1460000;
  @override
  int get dailyAllowance => 50000;
  @override
  double get spendingPercentage => 40000 / 1500000;
  @override
  Future<void> loadData() async {}
  @override
  Future<void> addExpense(int amount, {String note = 'Jajan'}) async {}
  @override
  Future<void> deleteExpense(int id) async {}
  @override
  Future<void> updateBudget({required int totalBudget, required int paydayDay}) async {}
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
  } catch (e) {
    print('Font load error: $e');
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadFonts();
  });

  testWidgets('Capture QuickLogDialog real screenshot with 7-8-9 numpad', (WidgetTester tester) async {
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
          scaffoldBackgroundColor: const Color(0xFF0F172A),
        ),
        home: Scaffold(
          backgroundColor: const Color(0xFF070B14),
          body: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(
                width: 392,
                child: QuickLogDialog(
                  repository: repo,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Type 2, 5, 000 on the new 7-8-9 keypad!
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('000'));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_app_quick_log.png';
      File(outPath).writeAsBytesSync(bytes);
      print('REAL FLUTTER APP SCREENSHOT SAVED: $outPath');
    });
  });

  testWidgets('Capture DashboardScreen real screenshot', (WidgetTester tester) async {
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
          scaffoldBackgroundColor: const Color(0xFF0F172A),
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

      final outPath = '/home/rayhan/.gemini/antigravity/brain/c3cf172f-5299-4a70-bc5d-1e40b03dd06d/actual_app_dashboard.png';
      File(outPath).writeAsBytesSync(bytes);
      print('REAL DASHBOARD SCREENSHOT SAVED: $outPath');
    });
  });
}
