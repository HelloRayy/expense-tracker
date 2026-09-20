import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Canonical strongly-typed expense category definition.
/// Eliminates ad-hoc string comparisons and unifies category metadata across screens.
class ExpenseCategory {
  final String id;
  final String displayName;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.color,
  });

  static const makananMinuman = ExpenseCategory(
    id: 'Makanan / Minuman',
    displayName: 'Makanan / Minuman',
    icon: Icons.restaurant_rounded,
    color: PirschColors.coralOrange,
  );

  static const transportasi = ExpenseCategory(
    id: 'Transportasi',
    displayName: 'Transportasi',
    icon: Icons.directions_car_rounded,
    color: Color(0xFF60A5FA),
  );

  static const lainnya = ExpenseCategory(
    id: 'Lainnya',
    displayName: 'Lainnya',
    icon: Icons.more_horiz_rounded,
    color: PirschColors.warmYellow,
  );

  static const penyesuaian = ExpenseCategory(
    id: 'Penyesuaian',
    displayName: 'Penyesuaian Saldo',
    icon: Icons.sync_alt_rounded,
    color: Color(0xFFA1A1AA),
  );

  static const topUp = ExpenseCategory(
    id: 'Top Up',
    displayName: 'Top Up Saldo',
    icon: Icons.account_balance_wallet_rounded,
    color: PirschColors.incomeGreen,
  );

  // Backward compatibility aliases
  static const makanan = makananMinuman;
  static const transport = transportasi;
  static const belanja = lainnya;
  static const kopi = makananMinuman;

  /// All registered canonical categories.
  static const List<ExpenseCategory> all = [
    makananMinuman,
    transportasi,
    lainnya,
  ];

  /// Resolves any string or alias into a canonical ExpenseCategory.
  /// Gracefully normalizes legacy strings like 'Kopi', 'Makanan', 'Transport', 'Belanja/QRIS' -> canonical categories.
  static ExpenseCategory? fromId(String? id) {
    if (id == null) return null;
    final normalized = id.toLowerCase().trim();
    if (normalized.contains('penyesuaian') || normalized.contains('koreksi') || normalized.contains('terlupa')) {
      return penyesuaian;
    }
    if (normalized.contains('top up') || normalized.contains('topup')) {
      return topUp;
    }
    if (normalized.contains('makan') ||
        normalized.contains('kopi') ||
        normalized.contains('minum') ||
        normalized.contains('food')) {
      return makananMinuman;
    }
    if (normalized.contains('transpor') ||
        normalized.contains('bensin') ||
        normalized.contains('ojek')) {
      return transportasi;
    }
    if (normalized.contains('belanja') ||
        normalized.contains('qris') ||
        normalized.contains('lain')) {
      return lainnya;
    }
    return lainnya;
  }
}
