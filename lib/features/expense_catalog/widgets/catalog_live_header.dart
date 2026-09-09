import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// Top header for ExpenseCatalogScreen showing back button, title, and live remaining budget badge.
class CatalogLiveHeader extends StatelessWidget {
  final int remainingToday;
  final VoidCallback onBack;
  final bool isDark;

  const CatalogLiveHeader({
    super.key,
    required this.remainingToday,
    required this.onBack,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = PirschColors.textPrimary(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);
    final isNegative = remainingToday < 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Navigation Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 24),
                ),
              ),
            ),
            // Live Remaining Today Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isNegative
                    ? PirschColors.red(isDark).withValues(alpha: 0.12)
                    : PirschColors.green(isDark).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isNegative
                      ? PirschColors.red(isDark).withValues(alpha: 0.3)
                      : PirschColors.green(isDark).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isNegative ? Icons.warning_amber_rounded : Icons.account_balance_wallet_rounded,
                    size: 14,
                    color: isNegative ? PirschColors.red(isDark) : PirschColors.green(isDark),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Sisa Hari Ini: ${CurrencyFormatter.formatCompact(remainingToday)}',
                    style: TextStyle(
                      color: isNegative ? PirschColors.red(isDark) : PirschColors.green(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Large Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Katalog Jajan',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Sekali sentuh kartu untuk langsung mencatat pengeluaran tanpa input manual.',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
