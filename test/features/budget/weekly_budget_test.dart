import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/features/budget/models/budget_model.dart';

void main() {
  group('Adaptive Weekly Savings Budget System - Section 6 Simulation', () {
    test('Simulates Section 6 table: 100k income, 30k savings, exact daily rolling', () {
      // Uang Mingguan: 100.000, Nabung Minggu: 30.000
      // Total budget jajan minggu ini = 100.000 - 30.000 = 70.000
      const weeklyIncome = 100000;
      const weeklySavingsTarget = 30000;

      // Mock Monday of week
      final monday = DateTime(2026, 9, 7); // Monday
      final sunday = DateTime(2026, 9, 13, 23, 59, 59, 999);

      final budget = BudgetModel(
        weeklyIncome: weeklyIncome,
        weeklySavingsTarget: weeklySavingsTarget,
        startDate: monday,
        endDate: sunday,
      );

      expect(budget.spendableBudget, 70000);

      // --- Hari 1 (Senin) ---
      // hariKe = 1, hariTersisa = 7
      // totalPengeluaranSampaiKemarin = 0
      // sisaBudget = 70.000
      // batasHarian = 70.000 / 7 = 10.000
      // pengeluaran aktual = 8.000
      final allowanceDay1 = budget.calculateDailyAllowance(0, targetDate: DateTime(2026, 9, 7));
      expect(allowanceDay1, 10000);
      const spentDay1 = 8000;

      // --- Hari 2 (Selasa) ---
      // hariKe = 2, hariTersisa = 6
      // totalPengeluaranSampaiKemarin = 8.000
      // sisaBudget = 70.000 - 8.000 = 62.000
      // batasHarian = 62.000 / 6 = 10.333 -> round to 100 = 10.300
      // pengeluaran aktual = 15.000
      final allowanceDay2 = budget.calculateDailyAllowance(spentDay1, targetDate: DateTime(2026, 9, 8));
      expect(allowanceDay2, 10300);
      const spentDay2 = 15000;

      // --- Hari 3 (Rabu) ---
      // hariKe = 3, hariTersisa = 5
      // totalPengeluaranSampaiKemarin = 8.000 + 15.000 = 23.000
      // sisaBudget = 70.000 - 23.000 = 47.000
      // batasHarian = 47.000 / 5 = 9.400
      // pengeluaran aktual = 5.000
      final spentUntilDay2 = spentDay1 + spentDay2;
      final allowanceDay3 = budget.calculateDailyAllowance(spentUntilDay2, targetDate: DateTime(2026, 9, 9));
      expect(allowanceDay3, 9400);
      const spentDay3 = 5000;

      // --- Hari 4 (Kamis) ---
      // hariKe = 4, hariTersisa = 4
      // totalPengeluaranSampaiKemarin = 28.000
      // sisaBudget = 70.000 - 28.000 = 42.000
      // batasHarian = 42.000 / 4 = 10.500
      // pengeluaran aktual = 10.500
      final spentUntilDay3 = spentUntilDay2 + spentDay3;
      final allowanceDay4 = budget.calculateDailyAllowance(spentUntilDay3, targetDate: DateTime(2026, 9, 10));
      expect(allowanceDay4, 10500);
      const spentDay4 = 10500;

      // --- Hari 5 (Jumat) ---
      // hariKe = 5, hariTersisa = 3
      // totalPengeluaranSampaiKemarin = 38.500
      // sisaBudget = 70.000 - 38.500 = 31.500
      // batasHarian = 31.500 / 3 = 10.500
      // pengeluaran aktual = 10.500
      final spentUntilDay4 = spentUntilDay3 + spentDay4;
      final allowanceDay5 = budget.calculateDailyAllowance(spentUntilDay4, targetDate: DateTime(2026, 9, 11));
      expect(allowanceDay5, 10500);
      const spentDay5 = 10500;

      // --- Hari 6 (Sabtu) ---
      // hariKe = 6, hariTersisa = 2
      // totalPengeluaranSampaiKemarin = 49.000
      // sisaBudget = 70.000 - 49.000 = 21.000
      // batasHarian = 21.000 / 2 = 10.500
      // pengeluaran aktual = 10.500
      final spentUntilDay5 = spentUntilDay4 + spentDay5;
      final allowanceDay6 = budget.calculateDailyAllowance(spentUntilDay5, targetDate: DateTime(2026, 9, 12));
      expect(allowanceDay6, 10500);
      const spentDay6 = 10500;

      // --- Hari 7 (Minggu) ---
      // hariKe = 7, hariTersisa = 1
      // totalPengeluaranSampaiKemarin = 59.500
      // sisaBudget = 70.000 - 59.500 = 10.500
      // batasHarian = 10.500 / 1 = 10.500
      // pengeluaran aktual = 10.500
      final spentUntilDay6 = spentUntilDay5 + spentDay6;
      final allowanceDay7 = budget.calculateDailyAllowance(spentUntilDay6, targetDate: DateTime(2026, 9, 13));
      expect(allowanceDay7, 10500);
      const spentDay7 = 10500;

      // Total Pengeluaran 1 Minggu
      final totalSpentWeek = spentDay1 + spentDay2 + spentDay3 + spentDay4 + spentDay5 + spentDay6 + spentDay7;
      expect(totalSpentWeek, 70000);

      // Sisa Uang Akhir Minggu = 100.000 - 70.000 = 30.000 (Target Tabungan Tercapai!)
      final remainingAtEnd = weeklyIncome - totalSpentWeek;
      expect(remainingAtEnd, weeklySavingsTarget);
      expect(budget.isSavingsAtRisk(totalSpentWeek), isFalse);
    });

    test('Savings at risk protection clamp to 0 when spendable exceeded', () {
      final budget = BudgetModel(
        weeklyIncome: 100000,
        weeklySavingsTarget: 30000,
        startDate: DateTime(2026, 9, 7),
        endDate: DateTime(2026, 9, 13, 23, 59, 59, 999),
      );

      // Spendable is 70.000. Spent until yesterday is 75.000.
      final allowance = budget.calculateDailyAllowance(75000, targetDate: DateTime(2026, 9, 10));
      expect(allowance, 0);
      expect(budget.isSavingsAtRisk(75000), isTrue);
    });

    test('Monday and Sunday calculations', () {
      final mon = BudgetModel.getMondayOfWeek(DateTime(2026, 9, 10)); // Thursday
      expect(mon.weekday, DateTime.monday);
      expect(mon.day, 7);

      final sun = BudgetModel.getSundayOfWeek(DateTime(2026, 9, 10));
      expect(sun.weekday, DateTime.sunday);
      expect(sun.day, 13);
    });

    test('Database serialization round-trip', () {
      final budget = BudgetModel(
        id: 1,
        weeklyIncome: 150000,
        weeklySavingsTarget: 50000,
        startDate: DateTime(2026, 9, 7),
        endDate: DateTime(2026, 9, 13, 23, 59, 59, 999),
      );

      final map = budget.toMap();
      expect(map['weekly_income'], 150000);
      expect(map['weekly_savings_target'], 50000);
      expect(map['total_budget'], 100000);

      final fromDb = BudgetModel.fromMap(map);
      expect(fromDb.weeklyIncome, 150000);
      expect(fromDb.weeklySavingsTarget, 50000);
      expect(fromDb.spendableBudget, 100000);
    });
  });
}
