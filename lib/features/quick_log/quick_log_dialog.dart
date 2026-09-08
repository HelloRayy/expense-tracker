import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../budget/repository/budget_repository.dart';

class QuickLogDialog extends StatefulWidget {
  final BudgetRepository repository;
  final VoidCallback? onComplete;

  const QuickLogDialog({
    super.key,
    required this.repository,
    this.onComplete,
  });

  static Future<void> show(
    BuildContext context, {
    required BudgetRepository repository,
    VoidCallback? onComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickLogDialog(
        repository: repository,
        onComplete: onComplete,
      ),
    );
  }

  @override
  State<QuickLogDialog> createState() => _QuickLogDialogState();
}

class _QuickLogDialogState extends State<QuickLogDialog> {
  String _expression = '';
  bool _isSaving = false;

  int _evaluate(String expr) {
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

  int get _currentTotal => _evaluate(_expression);

  bool get _hasOperator =>
      _expression.contains('+') ||
      _expression.contains('-') ||
      _expression.contains('×') ||
      _expression.contains('÷') ||
      _expression.contains('%');

  String get _currentOperand {
    final lastSpace = _expression.lastIndexOf(' ');
    if (lastSpace == -1) return _expression;
    return _expression.substring(lastSpace + 1);
  }

  void _onKeyPress(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (key == 'C') {
        _expression = '';
        return;
      }

      if (key == '⌫') {
        if (_expression.isNotEmpty) {
          if (_expression.endsWith(' + ') ||
              _expression.endsWith(' - ') ||
              _expression.endsWith(' × ') ||
              _expression.endsWith(' ÷ ')) {
            _expression = _expression.substring(0, _expression.length - 3);
          } else {
            _expression = _expression.substring(0, _expression.length - 1);
          }
        }
        return;
      }

      if (key == '+' || key == '-' || key == '×' || key == '÷') {
        if (_expression.isEmpty) {
          _expression = '0 $key ';
          return;
        }
        if (_expression.endsWith(' + ') ||
            _expression.endsWith(' - ') ||
            _expression.endsWith(' × ') ||
            _expression.endsWith(' ÷ ')) {
          _expression = '${_expression.substring(0, _expression.length - 3)} $key ';
        } else {
          _expression += ' $key ';
        }
        return;
      }

      if (key == '%') {
        if (_expression.isNotEmpty && !_expression.endsWith(' ') && !_expression.endsWith('%')) {
          _expression += '%';
        }
        return;
      }

      if (key == '=') {
        _submit();
        return;
      }

      if (_expression.endsWith('%')) {
        _expression += ' × ';
      }

      final curr = _currentOperand;

      if (key == '00') {
        if (curr.isNotEmpty && curr != '0' && curr.length + 2 <= 12) {
          _expression += '00';
        }
        return;
      }

      if (key == '000') {
        if (curr.isNotEmpty && curr != '0' && curr.length + 3 <= 12) {
          _expression += '000';
        }
        return;
      }

      if (key == '0') {
        if (curr == '0') return;
        if (curr.length < 12) {
          _expression += '0';
        }
        return;
      }

      // Digits 1-9
      if (curr == '0') {
        final lastZeroIndex = _expression.lastIndexOf('0');
        if (lastZeroIndex != -1 && lastZeroIndex == _expression.length - 1) {
          _expression = '${_expression.substring(0, lastZeroIndex)}$key';
          return;
        }
      }

      if (curr.length < 12 && _expression.length < 100) {
        _expression += key;
      }
    });
  }

  Future<void> _submit() async {
    final amount = _currentTotal;
    if (amount <= 0 || _isSaving) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      await widget.repository.addExpense(amount, note: 'Jajan');

      if (mounted) {
        widget.onComplete?.call();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildExpressionWidget(Color textPrimary, {required bool isOverBudget}) {
    const accentCyan = Color(0xFF00E5FF);
    final numberColor = isOverBudget ? PirschColors.roseRed : textPrimary;

    if (_expression.trim().isEmpty) {
      return RichText(
        textAlign: TextAlign.right,
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 48,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          children: [
            const TextSpan(text: '0'),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                margin: const EdgeInsets.only(left: 3),
                width: 2.5,
                height: 40,
                decoration: BoxDecoration(
                  color: accentCyan,
                  borderRadius: BorderRadius.circular(1.5),
                  boxShadow: [
                    BoxShadow(
                      color: accentCyan.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final spans = <InlineSpan>[];
    final regex = RegExp(r'(\d+|[+\-×÷%])');
    final matches = regex.allMatches(_expression);

    for (final m in matches) {
      final token = m.group(0)!;
      if (token == '+' || token == '-' || token == '×' || token == '÷' || token == '%') {
        spans.add(
          TextSpan(
            text: token,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: accentCyan,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      } else {
        final val = int.tryParse(token);
        final formattedNum = val != null
            ? CurrencyFormatter.format(val).replaceAll('Rp ', '')
            : token;
        spans.add(
          TextSpan(
            text: formattedNum,
            style: TextStyle(
              fontFamily: 'Inter',
              color: numberColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }
    }

    // Trailing active cursor matching Gambar 2
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          margin: const EdgeInsets.only(left: 3),
          width: 2.5,
          height: 40,
          decoration: BoxDecoration(
            color: accentCyan,
            borderRadius: BorderRadius.circular(1.5),
            boxShadow: [
              BoxShadow(
                color: accentCyan.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
      ),
    );

    return RichText(
      textAlign: TextAlign.right,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 48,
          letterSpacing: -0.5,
        ),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dailyAllowance = widget.repository.dailyAllowance;
    final isOverBudget = (_currentTotal > 0 && _currentTotal > dailyAllowance) || (dailyAllowance <= 0);

    final sheetBg = isDark ? const Color(0xFF000000) : PirschColors.lightBg;
    final btnBg = isDark ? const Color(0xFF18181A) : const Color(0xFFEBE6DA);
    final textPrimary = isDark ? Colors.white : Colors.black;
    final textSecondary = isDark ? const Color(0xFF8E8E93) : const Color(0xFF707070);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: 24 + bottomInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Info Strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calculate_rounded, color: PirschColors.mintGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Kalkulator Jajan',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  // Clean UI Text (No Badge Container)
                  Text(
                    'Batas Hari Ini: ${CurrencyFormatter.formatCompact(dailyAllowance)}',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Clean Calculator Display Matching Gambar 2
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Top line: Formatted expression with warning color on nominal digits
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: _buildExpressionWidget(textPrimary, isOverBudget: isOverBudget),
                    ),
                    const SizedBox(height: 10),
                    // Bottom line: Evaluated sub-result in subtle gray or red warning when over budget
                    SizedBox(
                      height: 30,
                      child: _hasOperator && _currentTotal > 0
                          ? Text(
                              CurrencyFormatter.format(_currentTotal).replaceAll('Rp ', ''),
                              style: TextStyle(
                                color: isOverBudget ? PirschColors.roseRed : textSecondary,
                                fontSize: 24,
                                fontWeight: isOverBudget ? FontWeight.w600 : FontWeight.w400,
                                letterSpacing: -0.5,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 4-Column Standard Calculator Keypad (×, ÷, -, +, =)
              _buildKeypadGrid(btnBg: btnBg, textPrimary: textPrimary, isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadGrid({
    required Color btnBg,
    required Color textPrimary,
    required bool isDark,
  }) {
    // 5 Rows x 4 Columns Standard Calculator Layout
    final rows = [
      // Row 1: C, ⌫, %, ÷
      [
        {'label': 'C', 'type': 'clear', 'color': PirschColors.roseRed},
        {'label': '⌫', 'type': 'backspace', 'color': PirschColors.roseRed},
        {'label': '%', 'type': 'operator', 'color': textPrimary},
        {'label': '÷', 'type': 'operator', 'color': PirschColors.mintGreen},
      ],
      // Row 2: 7, 8, 9, ×
      [
        {'label': '7', 'type': 'digit', 'color': textPrimary},
        {'label': '8', 'type': 'digit', 'color': textPrimary},
        {'label': '9', 'type': 'digit', 'color': textPrimary},
        {'label': '×', 'type': 'operator', 'color': PirschColors.mintGreen},
      ],
      // Row 3: 4, 5, 6, -
      [
        {'label': '4', 'type': 'digit', 'color': textPrimary},
        {'label': '5', 'type': 'digit', 'color': textPrimary},
        {'label': '6', 'type': 'digit', 'color': textPrimary},
        {'label': '-', 'type': 'operator', 'color': PirschColors.mintGreen},
      ],
      // Row 4: 1, 2, 3, +
      [
        {'label': '1', 'type': 'digit', 'color': textPrimary},
        {'label': '2', 'type': 'digit', 'color': textPrimary},
        {'label': '3', 'type': 'digit', 'color': textPrimary},
        {'label': '+', 'type': 'operator', 'color': PirschColors.mintGreen},
      ],
      // Row 5: 00, 0, 000, =
      [
        {'label': '00', 'type': 'action', 'color': textPrimary},
        {'label': '0', 'type': 'digit', 'color': textPrimary},
        {'label': '000', 'type': 'action', 'color': textPrimary},
        {'label': '=', 'type': 'submit', 'color': Colors.white},
      ],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final buttonSize = ((availableWidth - (3 * 12)) / 4).clamp(52.0, 70.0);

        return Column(
          children: rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: row.map((btn) {
                  return _buildThumbButton(
                    item: btn,
                    size: buttonSize,
                    btnBg: btnBg,
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildThumbButton({
    required Map<String, dynamic> item,
    required double size,
    required Color btnBg,
  }) {
    final label = item['label'] as String;
    final type = item['type'] as String;
    final textColor = item['color'] as Color;

    final isSubmit = type == 'submit';
    final isOperator = type == 'operator';

    Color circleBg = btnBg;
    if (isSubmit) {
      circleBg = const Color(0xFF00897B); // Vibrant Emerald Green
    } else if (isOperator) {
      circleBg = btnBg.withValues(alpha: 0.9);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: circleBg,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onKeyPress(label),
          customBorder: const CircleBorder(),
          splashColor: isSubmit ? Colors.white30 : PirschColors.mintGreen.withValues(alpha: 0.3),
          child: Center(
            child: type == 'backspace'
                ? Icon(Icons.backspace_outlined, color: textColor, size: 22)
                : Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: isSubmit
                          ? 32
                          : (isOperator ? 24 : (type == 'action' ? 18 : 24)),
                      fontWeight: (isSubmit || type == 'digit' || type == 'clear' || isOperator)
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
