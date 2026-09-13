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

    // Color palette matching the reference image
    final darkBtnBg = isDark ? const Color(0xFF1E1E22) : const Color(0xFFF1F3F5);
    final darkBtnFg = isDark ? Colors.white : const Color(0xFF1A1A1E);
    final darkBtnLabel = isDark
        ? Colors.white.withValues(alpha: 0.92)
        : const Color(0xFF1A1A1E);

    final contrastBtnBg = isDark ? Colors.white : const Color(0xFF0F0F12);
    final contrastBtnFg = isDark ? const Color(0xFF0F0F12) : Colors.white;

    return Row(
      children: [
        // Button 1: Tabungan with Mini Circular Progress Ring
        Expanded(
          child: _buildButton(
            context: context,
            backgroundColor: darkBtnBg,
            onTap: onTapSavings,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: fraction,
                        strokeWidth: 2.2,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? PirschColors.mintGreen : const Color(0xFF059669),
                        ),
                      ),
                      Text(
                        '$percent',
                        style: TextStyle(
                          color: darkBtnFg,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Tabungan',
                  style: TextStyle(
                    color: darkBtnLabel,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
            backgroundColor: darkBtnBg,
            onTap: onTapCategory,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 21,
                  color: darkBtnFg,
                ),
                const SizedBox(height: 5),
                Text(
                  'Kategori',
                  style: TextStyle(
                    color: darkBtnLabel,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Button 3: Catat (High-contrast prominent thumb button)
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
                      size: 22,
                      color: contrastBtnFg,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Catat',
                      style: TextStyle(
                        color: contrastBtnFg,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),

                // Indicator dot if passive transaction pending
                if (pendingCount > 0)
                  Positioned(
                    top: 6,
                    right: 8,
                    child: Container(
                      width: 7,
                      height: 7,
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
        splashColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        highlightColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        child: Container(
          height: 74,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: child,
        ),
      ),
    );
  }
}
