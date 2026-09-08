import 'dart:async';
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
  int _rawCursorPos = 0;
  bool _isSaving = false;
  bool _cursorVisible = true;
  Timer? _cursorBlinkTimer;

  @override
  void initState() {
    super.initState();
    _startCursorBlink();
  }

  void _startCursorBlink() {
    _cursorVisible = true;
    _cursorBlinkTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() => _cursorVisible = !_cursorVisible);
      }
    });
  }

  void _resetCursorBlink() {
    _cursorBlinkTimer?.cancel();
    _cursorVisible = true;
    _startCursorBlink();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cursorBlinkTimer?.cancel();
    super.dispose();
  }

  void _setCursorPos(int pos) {
    HapticFeedback.selectionClick();
    setState(() {
      _rawCursorPos = pos.clamp(0, _expression.length);
    });
    _resetCursorBlink();
  }

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

  void _onKeyPress(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      _rawCursorPos = _rawCursorPos.clamp(0, _expression.length);

      if (key == 'C') {
        _expression = '';
        _rawCursorPos = 0;
        _resetCursorBlink();
        return;
      }

      if (key == '⌫') {
        if (_expression.isNotEmpty && _rawCursorPos > 0) {
          final left = _expression.substring(0, _rawCursorPos);
          final right = _expression.substring(_rawCursorPos);
          if (left.endsWith(' + ') ||
              left.endsWith(' - ') ||
              left.endsWith(' × ') ||
              left.endsWith(' ÷ ')) {
            _expression = '${left.substring(0, left.length - 3)}$right';
            _rawCursorPos -= 3;
          } else if (left.endsWith(' ')) {
            _expression = '${left.substring(0, left.length - 1)}$right';
            _rawCursorPos -= 1;
          } else {
            _expression = '${left.substring(0, left.length - 1)}$right';
            _rawCursorPos -= 1;
          }
        }
        _resetCursorBlink();
        return;
      }

      if (key == '+' || key == '-' || key == '×' || key == '÷') {
        if (_expression.isEmpty) {
          _expression = '0 $key ';
          _rawCursorPos = _expression.length;
          _resetCursorBlink();
          return;
        }
        final left = _expression.substring(0, _rawCursorPos);
        final right = _expression.substring(_rawCursorPos);
        if (left.endsWith(' + ') ||
            left.endsWith(' - ') ||
            left.endsWith(' × ') ||
            left.endsWith(' ÷ ')) {
          _expression = '${left.substring(0, left.length - 3)} $key $right';
          _rawCursorPos = left.length - 3 + ' $key '.length;
        } else {
          _expression = '$left $key $right';
          _rawCursorPos += ' $key '.length;
        }
        _resetCursorBlink();
        return;
      }

      if (key == '%') {
        final left = _expression.substring(0, _rawCursorPos);
        final right = _expression.substring(_rawCursorPos);
        if (left.isNotEmpty && !left.endsWith(' ') && !left.endsWith('%')) {
          _expression = '$left%$right';
          _rawCursorPos += 1;
        }
        _resetCursorBlink();
        return;
      }

      if (key == '=') {
        _submit();
        return;
      }

      final left = _expression.substring(0, _rawCursorPos);
      final right = _expression.substring(_rawCursorPos);

      final lastSpace = left.lastIndexOf(' ');
      final opStart = lastSpace == -1 ? 0 : lastSpace + 1;
      final nextSpace = right.indexOf(' ');
      final opEnd = nextSpace == -1 ? _expression.length : _rawCursorPos + nextSpace;
      final curr = _expression.substring(opStart, opEnd);

      if (key == '00') {
        if (curr.isNotEmpty && curr != '0' && curr.length + 2 <= 12) {
          _expression = '$left' '00' '$right';
          _rawCursorPos += 2;
          _resetCursorBlink();
        }
        return;
      }

      if (key == '000') {
        if (curr.isNotEmpty && curr != '0' && curr.length + 3 <= 12) {
          _expression = '$left' '000' '$right';
          _rawCursorPos += 3;
          _resetCursorBlink();
        }
        return;
      }

      if (key == '0') {
        if (curr == '0') return;
        if (curr.length < 12) {
          _expression = '${left}0$right';
          _rawCursorPos += 1;
          _resetCursorBlink();
        }
        return;
      }

      // Digits 1-9
      if (curr == '0') {
        _expression = '${_expression.substring(0, opStart)}$key$right';
        _rawCursorPos = opStart + 1;
        _resetCursorBlink();
        return;
      }

      if (curr.length < 12 && _expression.length < 100) {
        _expression = '$left$key$right';
        _rawCursorPos += 1;
        _resetCursorBlink();
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

  Widget _buildCursorBar() {
    const accentCyan = Color(0xFF00E5FF);
    return AnimatedOpacity(
      opacity: _cursorVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 80),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 2.5,
        height: 38,
        decoration: BoxDecoration(
          color: accentCyan,
          borderRadius: BorderRadius.circular(1.5),
          boxShadow: [
            BoxShadow(
              color: accentCyan.withValues(alpha: 0.6),
              blurRadius: 5,
              spreadRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpressionWidget(Color textPrimary, {required bool isOverBudget}) {
    const accentCyan = Color(0xFF00E5FF);
    final numberColor = isOverBudget ? PirschColors.roseRed : textPrimary;

    if (_expression.trim().isEmpty) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          _resetCursorBlink();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '0',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: numberColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 4),
            _buildCursorBar(),
          ],
        ),
      );
    }

    final children = <Widget>[];
    final regex = RegExp(r'(\d+|[+\-×÷%]| +)');
    final matches = regex.allMatches(_expression);
    int rawIndex = 0;

    void maybeInsertCursor() {
      if (rawIndex == _rawCursorPos) {
        children.add(_buildCursorBar());
      }
    }

    maybeInsertCursor();

    for (final m in matches) {
      final token = m.group(0)!;
      final tokenStart = rawIndex;

      if (token == '+' || token == '-' || token == '×' || token == '÷' || token == '%') {
        children.add(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final isRight = details.localPosition.dx > 12;
              _setCursorPos(isRight ? tokenStart + token.length : tokenStart);
            },
            child: Text(
              token,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: accentCyan,
                fontSize: 48,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
              ),
            ),
          ),
        );
        rawIndex += token.length;
        maybeInsertCursor();
      } else if (token.trim().isEmpty) {
        children.add(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _setCursorPos(tokenStart),
            child: Text(
              token,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 48,
                letterSpacing: -0.5,
              ),
            ),
          ),
        );
        rawIndex += token.length;
        maybeInsertCursor();
      } else {
        final val = int.tryParse(token);
        final formattedNum = val != null
            ? CurrencyFormatter.format(val).replaceAll('Rp ', '')
            : token;

        var numOffset = 0;
        for (int i = 0; i < formattedNum.length; i++) {
          final ch = formattedNum[i];
          final isDot = ch == '.';
          final currentRawPos = tokenStart + numOffset;

          if (!isDot && currentRawPos == _rawCursorPos && children.isNotEmpty) {
            children.add(_buildCursorBar());
          }

          children.add(
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                if (isDot) {
                  _setCursorPos(currentRawPos);
                } else {
                  final isRight = details.localPosition.dx > 14;
                  _setCursorPos(isRight ? currentRawPos + 1 : currentRawPos);
                }
              },
              child: Text(
                ch,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: numberColor,
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          );

          if (!isDot) {
            numOffset++;
          }
        }
        rawIndex += token.length;
        maybeInsertCursor();
      }
    }

    if (_rawCursorPos >= _expression.length && !children.any((w) => w is AnimatedOpacity)) {
      children.add(_buildCursorBar());
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final todayLimit = widget.repository.remainingToday;
        final isOverBudget = (_currentTotal > 0 && _currentTotal > todayLimit) || (todayLimit <= 0);

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
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calculate_rounded, color: PirschColors.mintGreen, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Kalkulator Jajan',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Clean UI Text (No Badge Container)
                      Text(
                        'Batas Hari Ini: ${CurrencyFormatter.formatCompact(todayLimit)}',
                        style: TextStyle(
                          color: todayLimit < 0 ? PirschColors.roseRed : textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 16),

              // Clean Calculator Display Matching Gambar 2
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _setCursorPos(_expression.length),
                child: Container(
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
              ),
              const SizedBox(height: 10),

              // 4-Column Standard Calculator Keypad (×, ÷, -, +, =)
              _buildKeypadGrid(btnBg: btnBg, textPrimary: textPrimary, isDark: isDark),
            ],
          ),
        ),
      ),
    );
      },
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
