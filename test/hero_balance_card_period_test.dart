import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/features/dashboard/widgets/hero_balance_card.dart';

void main() {
  testWidgets('HeroBalanceCard toggles between daily and weekly view via dropdown', (tester) async {
    BudgetPeriodView currentView = BudgetPeriodView.daily;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return HeroBalanceCard(
                remaining: 150000,
                spent: 40000,
                remainingToday: 20000,
                remainingWeekly: 60000,
                formattedPeriod: '7 Sep - 13 Sep',
                isOverBudget: false,
                textPrimary: Colors.white,
                textSecondary: Colors.grey,
                periodView: currentView,
                onPeriodChanged: (newView) {
                  setState(() {
                    currentView = newView;
                  });
                },
                onTapPeriod: () {},
                onTapMenu: () {},
              );
            },
          ),
        ),
      ),
    );

    // Initial Daily State
    expect(find.text('hari ini ⌄'), findsOneWidget);
    expect(find.text('/ hari'), findsOneWidget);
    expect(find.text('Rp 20.000'), findsOneWidget);

    // Tap on dropdown anchor 'hari ini ⌄'
    await tester.tap(find.text('hari ini ⌄'));
    await tester.pumpAndSettle();

    // Verify Dropdown UI menu appears with 'Hari ini' and 'Mingguan'
    expect(find.text('Hari ini'), findsOneWidget);
    expect(find.text('Mingguan'), findsOneWidget);

    // Tap 'Mingguan'
    await tester.tap(find.text('Mingguan'));
    await tester.pumpAndSettle();

    // Verify Weekly State
    expect(find.text('mingguan ⌄'), findsOneWidget);
    expect(find.text('/ minggu'), findsOneWidget);
    expect(find.text('Rp 60.000'), findsOneWidget);

    // Tap on dropdown anchor 'mingguan ⌄' again
    await tester.tap(find.text('mingguan ⌄'));
    await tester.pumpAndSettle();

    // Tap 'Hari ini' to switch back
    await tester.tap(find.text('Hari ini'));
    await tester.pumpAndSettle();

    // Verify back to Daily State
    expect(find.text('hari ini ⌄'), findsOneWidget);
    expect(find.text('/ hari'), findsOneWidget);
    expect(find.text('Rp 20.000'), findsOneWidget);
  });
}
