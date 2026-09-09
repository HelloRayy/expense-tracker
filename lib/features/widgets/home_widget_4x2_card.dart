import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

/// 4x2 Android Home Screen Widget component mirroring the native AppWidget layout.
/// Displays greeting, subtitle, enlarged daily budget allowance (/hari),
/// and bottom metrics for weekly income (green, with ↓ arrow) and total spent (red, with ↑ arrow).
class HomeWidget4x2Card extends StatelessWidget {
  final String userName;
  final int dailyAllowance;
  final int weeklyIncome;
  final int totalSpent;
  final bool isDark;
  final VoidCallback? onTap;

  const HomeWidget4x2Card({
    super.key,
    this.userName = 'Username',
    required this.dailyAllowance,
    required this.weeklyIncome,
    required this.totalSpent,
    this.isDark = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? PirschColors.darkBg : PirschColors.lightBg;
    final borderColor = isDark ? PirschColors.darkBorder : PirschColors.lightBorder;
    final textPrimary = PirschColors.textPrimary(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);
    final greenColor = PirschColors.green(isDark);
    final redColor = PirschColors.red(isDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          height: 180,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header: Greeting & Context Subtitle
              Text(
                'Hi, $userName',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Batas jajan hari ini',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // Center Hero: Enlarged Nominal + /hari
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    CurrencyFormatter.format(dailyAllowance),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/hari',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Bottom Metrics: Uang Masuk Mingguan (Green) & Uang Keluar Keseluruhan (Red)
              Row(
                children: [
                  // Uang Masuk Mingguan (Green)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_downward_rounded,
                        size: 16,
                        color: greenColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        CurrencyFormatter.format(weeklyIncome),
                        style: TextStyle(
                          color: greenColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Uang Keluar Keseluruhan (Red)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 16,
                        color: redColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        CurrencyFormatter.format(totalSpent),
                        style: TextStyle(
                          color: redColor,
                          fontSize: 15,
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
        ),
      ),
    );
  }
}
