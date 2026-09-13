import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

/// Floating Capsule Bottom Navigation Bar for Dashboard.
/// Features an ultra-compact island with minimal vertical/horizontal padding
/// matching the reference design: concentric active pill, tight gaps, and zero bloat.
class FloatingCapsuleNavbar extends StatelessWidget {
  final bool isDark;
  final Color borderColor;
  final Color textSecondary;
  final VoidCallback onTapShopee;
  final VoidCallback onTapQuickLog;
  final VoidCallback onTapCatalog;
  final VoidCallback onTapSettings;

  const FloatingCapsuleNavbar({
    super.key,
    required this.isDark,
    required this.borderColor,
    required this.textSecondary,
    required this.onTapShopee,
    required this.onTapQuickLog,
    required this.onTapCatalog,
    required this.onTapSettings,
  });

  Widget _buildNavItem({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    double iconSize = 22,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        radius: 20,
        splashColor: Colors.transparent,
        highlightColor: isDark ? Colors.white10 : Colors.black12,
        child: SizedBox(
          width: 40,
          height: 44,
          child: Icon(icon, color: textSecondary, size: iconSize),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.fromLTRB(4, 4, 6, 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nav 1: Home (Active Pill matching reference design)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? Colors.white : const Color(0xFF0C0C0C),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.home_rounded,
              color: isDark ? const Color(0xFF0C0C0C) : Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 4),

          // Nav 2: Shopee / Integrations
          _buildNavItem(
            icon: Icons.storefront_rounded,
            tooltip: 'Shopee & Scanner',
            onTap: onTapShopee,
          ),

          const SizedBox(width: 4),

          // Nav Center: (+) Quick Log Action Button
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onTapQuickLog();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: PirschColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            ),
          ),

          const SizedBox(width: 4),

          // Nav 4: Expense Catalog Cards
          _buildNavItem(
            icon: Icons.grid_view_rounded,
            tooltip: 'Katalog Kartu Jajan',
            onTap: onTapCatalog,
          ),

          const SizedBox(width: 4),

          // Nav 5: Settings
          _buildNavItem(
            icon: Icons.tune_rounded,
            tooltip: 'Pengaturan',
            onTap: onTapSettings,
          ),
        ],
      ),
    );
  }
}
