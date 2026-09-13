import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budget/repository/budget_repository.dart';

/// Interactive modal sheet to input new weekly budget with previous week rollover surplus.
class WeeklyBudgetInputSheet extends StatefulWidget {
  final BudgetRepository repository;

  const WeeklyBudgetInputSheet({
    super.key,
    required this.repository,
  });

  static Future<void> show(BuildContext context, BudgetRepository repository) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WeeklyBudgetInputSheet(repository: repository),
    );
  }

  @override
  State<WeeklyBudgetInputSheet> createState() => _WeeklyBudgetInputSheetState();
}

class _WeeklyBudgetInputSheetState extends State<WeeklyBudgetInputSheet> {
  late TextEditingController _incomeController;
  late TextEditingController _savingsController;
  late int _carryover;
  bool _includeCarryover = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carryover = widget.repository.carryoverBalance;
    _incomeController = TextEditingController();
    _savingsController = TextEditingController();

    _incomeController.addListener(() {
      final text = _incomeController.text;
      final parsed = CurrencyFormatter.parse(text);
      if (parsed > 0) {
        // Automatically default savings to 30% rounded
        final defaultSavings = (parsed * 0.3).round();
        _savingsController.text = CurrencyFormatter.formatNumber(defaultSavings);
      } else {
        _savingsController.text = '';
      }
      setState(() {});
    });

    _savingsController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final income = CurrencyFormatter.parse(_incomeController.text);
    final savings = CurrencyFormatter.parse(_savingsController.text);

    if (income < 0) {
      setState(() => _errorMessage = 'Nominal uang jajan tidak boleh negatif');
      return;
    }

    if (income > 0 && savings >= income) {
      setState(() => _errorMessage = 'Target tabungan harus lebih kecil dari uang jajan');
      return;
    }

    final effectiveCarryover = _includeCarryover ? _carryover : 0;

    widget.repository.confirmWeeklyBudget(
      newIncome: income,
      carryover: effectiveCarryover,
      savingsTarget: savings,
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budget minggu ini berhasil diaktifkan!'),
        backgroundColor: PirschColors.mintGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = PirschColors.card(isDark);
    final borderColor = PirschColors.border(isDark);
    final textPrimary = PirschColors.textPrimary(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);

    final inputIncome = CurrencyFormatter.parse(_incomeController.text);
    final inputSavings = CurrencyFormatter.parse(_savingsController.text);
    final effectiveCarryover = _includeCarryover ? _carryover : 0;
    final totalSpendable = (inputIncome - inputSavings + effectiveCarryover).clamp(0, double.maxFinite.toInt());

    final periodStr = widget.repository.budget?.formattedPeriod ?? '';

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header title & period
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Input Uang Jajan',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (periodStr.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: PirschColors.cardElevated(isDark),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      periodStr,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Periode baru telah dimulai. Masukkan nominal uang jajan untuk minggu ini.',
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            // Carryover Surplus Card (if any leftover from last week)
            if (_carryover > 0) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PirschColors.mintGreen.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: PirschColors.mintGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.savings_outlined,
                      color: PirschColors.mintGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sisa Minggu Lalu',
                            style: TextStyle(
                              color: PirschColors.mintGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+ ${CurrencyFormatter.format(_carryover)}',
                            style: const TextStyle(
                              color: PirschColors.mintGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: _includeCarryover,
                      activeColor: PirschColors.mintGreen,
                      checkColor: Colors.black,
                      onChanged: (val) {
                        setState(() {
                          _includeCarryover = val ?? true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Input Uang Jajan
            Text(
              'Uang Jajan Minggu Ini (Rp)',
              style: TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Contoh: 150.000',
                hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
                filled: true,
                fillColor: PirschColors.cardElevated(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PirschColors.mintGreen, width: 1.5),
                ),
                prefixText: 'Rp ',
                prefixStyle: TextStyle(color: textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 14),

            // Target Tabungan (Optional / auto 30%)
            Text(
              'Target Ditabung (Disisihkan)',
              style: TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _savingsController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '0 (atau default 30%)',
                hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
                filled: true,
                fillColor: PirschColors.cardElevated(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PirschColors.mintGreen, width: 1.5),
                ),
                prefixText: 'Rp ',
                prefixStyle: TextStyle(color: textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),

            // Live Preview Total Budget Belanja
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: PirschColors.cardElevated(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Boleh Jajan Minggu Ini:',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(totalSpendable),
                    style: TextStyle(
                      color: totalSpendable > 0 ? PirschColors.mintGreen : textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: PirschColors.roseRed, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PirschColors.mintGreen,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Mulai Minggu Ini',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
