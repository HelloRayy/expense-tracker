import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

/// Compact 3-Action Button Bar for Dashboard.
/// Replaces the visual clutter of multiple full-width cards with a sleek,
/// 1-row action bar:
/// 1. Tabungan (Mini Circular Progress Ring with % in center)
/// 2. Kategori (1-tap category allocation navigation)
/// 3. Catat Jajan (High-contrast solid action button with pending badge)
class DashboardActionBar extends StatelessWidget {
  final int weeklySavingsTarget;
  final int currentSaved;
  final int pendingCount;
  final bool isDark;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTapSavings;
  final VoidCallback onTapCategory;
  final VoidCallback onTapQuickLog;

  const DashboardActionBar({
    super.key,
    required this.weeklySavingsTarget,
    required this.currentSaved,
    this.pendingCount = 0,
    required this.isDark,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTapSavings,
    required this.onTapCategory,
    required this.onTapQuickLog,
  });

  @override
  Widget build(BuildContext context) {
    // Compute savings progress fraction and percentage
    final double fraction = weeklySavingsTarget > 0
        ? (currentSaved / weeklySavingsTarget).clamp(0.0, 1.0)
        : 1.0;
    final int percent = (fraction * 100).toInt();

    final contrastBtnBg = isDark ? Colors.white : const Color(0xFF0C0C0C);
    final contrastBtnFg = isDark ? const Color(0xFF0C0C0C) : Colors.white;

    return Row(
      children: [
        // Button 1: Tabungan with Mini Circular Progress Ring
        Expanded(
          child: _buildButton(
            context: context,
            backgroundColor: cardColor,
            onTap: onTapSavings,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: fraction,
                        strokeWidth: 2.5,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          PirschColors.mintGreen,
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tabungan',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Button 2: Kategori Navigation
        Expanded(
          child: _buildButton(
            context: context,
            backgroundColor: cardColor,
            onTap: onTapCategory,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 22,
                  color: const Color(0xFF60A5FA),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kategori',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Button 3: Catat Jajan (High-contrast prominent pill)
        Expanded(
          child: _buildButton(
            context: context,
            backgroundColor: contrastBtnBg,
            onTap: onTapQuickLog,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 24,
                      color: contrastBtnFg,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Catat',
                      style: TextStyle(
                        color: contrastBtnFg,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),

                // Indicator dot if passive transaction pending
                if (pendingCount > 0)
                  Positioned(
                    top: -2,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: PirschColors.coralOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required Color backgroundColor,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 68,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: child,
        ),
      ),
    );
  }
}
