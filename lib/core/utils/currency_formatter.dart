import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _formatter.format(amount);
  }

  static String formatCompact(num amount) {
    if (amount >= 1000000) {
      final juta = (amount / 1000000).toStringAsFixed(1).replaceAll('.0', '');
      return 'Rp ${juta}jt';
    } else if (amount >= 1000) {
      final ribu = (amount / 1000).toStringAsFixed(0);
      return 'Rp ${ribu}rb';
    }
    return 'Rp $amount';
  }

  static int parse(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }
}
