import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// Formatted mathematical expression display with interactive cursor navigation.
class QuickLogExpressionDisplay extends StatelessWidget {
  final String expression;
  final int rawCursorPos;
  final bool cursorVisible;
  final bool isOverBudget;
  final Color textPrimary;
  final ValueChanged<int> onSetCursorPos;
  final VoidCallback? onResetCursorBlink;

  const QuickLogExpressionDisplay({
    super.key,
    required this.expression,
    required this.rawCursorPos,
    required this.cursorVisible,
    required this.isOverBudget,
    required this.textPrimary,
    required this.onSetCursorPos,
    this.onResetCursorBlink,
  });

  Widget _buildCursorBar() {
    const accentCyan = Color(0xFF00E5FF);
    return AnimatedOpacity(
      opacity: cursorVisible ? 1.0 : 0.0,
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

  @override
  Widget build(BuildContext context) {
    const accentCyan = Color(0xFF00E5FF);
    final numberColor = isOverBudget ? PirschColors.roseRed : textPrimary;

    if (expression.trim().isEmpty) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onResetCursorBlink?.call();
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
    final matches = regex.allMatches(expression);
    int rawIndex = 0;

    void maybeInsertCursor() {
      if (rawIndex == rawCursorPos) {
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
              onSetCursorPos(isRight ? tokenStart + token.length : tokenStart);
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
            onTap: () => onSetCursorPos(tokenStart),
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

          if (!isDot && currentRawPos == rawCursorPos && children.isNotEmpty) {
            children.add(_buildCursorBar());
          }

          children.add(
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                if (isDot) {
                  onSetCursorPos(currentRawPos);
                } else {
                  final isRight = details.localPosition.dx > 14;
                  onSetCursorPos(isRight ? currentRawPos + 1 : currentRawPos);
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

    if (rawCursorPos >= expression.length && !children.any((w) => w is AnimatedOpacity)) {
      children.add(_buildCursorBar());
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
