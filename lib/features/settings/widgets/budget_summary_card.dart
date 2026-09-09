import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// Live Calculation Summary Card showing spendable budget, estimated daily allowance,
/// and targeted savings.
class BudgetSummaryCard extends StatelessWidget {
  final int spendable;
  final int dailyEst;
  final int savings;
  final bool isDark;
  final Color elevatedColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const BudgetSummaryCard({
    super.key,
    required this.spendable,
    required this.dailyEst,
    required this.savings,
    required this.isDark,
    required this.elevatedColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: elevatedColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Boleh Dibelanjakan:',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              Text(
                CurrencyFormatter.format(spendable),
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimasi Batas Harian:',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              Text(
                '${CurrencyFormatter.format(dailyEst)} / hari',
                style: TextStyle(
                  color: PirschColors.green(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Tabungan Akhir:',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              Text(
                CurrencyFormatter.format(savings),
                style: TextStyle(
                  color: PirschColors.yellow(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
