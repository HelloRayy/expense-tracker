import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/core/constants/ui_keys.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';
import 'package:jajan_tracker/features/budget/repository/budget_repository.dart';
import 'package:jajan_tracker/features/dashboard/widgets/hero_balance_card.dart';

void main() {
  group('BudgetRepository tomorrowDailyAllowance Tests', () {
    test('Calculates tomorrow allowance correctly when today is normal', () {
      final repo = BudgetRepository();
      final monday = DateTime(2026, 9, 21); // Monday
      final sunday = DateTime(2026, 9, 27, 23, 59, 59);

      final budget = BudgetModel(
        weeklyIncome: 700000,
        weeklySavingsTarget: 0,
        startDate: monday,
        endDate: sunday,
      );

      // Spendable: 700.000.
      // Total spent so far: 100.000.
      repo.setForTest(
        budget: budget,
        totalSpent: 100000,
        spentUntilYesterday: 0,
        spentToday: 100000,
      );

      // Remaining budget for tomorrow = 700.000 - 100.000 = 600.000.
      // If tomorrow has N days remaining in week, allowance = 600.000 / N.
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final daysRemainingTomorrow = budget.getDaysRemainingInWeek(tomorrow);
      final expectedAllowance = ((600000 / daysRemainingTomorrow) / 100).round() * 100;

      expect(repo.tomorrowDailyAllowance, expectedAllowance);
    });

    test('Calculates tomorrow max jajan correctly when today is over budget (mines)', () {
      final repo = BudgetRepository();
      final now = DateTime.now();
      final budget = BudgetModel(
        weeklyIncome: 700000,
        weeklySavingsTarget: 0,
        startDate: BudgetModel.getMondayOfWeek(now),
        endDate: BudgetModel.getSundayOfWeek(now),
      );

      // Today daily allowance was set to 100k, but user spent 250k today!
      // Today is over budget by 150k (mines).
      repo.setForTest(
        budget: budget,
        totalSpent: 250000,
        spentUntilYesterday: 0,
        spentToday: 250000,
      );

      expect(repo.isOverBudgetToday, isTrue);

      final tomorrow = now.add(const Duration(days: 1));
      if (budget.daysRemainingInWeek <= 1) {
        // Today is Sunday, next week spendable = 700k + (700k - 250k) = 1.150.000 / 7
        final surplus = (700000 - 250000).clamp(0, 700000);
        final expected = (((700000 + surplus) / 7) / 100).round() * 100;
        expect(repo.tomorrowDailyAllowance, expected);
      } else {
        final daysRemainingTomorrow = budget.getDaysRemainingInWeek(tomorrow);
        final remainingWeekly = 700000 - 250000; // 450.000
        final expected = ((remainingWeekly / daysRemainingTomorrow) / 100).round() * 100;
        expect(repo.tomorrowDailyAllowance, expected);
      }
    });

    test('Returns 0 when entire weekly spendable budget is exhausted', () {
      final repo = BudgetRepository();
      final now = DateTime.now();
      final budget = BudgetModel(
        weeklyIncome: 700000,
        weeklySavingsTarget: 0,
        startDate: BudgetModel.getMondayOfWeek(now),
        endDate: BudgetModel.getSundayOfWeek(now),
      );

      // Total spent equals or exceeds weekly spendable
      repo.setForTest(
        budget: budget,
        totalSpent: 800000,
        spentUntilYesterday: 500000,
        spentToday: 300000,
      );

      if (budget.daysRemainingInWeek > 1) {
        expect(repo.tomorrowDailyAllowance, 0);
      }
    });
  });

  group('HeroBalanceCard Tomorrow Allowance Widget Tests', () {
    testWidgets('Renders heroTomorrowAllowance badge when isDaily is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroBalanceCard(
              remaining: 350000,
              spent: 150000,
              remainingToday: -50000, // Mines today
              tomorrowDailyAllowance: 85000,
              formattedPeriod: '21 Sep - 27 Sep',
              isOverBudget: true,
              textPrimary: Colors.white,
              textSecondary: Colors.grey,
              periodView: BudgetPeriodView.daily,
              onTapMenu: () {},
            ),
          ),
        ),
      );

      // Verify the negative amount is displayed
      expect(find.byKey(UIKeys.heroRemainingAmount), findsOneWidget);
      expect(find.text('-Rp 50.000'), findsOneWidget);

      // Verify heroTomorrowAllowance badge is displayed
      expect(find.byKey(UIKeys.heroTomorrowAllowance), findsOneWidget);
      expect(find.text('Besok max jajan: Rp 85.000'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('Hides heroTomorrowAllowance badge when periodView is weekly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroBalanceCard(
              remaining: 350000,
              spent: 150000,
              remainingToday: -50000,
              tomorrowDailyAllowance: 85000,
              formattedPeriod: '21 Sep - 27 Sep',
              isOverBudget: true,
              textPrimary: Colors.white,
              textSecondary: Colors.grey,
              periodView: BudgetPeriodView.weekly,
              onTapMenu: () {},
            ),
          ),
        ),
      );

      // When weekly view is active, daily projection is hidden
      expect(find.byKey(UIKeys.heroTomorrowAllowance), findsNothing);
      expect(find.text('Besok max jajan: Rp 85.000'), findsNothing);
    });
  });
}
