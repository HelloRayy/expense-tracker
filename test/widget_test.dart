import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/core/utils/currency_formatter.dart';

void main() {
  test('App smoke test', () {
    expect(CurrencyFormatter.format(10000), contains('10.000'));
  });
}
