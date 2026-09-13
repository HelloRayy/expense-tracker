import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_settings_controller.dart';
import '../../core/utils/currency_formatter.dart';
import '../budget/repository/budget_repository.dart';
import 'services/calculator_evaluator.dart';
import 'widgets/quick_log_expression_display.dart';
import 'widgets/quick_log_keypad.dart';

/// Standalone full screen for logging expenses, styled matching the reference image:
/// - Circular back and options navigation pills
/// - "Recipient" note card with text input field
/// - "Amount" section with large currency typography and green blinking cursor
/// - 4-column squircle calculator keypad
/// - High-contrast vibrant yellow capsule action button at the bottom
class QuickLogScreen extends StatefulWidget {
  final BudgetRepository repository;
  final VoidCallback? onComplete;

  const QuickLogScreen({
    super.key,
    required this.repository,
    this.onComplete,
  });

  static Future<void> open(
    BuildContext context, {
    required BudgetRepository repository,
    VoidCallback? onComplete,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuickLogScreen(
          repository: repository,
          onComplete: onComplete,
        ),
      ),
    );
  }

  @override
  State<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends State<QuickLogScreen> {
  final TextEditingController _noteController = TextEditingController();
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
    _noteController.dispose();
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
        final evaluated = _currentTotal;
        if (evaluated > 0) {
          _expression = evaluated.toString();
          _rawCursorPos = _expression.length;
          _resetCursorBlink();
        }
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

    final note = _noteController.text.trim();
    final effectiveNote = note.isEmpty ? 'Pengeluaran' : note;

    try {
      await widget.repository.addExpense(amount, note: effectiveNote);

      if (mounted) {
        widget.onComplete?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil mencatat ${CurrencyFormatter.format(amount)} ($effectiveNote)'),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
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
        final todayLimit = widget.repository.remainingToday;
        final isOverBudget = (_currentTotal > 0 && _currentTotal > todayLimit) || (todayLimit <= 0);

        final bgColor = isDark ? const Color(0xFF0C0C0E) : PirschColors.lightBg;
        final cardColor = isDark ? const Color(0xFF18181B) : Colors.white;
        final btnBg = isDark ? const Color(0xFF18181B) : const Color(0xFFE8EAF0);
        final textPrimary = isDark ? Colors.white : const Color(0xFF0C0C0C);
        final textSecondary = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button (Circular Dark Pill)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: cardColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: textPrimary,
                              size: 18,
                            ),
                          ),
                        ),
                      ),

                      // Screen Title
                      Text(
                        'Catat Pengeluaran',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),

                      // Right Action Pill (Clear or Options)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _expression = '';
                              _rawCursorPos = 0;
                              _noteController.clear();
                            });
                            _resetCursorBlink();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: cardColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.more_horiz_rounded,
                              color: textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Area for Note Card & Amount Display
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Section 1: "Recipient" / Note Card
                        Text(
                          'Keterangan',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              // Avatar / Category Icon
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF222226) : const Color(0xFFEFF2F8),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  color: PirschColors.primaryBlue,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Text Input Field for Note
                              Expanded(
                                child: TextField(
                                  controller: _noteController,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Tulis catatan jajan (cth: Kopi)...',
                                    hintStyle: TextStyle(
                                      color: textSecondary.withValues(alpha: 0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section 2: "Amount" Display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nominal',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                        const SizedBox(height: 8),

                        // Large Amount & Cursor Display
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _setCursorPos(_expression.length),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Rp ',
                                        style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.w800,
                                          color: isOverBudget ? PirschColors.roseRed : textPrimary,
                                          letterSpacing: -1.0,
                                        ),
                                      ),
                                      QuickLogExpressionDisplay(
                                        expression: _expression,
                                        rawCursorPos: _rawCursorPos,
                                        cursorVisible: _cursorVisible,
                                        isOverBudget: isOverBudget,
                                        textPrimary: textPrimary,
                                        onSetCursorPos: _setCursorPos,
                                        onResetCursorBlink: _resetCursorBlink,
                                      ),
                                    ],
                                  ),
                                ),
                                if (_hasOperator && _currentTotal > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '= ${CurrencyFormatter.format(_currentTotal)}',
                                    style: TextStyle(
                                      color: isOverBudget ? PirschColors.roseRed : PirschColors.primaryBlue,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // 4-Column Keypad with Squircle Buttons
                        QuickLogKeypad(
                          onKeyPress: _onKeyPress,
                          btnBg: btnBg,
                          textPrimary: textPrimary,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),

                        // Bottom Action Button: Vibrant Yellow Capsule
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _currentTotal > 0 && !_isSaving ? _submit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFEB3B), // Vibrant Yellow matching reference
                              disabledBackgroundColor: isDark
                                  ? const Color(0xFF242428)
                                  : const Color(0xFFE0E0E0),
                              foregroundColor: const Color(0xFF0C0C0C),
                              disabledForegroundColor: textSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0C0C0C),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Catat Pengeluaran',
                                    style: TextStyle(
                                      color: Color(0xFF0C0C0C),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
