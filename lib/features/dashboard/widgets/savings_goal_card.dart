import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// Savings Goal Card matching Wireframe 3 (savingsItems) and Reference Design 1.
/// Displays savings title, target ratio, linear progress bar, and remaining balance to target.
class SavingsGoalCard extends StatelessWidget {
  final int weeklySavingsTarget;
  final int currentSaved;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onConfigure;

  const SavingsGoalCard({
    super.key,
    required this.weeklySavingsTarget,
    required this.currentSaved,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    // Effective savings progress (capped between 0.0 and 1.0)
    final target = weeklySavingsTarget > 0 ? weeklySavingsTarget : 0;
    final saved = currentSaved.clamp(0, target > 0 ? target : double.maxFinite.toInt());
    final double progress = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
    final int remainingToTarget = (target - saved).clamp(0, target);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row: "Savings" / "Target Tabungan" + "See all" / "Atur"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Savings',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            InkWell(
              onTap: onConfigure,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: PirschColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Main Savings Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B1B1B) : cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Goal Title & Ratio (e.g. Tabungan Minggu Ini | Rp 30.000 / Rp 50.000)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Tabungan Minggu Ini',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: CurrencyFormatter.format(saved),
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${CurrencyFormatter.format(target)}',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Linear Progress Bar with Periwinkle Accent
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress > 0 ? progress : 0.02,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: PirschColors.primaryBlue,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Subtitle Progress Text
              Text(
                target == 0
                    ? 'Target tabungan belum diatur. Ketuk "See all" untuk mengatur.'
                    : remainingToTarget == 0
                        ? 'Target tabungan minggu ini sudah tercapai!'
                        : '${CurrencyFormatter.format(remainingToTarget)} lagi untuk mencapai target mingguan',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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
