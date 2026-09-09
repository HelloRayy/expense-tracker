/// Pure Dart service for evaluating mathematical expressions in Quick Log.
/// Supports standard operations (+, -, ×, ÷) with operator precedence and percentages.
class CalculatorEvaluator {
  CalculatorEvaluator._();

  /// Checks if the expression contains any mathematical operators.
  static bool hasOperator(String expr) {
    return expr.contains('+') ||
        expr.contains('-') ||
        expr.contains('×') ||
        expr.contains('÷') ||
        expr.contains('%');
  }

  /// Parses and evaluates an expression string (e.g. "25000 × 2 + 10000").
  /// Returns a rounded integer clamped between 0 and 999,999,999.
  static int evaluate(String expr) {
    if (expr.trim().isEmpty) return 0;

    final rawTokens = expr.trim().split(RegExp(r'\s+'));
    if (rawTokens.isEmpty) return 0;

    final List<dynamic> tokens = [];
    for (final t in rawTokens) {
      if (t == '+' || t == '-' || t == '×' || t == '÷' || t == '*' || t == '/') {
        tokens.add(t == '*' ? '×' : (t == '/' ? '÷' : t));
      } else {
        if (t.endsWith('%')) {
          final clean = t.replaceAll('%', '').replaceAll('.', '').replaceAll(',', '').trim();
          final val = double.tryParse(clean) ?? 0.0;
          tokens.add(val / 100.0);
        } else {
          final clean = t.replaceAll('.', '').replaceAll(',', '').trim();
          final val = double.tryParse(clean) ?? 0.0;
          tokens.add(val);
        }
      }
    }

    if (tokens.isEmpty) return 0;

    // Discard trailing operator if expression is mid-typing (e.g. "25.000 × ")
    if (tokens.last is String) {
      tokens.removeLast();
    }
    if (tokens.isEmpty) return 0;

    // Pass 1: Multiplication and Division (× and ÷)
    final List<dynamic> pass1 = [];
    int i = 0;
    while (i < tokens.length) {
      final token = tokens[i];
      if (token == '×' || token == '÷') {
        if (pass1.isNotEmpty && i + 1 < tokens.length && tokens[i + 1] is num) {
          final prev = (pass1.removeLast() as num).toDouble();
          final next = (tokens[i + 1] as num).toDouble();
          if (token == '×') {
            pass1.add(prev * next);
          } else {
            pass1.add(next != 0 ? prev / next : 0.0);
          }
          i += 2;
          continue;
        }
      }
      pass1.add(token);
      i++;
    }

    // Pass 2: Addition and Subtraction (+ and -)
    if (pass1.isEmpty) return 0;
    double result = pass1[0] is num ? (pass1[0] as num).toDouble() : 0.0;
    int j = 1;
    while (j < pass1.length) {
      final op = pass1[j];
      if (j + 1 < pass1.length && pass1[j + 1] is num) {
        final val = (pass1[j + 1] as num).toDouble();
        if (op == '+') {
          result += val;
        } else if (op == '-') {
          result -= val;
        }
        j += 2;
      } else {
        j++;
      }
    }

    return result.round().clamp(0, 999999999);
  }
}
