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
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final String formatted;
    if (absAmount >= 1000000) {
      final juta = (absAmount / 1000000).toStringAsFixed(1).replaceAll('.0', '');
      formatted = 'Rp ${juta}jt';
    } else if (absAmount >= 1000) {
      final ribu = (absAmount / 1000).toStringAsFixed(0);
      formatted = 'Rp ${ribu}rb';
    } else {
      formatted = 'Rp $absAmount';
    }
    return isNegative ? '-$formatted' : formatted;
  }

  static int parse(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }
}
