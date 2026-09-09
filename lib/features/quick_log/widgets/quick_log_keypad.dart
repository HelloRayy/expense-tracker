import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Interactive 4-column calculator keypad for Quick Log.
/// Provides responsive circular buttons with haptic feedback styling.
class QuickLogKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyPress;
  final Color btnBg;
  final Color textPrimary;
  final bool isDark;

  const QuickLogKeypad({
    super.key,
    required this.onKeyPress,
    required this.btnBg,
    required this.textPrimary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: () => onKeyPress(label),
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
