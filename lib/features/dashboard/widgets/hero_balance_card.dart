import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// Hero Balance Card for Dashboard.
/// Displays greeting 'Hi, Sobat', period dropdown, primary '/hari' allowance,
/// and side-by-side metrics for '↙ Sisa Saldo' and '↗ Terpakai'.
class HeroBalanceCard extends StatelessWidget {
  final int remaining;
  final int spent;
  final int remainingToday;
  final String formattedPeriod;
  final bool isOverBudget;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTapPeriod;
  final VoidCallback onTapMenu;

  const HeroBalanceCard({
    super.key,
    required this.remaining,
    required this.spent,
    required this.remainingToday,
    required this.formattedPeriod,
    required this.isOverBudget,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTapPeriod,
    required this.onTapMenu,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNegative = remainingToday < 0;
    final displayAmount = isNegative
        ? '-${CurrencyFormatter.format(remainingToday.abs())}'
        : CurrencyFormatter.format(remainingToday);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Greeting & Period Dropdown (Left) + 3-Dots Menu (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Sobat',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    InkWell(
                      onTap: onTapPeriod,
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'batas jajan ',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'hari ini ⌄',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: textSecondary,
                            ),
                          ),
                          if (formattedPeriod.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '• $formattedPeriod',
                              style: TextStyle(
                                color: textSecondary.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 3-dots Menu Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTapMenu,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Hero Nominal: Left-aligned (Sisa Jajan Hari Ini)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  displayAmount,
                  style: TextStyle(
                    color: isNegative || isOverBudget ? PirschColors.roseRed : textPrimary,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '/ hari',
                  style: TextStyle(
                    color: isNegative || isOverBudget
                        ? PirschColors.roseRed.withValues(alpha: 0.7)
                        : textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sub-metrics Row below Hero: ↙ Sisa Saldo & ↗ Terpakai (Side-by-Side)
          Row(
            children: [
              // Left: ↙ Sisa Saldo (WCAG AA Compliant Green)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.south_west_rounded,
                    size: 15,
                    color: PirschColors.green(isDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    CurrencyFormatter.format(remaining),
                    style: TextStyle(
                      color: remaining < 0 ? PirschColors.red(isDark) : PirschColors.green(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),

              // Right: ↗ Terpakai (WCAG AA Compliant Red)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.north_east_rounded,
                    size: 15,
                    color: PirschColors.red(isDark),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    CurrencyFormatter.format(spent),
                    style: TextStyle(
                      color: PirschColors.red(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
