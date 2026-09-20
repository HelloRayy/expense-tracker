import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/constants/ui_keys.dart';
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
  final ImageProvider? coinsImage;
  final ui.Image? rawCoinsImage;

  const HomeWidget4x2Card({
    super.key,
    this.userName = 'Raditya Rayhan',
    required this.dailyAllowance,
    required this.weeklyIncome,
    required this.totalSpent,
    this.isDark = true,
    this.onTap,
    this.coinsImage,
    this.rawCoinsImage,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF0C0D10) : Colors.white;
    final borderColor = isDark ? const Color(0x8027272A) : const Color(0xFFE4E4E7);
    final textPrimary = isDark ? const Color(0xFFEDEDED) : const Color(0xFF0C0C0E);
    final textSecondary = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final greenColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
    final redColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);

    return Material(
      key: UIKeys.homeWidget4x2Card,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
              children: [
                // 1. Coin Back Radial Glow
                Positioned(
                  top: -26,
                  right: -35,
                  width: 219,
                  height: 219,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.12 : 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Coins Illustration from pen.dev (Coins-amico)
                Positioned(
                  top: 19,
                  right: -60,
                  width: 221,
                  height: 195,
                  child: rawCoinsImage != null
                      ? RawImage(
                          image: rawCoinsImage,
                          width: 221,
                          height: 195,
                          fit: BoxFit.contain,
                        )
                      : Image(
                          image: coinsImage ?? const AssetImage('assets/images/coins_illustration.png'),
                          width: 221,
                          height: 195,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                ),

                // 3. Left Content Column
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Header: Greeting & Context Subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Hi, $userName',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Batas jajan hari ini',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      // Lower Block: Hero Nominal + Metrics grouped with a small gap
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Center Hero: Nominal + /hari
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                CurrencyFormatter.format(dailyAllowance),
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '/hari',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Bottom Metrics: Uang Masuk Mingguan & Total Pengeluaran
                          Row(
                            children: [
                              // Income Stat (Green)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    size: 15,
                                    color: greenColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    CurrencyFormatter.format(weeklyIncome),
                                    style: TextStyle(
                                      color: greenColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // Expense Stat (Red)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_upward_rounded,
                                    size: 15,
                                    color: redColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    CurrencyFormatter.format(totalSpent),
                                    style: TextStyle(
                                      color: redColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
