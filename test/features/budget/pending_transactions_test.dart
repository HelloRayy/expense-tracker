import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/features/budget/models/pending_transaction_model.dart';

void main() {
  group('PendingTransactionModel Tests', () {
    test('toMap and fromMap preserve transaction properties correctly', () {
      final now = DateTime(2026, 9, 13, 21, 30);
      final model = PendingTransactionModel(
        id: 1,
        amount: 35000,
        source: 'ShopeePay',
        rawTitle: 'Pembayaran ShopeePay Berhasil',
        createdAt: now,
        isRecorded: false,
      );

      final map = model.toMap();
      expect(map['id'], 1);
      expect(map['amount'], 35000);
      expect(map['source'], 'ShopeePay');
      expect(map['raw_title'], 'Pembayaran ShopeePay Berhasil');
      expect(map['is_recorded'], 0);

      final restored = PendingTransactionModel.fromMap(map);
      expect(restored.id, 1);
      expect(restored.amount, 35000);
      expect(restored.source, 'ShopeePay');
      expect(restored.rawTitle, 'Pembayaran ShopeePay Berhasil');
      expect(restored.isRecorded, false);
    });

    test('defaults isRecorded to false and handles missing rawTitle safely', () {
      final map = {
        'id': 2,
        'amount': 50000,
        'source': 'QRIS',
        'created_at': DateTime.now().toIso8601String(),
      };

      final model = PendingTransactionModel.fromMap(map);
      expect(model.id, 2);
      expect(model.amount, 50000);
      expect(model.source, 'QRIS');
      expect(model.rawTitle, '');
      expect(model.isRecorded, false);
    });
  });
}
