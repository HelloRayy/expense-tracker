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

  static const makanan = ExpenseCategory(
    id: 'Makanan',
    displayName: 'Makanan',
    icon: Icons.restaurant_rounded,
    color: PirschColors.coralOrange,
  );

  static const kopi = ExpenseCategory(
    id: 'Kopi & Minum',
    displayName: 'Kopi & Minum',
    icon: Icons.local_cafe_rounded,
    color: PirschColors.mintGreen,
  );

  static const transport = ExpenseCategory(
    id: 'Transport',
    displayName: 'Transport',
    icon: Icons.directions_car_rounded,
    color: Color(0xFF60A5FA),
  );

  static const belanja = ExpenseCategory(
    id: 'Belanja',
    displayName: 'Belanja/QRIS',
    icon: Icons.shopping_bag_rounded,
    color: PirschColors.warmYellow,
  );

  /// All registered canonical categories.
  static const List<ExpenseCategory> all = [
    makanan,
    kopi,
    transport,
    belanja,
  ];

  /// Resolves any string or alias into a canonical ExpenseCategory.
  /// Gracefully normalizes legacy strings like 'Kopi' -> 'Kopi & Minum', 'Belanja/QRIS' -> 'Belanja'.
  static ExpenseCategory? fromId(String? id) {
    if (id == null) return null;
    final normalized = id.toLowerCase().trim();
    if (normalized.contains('makan')) return makanan;
    if (normalized.contains('kopi') || normalized.contains('minum')) return kopi;
    if (normalized.contains('transpor')) return transport;
    if (normalized.contains('belanja') || normalized.contains('qris')) return belanja;
    return null;
  }
}
