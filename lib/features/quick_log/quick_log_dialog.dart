import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../budget/repository/budget_repository.dart';
import 'services/calculator_evaluator.dart';
import 'widgets/quick_log_expression_display.dart';
import 'widgets/quick_log_keypad.dart';

/// Bottom sheet dialog for quickly logging an expense with an interactive calculator.
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

  int get _currentTotal => CalculatorEvaluator.evaluate(_expression);

  bool get _hasOperator => CalculatorEvaluator.hasOperator(_expression);

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

                  // Clean Calculator Display
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _setCursorPos(_expression.length),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: QuickLogExpressionDisplay(
                              expression: _expression,
                              rawCursorPos: _rawCursorPos,
                              cursorVisible: _cursorVisible,
                              isOverBudget: isOverBudget,
                              textPrimary: textPrimary,
                              onSetCursorPos: _setCursorPos,
                              onResetCursorBlink: _resetCursorBlink,
                            ),
                          ),
                          const SizedBox(height: 10),
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

                  // 4-Column Standard Calculator Keypad
                  QuickLogKeypad(
                    onKeyPress: _onKeyPress,
                    btnBg: btnBg,
                    textPrimary: textPrimary,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
