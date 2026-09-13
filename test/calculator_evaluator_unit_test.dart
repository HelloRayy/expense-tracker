import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/features/quick_log/services/calculator_evaluator.dart';

void main() {
  group('CalculatorEvaluator', () {
    test('evaluates simple numbers', () {
      expect(CalculatorEvaluator.evaluate('50000'), 50000);
      expect(CalculatorEvaluator.evaluate('50.000'), 50000);
      expect(CalculatorEvaluator.evaluate(''), 0);
    });

    test('evaluates addition and subtraction', () {
      expect(CalculatorEvaluator.evaluate('20000 + 30000'), 50000);
      expect(CalculatorEvaluator.evaluate('50000 - 15000'), 35000);
    });

    test('evaluates multiplication and division with precedence', () {
      expect(CalculatorEvaluator.evaluate('10000 + 5000 × 2'), 20000);
      expect(CalculatorEvaluator.evaluate('50000 ÷ 2'), 25000);
      expect(CalculatorEvaluator.evaluate('100000 - 40000 ÷ 2'), 80000);
    });

    test('evaluates percentages', () {
      expect(CalculatorEvaluator.evaluate('100000 × 10%'), 10000);
    });

    test('ignores trailing incomplete operators gracefully', () {
      expect(CalculatorEvaluator.evaluate('25000 × '), 25000);
      expect(CalculatorEvaluator.evaluate('10000 + '), 10000);
    });

    test('detects operators with hasOperator', () {
      expect(CalculatorEvaluator.hasOperator('25000'), isFalse);
      expect(CalculatorEvaluator.hasOperator('25000 + 1'), isTrue);
      expect(CalculatorEvaluator.hasOperator('25000 × 2'), isTrue);
      expect(CalculatorEvaluator.hasOperator('10%'), isTrue);
    });

    group('Auto-Kilo Experimental Mode', () {
      test('keeps numbers intact when autoKilo is false', () {
        expect(CalculatorEvaluator.evaluate('72', autoKilo: false), 72);
        expect(CalculatorEvaluator.evaluate('72 + 3000', autoKilo: false), 3072);
      });

      test('scales single integer < 1000 by 1000 when autoKilo is true', () {
        expect(CalculatorEvaluator.evaluate('72', autoKilo: true), 72000);
        expect(CalculatorEvaluator.evaluate('500', autoKilo: true), 500000);
        expect(CalculatorEvaluator.evaluate('0', autoKilo: true), 0);
        expect(CalculatorEvaluator.evaluate('50000', autoKilo: true), 50000);
      });

      test('scales additive operands while preserving full thousands', () {
        expect(CalculatorEvaluator.evaluate('72 + 3.000', autoKilo: true), 75000);
        expect(CalculatorEvaluator.evaluate('72 + 3', autoKilo: true), 75000);
        expect(CalculatorEvaluator.evaluate('100 - 5', autoKilo: true), 95000);
      });

      test('safeguards multipliers and divisors from being scaled to thousands', () {
        expect(CalculatorEvaluator.evaluate('50000 ÷ 2', autoKilo: true), 25000);
        expect(CalculatorEvaluator.evaluate('50.000 ÷ 2', autoKilo: true), 25000);
        expect(CalculatorEvaluator.evaluate('25 × 2', autoKilo: true), 50000);
        expect(CalculatorEvaluator.evaluate('100.000 × 10%', autoKilo: true), 10000);
      });
    });
  });
}
