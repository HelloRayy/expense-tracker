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
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Nav 1: Home (Active)
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home_rounded, color: PirschColors.mintGreen, size: 26),
            onPressed: () {},
          ),

          // Nav 2: Shopee / Integrations
          IconButton(
            tooltip: 'Shopee & Scanner',
            icon: Icon(Icons.storefront_rounded, color: textSecondary, size: 24),
            onPressed: onTapShopee,
          ),

          // Nav Center: (+) Prominent Quick Log Button
          GestureDetector(
            onTap: onTapQuickLog,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: PirschColors.mintGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 28),
            ),
          ),

          // Nav 4: Expense Catalog Cards
          IconButton(
            tooltip: 'Katalog Kartu Jajan',
            icon: Icon(Icons.grid_view_rounded, color: textSecondary, size: 24),
            onPressed: onTapCatalog,
          ),

          // Nav 5: Settings
          IconButton(
            tooltip: 'Pengaturan',
            icon: Icon(Icons.tune_rounded, color: textSecondary, size: 24),
            onPressed: onTapSettings,
          ),
        ],
      ),
    );
  }
}
