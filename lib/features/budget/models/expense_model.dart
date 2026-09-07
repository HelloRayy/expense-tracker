import 'package:intl/intl.dart';

class ExpenseModel {
  final int? id;
  final int amount;
  final String note;
  final DateTime createdAt;

  ExpenseModel({
    this.id,
    required this.amount,
    this.note = 'Jajan',
    required this.createdAt,
  });

  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

    final timeStr = DateFormat('HH:mm').format(createdAt);

    if (expenseDate == today) {
      return 'Hari ini, $timeStr';
    } else if (expenseDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin, $timeStr';
    } else {
      return DateFormat('d MMM, HH:mm', 'id_ID').format(createdAt);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'note': note.trim().isEmpty ? 'Jajan' : note.trim(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      amount: map['amount'] as int? ?? 0,
      note: map['note'] as String? ?? 'Jajan',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
