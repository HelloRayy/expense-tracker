import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

/// 4x2 Android Home Screen Widget component mirroring the native AppWidget layout.
/// Displays greeting, subtitle, enlarged daily budget allowance (/hari),
/// and bottom metrics for remaining today (green) and spent today (red).
class HomeWidget4x2Card extends StatelessWidget {
  final String userName;
  final int dailyAllowance;
  final int remainingToday;
  final int spentToday;
  final bool isDark;
  final VoidCallback? onTap;

  const HomeWidget4x2Card({
    super.key,
    this.userName = 'Username',
    required this.dailyAllowance,
    required this.remainingToday,
    required this.spentToday,
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

              // Bottom Metrics: Sisa Hari Ini (Green) & Pengeluaran Hari Ini (Red)
              Row(
                children: [
                  Text(
                    CurrencyFormatter.format(remainingToday),
                    style: TextStyle(
                      color: remainingToday < 0 ? redColor : greenColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    CurrencyFormatter.format(spentToday),
                    style: TextStyle(
                      color: redColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
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
