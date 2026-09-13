import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// Enum to toggle between Daily ('hari ini') and Weekly ('mingguan') allowance view.
enum BudgetPeriodView {
  daily,
  weekly,
}

/// Hero Balance Card for Dashboard.
/// Displays greeting 'Hi, Sobat', period dropdown, primary allowance (/hari or /minggu),
/// and side-by-side metrics for '↙ Sisa Saldo' and '↗ Terpakai'.
class HeroBalanceCard extends StatelessWidget {
  final int remaining;
  final int spent;
  final int remainingToday;
  final int? remainingWeekly;
  final String formattedPeriod;
  final bool isOverBudget;
  final Color textPrimary;
  final Color textSecondary;
  final BudgetPeriodView periodView;
  final ValueChanged<BudgetPeriodView>? onPeriodChanged;
  final VoidCallback? onTapPeriod;
  final VoidCallback onTapMenu;

  const HeroBalanceCard({
    super.key,
    required this.remaining,
    required this.spent,
    required this.remainingToday,
    this.remainingWeekly,
    required this.formattedPeriod,
    required this.isOverBudget,
    required this.textPrimary,
    required this.textSecondary,
    this.periodView = BudgetPeriodView.daily,
    this.onPeriodChanged,
    this.onTapPeriod,
    required this.onTapMenu,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDaily = periodView == BudgetPeriodView.daily;
    final effectiveAmount = isDaily ? remainingToday : (remainingWeekly ?? remaining);
    final isNegative = effectiveAmount < 0;
    final displayAmount = isNegative
        ? '-${CurrencyFormatter.format(effectiveAmount.abs())}'
        : CurrencyFormatter.format(effectiveAmount);
    final periodUnit = isDaily ? '/ hari' : '/ minggu';
    final periodLabel = isDaily ? 'hari ini' : 'mingguan';

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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ),
                          child: PopupMenuButton<BudgetPeriodView>(
                            initialValue: periodView,
                            tooltip: 'Pilih periode',
                            offset: const Offset(0, 24),
                            elevation: 8,
                            color: isDark ? const Color(0xFF1E1E22) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.black.withValues(alpha: 0.08),
                                width: 1,
                              ),
                            ),
                            onSelected: (view) {
                              onPeriodChanged?.call(view);
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<BudgetPeriodView>(
                                value: BudgetPeriodView.daily,
                                height: 42,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.today_rounded,
                                      size: 16,
                                      color: isDaily ? PirschColors.incomeGreen : textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Hari ini',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isDaily ? FontWeight.w700 : FontWeight.w500,
                                          color: isDaily ? textPrimary : textSecondary,
                                        ),
                                      ),
                                    ),
                                    if (isDaily)
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: PirschColors.incomeGreen,
                                      ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<BudgetPeriodView>(
                                value: BudgetPeriodView.weekly,
                                height: 42,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_view_week_rounded,
                                      size: 16,
                                      color: !isDaily ? PirschColors.incomeGreen : textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Mingguan',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: !isDaily ? FontWeight.w700 : FontWeight.w500,
                                          color: !isDaily ? textPrimary : textSecondary,
                                        ),
                                      ),
                                    ),
                                    if (!isDaily)
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: PirschColors.incomeGreen,
                                      ),
                                  ],
                                ),
                              ),
                            ],
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
                                  '$periodLabel ⌄',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (formattedPeriod.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: onTapPeriod,
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '• $formattedPeriod',
                                style: TextStyle(
                                  color: textSecondary.withValues(alpha: 0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
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

          // Main Hero Nominal: Left-aligned (Sisa Jajan Hari Ini / Mingguan)
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
                  periodUnit,
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
