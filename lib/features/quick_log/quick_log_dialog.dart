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
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  int _evaluate(String expr) {
    if (expr.isEmpty) return 0;
    final parts = expr.split('+');
    int total = 0;
    for (final part in parts) {
      final clean = part.replaceAll('.', '').replaceAll(' ', '').trim();
      total += int.tryParse(clean) ?? 0;
    }
    return total;
  }

  int get _currentTotal => _evaluate(_expression);

  void _onKeyPress(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (key == 'C') {
        _expression = '';
      } else if (key == '⌫') {
        if (_expression.isNotEmpty) {
          if (_expression.endsWith(' + ')) {
            _expression = _expression.substring(0, _expression.length - 3);
          } else {
            _expression = _expression.substring(0, _expression.length - 1);
          }
        }
      } else if (key == '+') {
        if (_expression.isNotEmpty && !_expression.endsWith(' + ')) {
          _expression += ' + ';
        }
      } else if (key == '000') {
        if (_expression.isNotEmpty && !_expression.endsWith(' + ') && _expression.length <= 9) {
          _expression += '000';
        }
      } else if (key == '00') {
        if (_expression.isNotEmpty && !_expression.endsWith(' + ') && _expression.length <= 10) {
          _expression += '00';
        }
      } else if (key.startsWith('+') && key.endsWith('rb')) {
        // Preset shortcuts (+5rb, +10rb, +25rb, +50rb)
        final numStr = key.replaceAll('+', '').replaceAll('rb', '');
        final addAmount = (int.tryParse(numStr) ?? 0) * 1000;
        final total = _currentTotal + addAmount;
        _expression = total.toString();
      } else if (key == '=') {
        _submit();
      } else {
        // Digits 0-9
        if (_expression.length <= 12) {
          _expression += key;
        }
      }
    });
  }

  Future<void> _submit() async {
    final amount = _currentTotal;
    if (amount <= 0 || _isSaving) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final note = _noteController.text.trim().isEmpty ? 'Jajan' : _noteController.text.trim();
    await widget.repository.addExpense(amount, note: note);

    if (mounted) {
      widget.onComplete?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final remaining = widget.repository.remainingBalance;

    final sheetBg = isDark ? const Color(0xFF000000) : PirschColors.lightBg;
    final btnBg = isDark ? const Color(0xFF18181A) : const Color(0xFFEBE6DA);
    final textPrimary = isDark ? Colors.white : Colors.black;
    final textSecondary = isDark ? const Color(0xFF8E8E93) : const Color(0xFF707070);

    // Formatted display string
    String displayString = '0';
    if (_expression.isNotEmpty) {
      if (_expression.contains(' + ')) {
        displayString = _expression;
      } else {
        final val = int.tryParse(_expression);
        if (val != null) {
          displayString = CurrencyFormatter.format(val).replaceAll('Rp ', '');
        } else {
          displayString = _expression;
        }
      }
    }

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: 24 + bottomInset,
      ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: PirschColors.mintGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PirschColors.mintGreen.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Sisa: ${CurrencyFormatter.formatCompact(remaining)}',
                  style: const TextStyle(
                    color: PirschColors.mintGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Large Calculator Display (Right Aligned - Reference Style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_expression.contains(' + '))
                  Text(
                    '= ${CurrencyFormatter.format(_currentTotal)}',
                    style: const TextStyle(
                      color: PirschColors.mintGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    displayString,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Inline Note / Category Chips Input
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: btnBg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _noteController,
                    style: TextStyle(color: textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Keterangan (opsional, cth: Kopi, Mie Ayam)',
                      hintStyle: TextStyle(color: textSecondary, fontSize: 12),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Category Quick Chips
              _buildCategoryChip(Icons.restaurant_rounded, 'Makan', btnBg, textSecondary),
              const SizedBox(width: 6),
              _buildCategoryChip(Icons.local_cafe_rounded, 'Kopi', btnBg, textSecondary),
            ],
          ),
          const SizedBox(height: 16),

          // 4-Column Thumb-Friendly Circular Keypad
          _buildKeypadGrid(btnBg: btnBg, textPrimary: textPrimary, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(IconData icon, String text, Color bg, Color iconColor) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        _noteController.text = text;
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }

  Widget _buildKeypadGrid({
    required Color btnBg,
    required Color textPrimary,
    required bool isDark,
  }) {
    // 5 Rows x 4 Columns Thumb-Friendly Circular Buttons
    final rows = [
      // Row 1: C, ⌫, 000, +
      [
        {'label': 'C', 'type': 'clear', 'color': PirschColors.roseRed},
        {'label': '⌫', 'type': 'backspace', 'color': PirschColors.roseRed},
        {'label': '000', 'type': 'action', 'color': textPrimary},
        {'label': '+', 'type': 'operator', 'color': PirschColors.mintGreen},
      ],
      // Row 2: 7, 8, 9, +5rb
      [
        {'label': '7', 'type': 'digit', 'color': textPrimary},
        {'label': '8', 'type': 'digit', 'color': textPrimary},
        {'label': '9', 'type': 'digit', 'color': textPrimary},
        {'label': '+5rb', 'type': 'preset', 'color': isDark ? const Color(0xFF9E9E9E) : const Color(0xFF555555)},
      ],
      // Row 3: 4, 5, 6, +10rb
      [
        {'label': '4', 'type': 'digit', 'color': textPrimary},
        {'label': '5', 'type': 'digit', 'color': textPrimary},
        {'label': '6', 'type': 'digit', 'color': textPrimary},
        {'label': '+10rb', 'type': 'preset', 'color': isDark ? const Color(0xFF9E9E9E) : const Color(0xFF555555)},
      ],
      // Row 4: 1, 2, 3, +25rb
      [
        {'label': '1', 'type': 'digit', 'color': textPrimary},
        {'label': '2', 'type': 'digit', 'color': textPrimary},
        {'label': '3', 'type': 'digit', 'color': textPrimary},
        {'label': '+25rb', 'type': 'preset', 'color': isDark ? const Color(0xFF9E9E9E) : const Color(0xFF555555)},
      ],
      // Row 5: 00, 0, +50rb, = (Large Green Submit)
      [
        {'label': '00', 'type': 'action', 'color': textPrimary},
        {'label': '0', 'type': 'digit', 'color': textPrimary},
        {'label': '+50rb', 'type': 'preset', 'color': isDark ? const Color(0xFF9E9E9E) : const Color(0xFF555555)},
        {'label': '=', 'type': 'submit', 'color': Colors.white},
      ],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate circle diameter to maintain perfect roundness
        final availableWidth = constraints.maxWidth;
        final buttonSize = ((availableWidth - (3 * 12)) / 4).clamp(54.0, 72.0);

        return Column(
          children: rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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

    // Background color: Green for '=', slightly lighter for operators, standard circular for digits
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
                          : (type == 'preset'
                              ? 13
                              : (type == 'action' ? 18 : 24)),
                      fontWeight: (isSubmit || type == 'digit' || type == 'clear')
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
