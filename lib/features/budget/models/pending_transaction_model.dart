/// Data model representing a passively detected transaction from notifications
/// (e.g. ShopeePay, GoPay, DANA, QRIS Bank) that has not yet been recorded.
class PendingTransactionModel {
  final int? id;
  final int amount;
  final String source;
  final String rawTitle;
  final DateTime createdAt;
  final bool isRecorded;

  const PendingTransactionModel({
    this.id,
    required this.amount,
    required this.source,
    this.rawTitle = '',
    required this.createdAt,
    this.isRecorded = false,
  });

  factory PendingTransactionModel.fromMap(Map<String, dynamic> map) {
    return PendingTransactionModel(
      id: map['id'] as int?,
      amount: map['amount'] as int? ?? 0,
      source: (map['source'] as String?) ?? 'ShopeePay',
      rawTitle: (map['raw_title'] as String?) ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      isRecorded: (map['is_recorded'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'source': source,
      'raw_title': rawTitle,
      'created_at': createdAt.toIso8601String(),
      'is_recorded': isRecorded ? 1 : 0,
    };
  }
}
