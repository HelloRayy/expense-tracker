import 'package:intl/intl.dart';

class BudgetModel {
  final int id;
  final int weeklyIncome; // uangMingguan
  final int weeklySavingsTarget; // nabungMinggu
  final DateTime startDate; // Monday 00:00:00
  final DateTime endDate; // Sunday 23:59:59

  BudgetModel({
    this.id = 1,
    int? weeklyIncome,
    int? weeklySavingsTarget,
    int? totalBudget,
    int? paydayDay,
    required this.startDate,
    required this.endDate,
  })  : weeklyIncome = weeklyIncome ?? totalBudget ?? 100000,
        weeklySavingsTarget = weeklySavingsTarget ?? ((weeklyIncome ?? totalBudget ?? 100000) * 0.3).round();

  /// Backward-compatible alias for total weekly money
  int get totalBudget => weeklyIncome;

  /// Total budget available for spending across the week
  int get spendableBudget => (weeklyIncome - weeklySavingsTarget).clamp(0, weeklyIncome);

  /// Day index in the week (1 = Monday, ..., 7 = Sunday)
  int get dayOfWeek {
    final now = DateTime.now();
    return now.weekday; // In Dart, Monday is 1 and Sunday is 7
  }

  int getDayOfWeek([DateTime? date]) {
    return (date ?? DateTime.now()).weekday;
  }

  int getDaysRemainingInWeek([DateTime? date]) {
    final dayIndex = (date ?? DateTime.now()).weekday;
    return (7 - (dayIndex - 1)).clamp(1, 7);
  }

  int get daysRemainingInWeek => getDaysRemainingInWeek();

  /// Backward-compatible alias for daysRemaining
  int get daysRemaining => daysRemainingInWeek;

  /// Backward-compatible alias for paydayDay
  int get paydayDay => 25;

  /// Calculates today's daily limit based on the adaptive rolling formula:
  /// sisaBudgetMingguIni = (weeklyIncome - weeklySavingsTarget) - spentUntilYesterday
  /// batasHarian = sisaBudgetMingguIni / daysRemainingInWeek
  int calculateDailyAllowance(int spentUntilYesterday, {DateTime? targetDate}) {
    if (spentUntilYesterday < 0) return 0;
    final remainingBudget = spendableBudget - spentUntilYesterday;
    if (remainingBudget <= 0) return 0;
    final daysLeft = getDaysRemainingInWeek(targetDate);
    final allowance = remainingBudget / daysLeft;
    // Round to nearest hundred for clean IDR display
    return (allowance / 100).round() * 100;
  }

  /// True if total spending in the week has exceeded weekly spendable budget
  bool isSavingsAtRisk(int totalSpent) {
    return totalSpent > spendableBudget;
  }

  String get formattedPeriod {
    try {
      final f = DateFormat('d MMM', 'id_ID');
      return '${f.format(startDate)} - ${f.format(endDate)}';
    } catch (_) {
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final startStr = '${startDate.day} ${months[startDate.month]}';
      final endStr = '${endDate.day} ${months[endDate.month]}';
      return '$startStr - $endStr';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weekly_income': weeklyIncome,
      'weekly_savings_target': weeklySavingsTarget,
      'total_budget': spendableBudget,
      'payday_day': 25,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    final income = map['weekly_income'] as int? ?? map['total_budget'] as int? ?? 100000;
    final savings = map['weekly_savings_target'] as int? ?? 30000;

    return BudgetModel(
      id: map['id'] as int? ?? 1,
      weeklyIncome: income,
      weeklySavingsTarget: savings,
      startDate: DateTime.tryParse(map['start_date'] as String? ?? '') ?? getMondayOfWeek(DateTime.now()),
      endDate: DateTime.tryParse(map['end_date'] as String? ?? '') ?? getSundayOfWeek(DateTime.now()),
    );
  }

  BudgetModel copyWith({
    int? id,
    int? weeklyIncome,
    int? weeklySavingsTarget,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      weeklyIncome: weeklyIncome ?? this.weeklyIncome,
      weeklySavingsTarget: weeklySavingsTarget ?? this.weeklySavingsTarget,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Calculates Monday 00:00:00 of the given week
  static DateTime getMondayOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// Calculates Sunday 23:59:59.999 of the given week
  static DateTime getSundayOfWeek(DateTime date) {
    final monday = getMondayOfWeek(date);
    return DateTime(monday.year, monday.month, monday.day + 6, 23, 59, 59, 999);
  }

  /// Creates a default weekly budget starting this Monday
  static BudgetModel createDefault({
    int? income,
    int? savings,
    int? total,
    int? payday,
  }) {
    final now = DateTime.now();
    return BudgetModel(
      weeklyIncome: income ?? total ?? 100000,
      weeklySavingsTarget: savings ?? 30000,
      startDate: getMondayOfWeek(now),
      endDate: getSundayOfWeek(now),
    );
  }
}
