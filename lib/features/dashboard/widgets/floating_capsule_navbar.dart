import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Floating Capsule Bottom Navigation Bar for Dashboard.
/// Provides quick access to Home, Shopee Scanner, Quick Log (+), Expense Catalog, and Settings.
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      constraints: const BoxConstraints(maxWidth: 326),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.09),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

          // Nav 2: Shopee / Integrations
          IconButton(
            tooltip: 'Shopee & Scanner',
            icon: Icon(Icons.storefront_rounded, color: textSecondary, size: 22),
            onPressed: onTapShopee,
          ),

          // Nav Center: (+) Quick Log Action Button
          GestureDetector(
            onTap: onTapQuickLog,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: PirschColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
          ),

          // Nav 4: Expense Catalog Cards
          IconButton(
            tooltip: 'Katalog Kartu Jajan',
            icon: Icon(Icons.grid_view_rounded, color: textSecondary, size: 22),
            onPressed: onTapCatalog,
          ),

          // Nav 5: Settings
          IconButton(
            tooltip: 'Pengaturan',
            icon: Icon(Icons.tune_rounded, color: textSecondary, size: 22),
            onPressed: onTapSettings,
          ),
        ],
      ),
    );
  }
}
