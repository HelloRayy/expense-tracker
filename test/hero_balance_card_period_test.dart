import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/core/services/app_settings_controller.dart';
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

  testWidgets('HeroBalanceCard shows single direct edit when cash wallet is disabled', (tester) async {
    AppSettingsController.instance.setCashWalletEnabledForTest(false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeroBalanceCard(
            remaining: 110000,
            spent: 40000,
            remainingToday: 20000,
            ewalletBalance: 110000,
            cashBalance: 0,
            formattedPeriod: '7 Sep - 13 Sep',
            isOverBudget: false,
            textPrimary: Colors.white,
            textSecondary: Colors.grey,
            onTapMenu: () {},
          ),
        ),
      ),
    );

    // Initial state: Sisa saldo has pen icon, no chevron
    expect(find.byIcon(Icons.south_west_rounded), findsOneWidget);
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
    expect(find.text('E-Wallet '), findsNothing);
    expect(find.text('Tunai '), findsNothing);
  });

  testWidgets('HeroBalanceCard accordion toggles E-Wallet and Tunai breakdown when cash wallet is enabled', (tester) async {
    AppSettingsController.instance.setCashWalletEnabledForTest(true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeroBalanceCard(
            remaining: 110000,
            spent: 40000,
            remainingToday: 20000,
            ewalletBalance: 110000,
            cashBalance: 0,
            formattedPeriod: '7 Sep - 13 Sep',
            isOverBudget: false,
            textPrimary: Colors.white,
            textSecondary: Colors.grey,
            onTapMenu: () {},
          ),
        ),
      ),
    );

    // Initial state: Sisa saldo is visible, chevron is visible
    expect(find.byIcon(Icons.south_west_rounded), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    expect(find.text('Rp 40.000'), findsOneWidget);

    // Tap on accordion toggle (the south_west icon / arrow)
    await tester.tap(find.byIcon(Icons.south_west_rounded));
    await tester.pumpAndSettle();

    // Verify breakdown is revealed with pen icons
    expect(find.text('E-Wallet '), findsOneWidget);
    expect(find.text('Tunai '), findsOneWidget);
    expect(find.byIcon(Icons.edit_rounded), findsNWidgets(2));

    // Tap again to collapse
    await tester.tap(find.byIcon(Icons.south_west_rounded));
    await tester.pumpAndSettle();

    // Reset back to false
    AppSettingsController.instance.setCashWalletEnabledForTest(false);
  });
}
