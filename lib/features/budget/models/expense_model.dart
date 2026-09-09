import 'package:intl/intl.dart';

class ExpenseModel {
  final int? id;
  final int amount;
  final String note;
  final String? categoryId;
  final DateTime createdAt;

  ExpenseModel({
    this.id,
    required this.amount,
    this.note = 'Jajan',
    this.categoryId,
    required this.createdAt,
  });

  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return createdAt.year == yesterday.year &&
        createdAt.month == yesterday.month &&
        createdAt.day == yesterday.day;
  }

  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    if (isToday) {
      return 'Hari ini, $timeStr';
    } else if (isYesterday) {
      return 'Kemarin, $timeStr';
    } else {
      try {
        return DateFormat('d MMM, HH:mm', 'id_ID').format(createdAt);
      } catch (_) {
        const months = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
        ];
        return '${createdAt.day} ${months[createdAt.month]}, $timeStr';
      }
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'note': note.trim().isEmpty ? 'Jajan' : note.trim(),
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      amount: map['amount'] as int? ?? 0,
      note: map['note'] as String? ?? 'Jajan',
      categoryId: map['category_id'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  ExpenseModel copyWith({
    int? id,
    int? amount,
    String? note,
    String? categoryId,
    bool clearCategory = false,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
