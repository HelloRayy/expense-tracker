import 'package:intl/intl.dart';

class BudgetModel {
  final int id;
  final int totalBudget;
  final int paydayDay; // 1 to 31
  final DateTime startDate;
  final DateTime endDate;

  BudgetModel({
    this.id = 1,
    required this.totalBudget,
    required this.paydayDay,
    required this.startDate,
    required this.endDate,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final diff = end.difference(today).inDays;
    return diff < 1 ? 1 : diff;
  }

  int get totalDaysInPeriod {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final diff = end.difference(start).inDays;
    return diff < 1 ? 1 : diff;
  }

  int calculateDailyAllowance(int remainingBalance) {
    if (remainingBalance <= 0) return 0;
    return (remainingBalance / daysRemaining).round();
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
      'total_budget': totalBudget,
      'payday_day': paydayDay,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int? ?? 1,
      totalBudget: map['total_budget'] as int? ?? 1000000,
      paydayDay: map['payday_day'] as int? ?? 25,
      startDate: DateTime.tryParse(map['start_date'] as String? ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(map['end_date'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
    );
  }

  BudgetModel copyWith({
    int? id,
    int? totalBudget,
    int? paydayDay,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      totalBudget: totalBudget ?? this.totalBudget,
      paydayDay: paydayDay ?? this.paydayDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Helper to safely clamp target day to max days of the month (e.g. 31 in Feb -> 28/29)
  static DateTime _safeDate(int year, int month, int targetDay) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final clamped = targetDay > lastDay ? lastDay : (targetDay < 1 ? 1 : targetDay);
    return DateTime(year, month, clamped);
  }

  /// Calculates the current period based on payday day
  static BudgetModel createDefault({int total = 1000000, int payday = 25}) {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    final todayClamped = _safeDate(now.year, now.month, payday);

    if (now.day >= todayClamped.day) {
      start = todayClamped;
      // Next month payday - 1 day
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      end = _safeDate(nextYear, nextMonth, payday).subtract(const Duration(days: 1));
    } else {
      // Previous month payday
      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;
      start = _safeDate(prevYear, prevMonth, payday);
      end = todayClamped.subtract(const Duration(days: 1));
    }

    return BudgetModel(
      totalBudget: total,
      paydayDay: payday,
      startDate: start,
      endDate: end,
    );
  }
}
