import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Data model representing a reusable quick expense card preset.
class ExpensePresetModel {
  final String id;
  final String title;
  final int amount;
  final String category;
  final IconData icon;
  final Color color;

  const ExpensePresetModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'icon_name': _nameFromIcon(icon),
      'color_value': color.toARGB32(),
    };
  }

  factory ExpensePresetModel.fromMap(Map<String, dynamic> map) {
    final iconName = map['icon_name'] as String? ?? 'receipt';
    final colorValue = map['color_value'] as int? ?? 0xFF00D47E;
    return ExpensePresetModel(
      id: map['id'] as String? ?? UniqueKey().toString(),
      title: map['title'] as String? ?? 'Jajan',
      amount: map['amount'] as int? ?? 0,
      category: map['category'] as String? ?? 'Makanan',
      icon: iconFromName(iconName),
      color: Color(colorValue),
    );
  }

  static IconData iconFromName(String name) {
    switch (name) {
      case 'cafe':
        return Icons.local_cafe_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'ramen':
        return Icons.ramen_dining_rounded;
      case 'beverage':
        return Icons.emoji_food_beverage_rounded;
      case 'two_wheeler':
        return Icons.two_wheeler_rounded;
      case 'gas_station':
        return Icons.local_gas_station_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'parking':
        return Icons.local_parking_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  static String _nameFromIcon(IconData icon) {
    if (icon == Icons.local_cafe_rounded) return 'cafe';
    if (icon == Icons.restaurant_rounded) return 'restaurant';
    if (icon == Icons.ramen_dining_rounded) return 'ramen';
    if (icon == Icons.emoji_food_beverage_rounded) return 'beverage';
    if (icon == Icons.two_wheeler_rounded) return 'two_wheeler';
    if (icon == Icons.local_gas_station_rounded) return 'gas_station';
    if (icon == Icons.shopping_bag_rounded) return 'shopping';
    if (icon == Icons.local_parking_rounded) return 'parking';
    return 'receipt';
  }

  /// Default curated starter presets matching common daily expenses.
  static List<ExpensePresetModel> get defaultPresets => [
    const ExpensePresetModel(
      id: 'kopi_kenangan',
      title: 'Kopi Kenangan',
      amount: 15000,
      category: 'Kopi',
      icon: Icons.local_cafe_rounded,
      color: PirschColors.mintGreen,
    ),
    const ExpensePresetModel(
      id: 'nasi_padang',
      title: 'Nasi Padang',
      amount: 25000,
      category: 'Makanan',
      icon: Icons.restaurant_rounded,
      color: PirschColors.coralOrange,
    ),
    const ExpensePresetModel(
      id: 'mie_ayam',
      title: 'Mie Ayam / Bakso',
      amount: 18000,
      category: 'Makanan',
      icon: Icons.ramen_dining_rounded,
      color: PirschColors.coralOrange,
    ),
    const ExpensePresetModel(
      id: 'es_teh_boba',
      title: 'Es Teh / Minum Dingin',
      amount: 8000,
      category: 'Kopi',
      icon: Icons.emoji_food_beverage_rounded,
      color: PirschColors.mintGreen,
    ),
    const ExpensePresetModel(
      id: 'ojek_online',
      title: 'Ojek Online',
      amount: 14000,
      category: 'Transport',
      icon: Icons.two_wheeler_rounded,
      color: Color(0xFF60A5FA),
    ),
    const ExpensePresetModel(
      id: 'bensin_motor',
      title: 'Bensin Motor',
      amount: 20000,
      category: 'Transport',
      icon: Icons.local_gas_station_rounded,
      color: Color(0xFF60A5FA),
    ),
    const ExpensePresetModel(
      id: 'snack_indomaret',
      title: 'Camilan / Minimarket',
      amount: 12000,
      category: 'Belanja',
      icon: Icons.shopping_bag_rounded,
      color: PirschColors.warmYellow,
    ),
    const ExpensePresetModel(
      id: 'parkir',
      title: 'Uang Parkir',
      amount: 3000,
      category: 'Transport',
      icon: Icons.local_parking_rounded,
      color: Color(0xFF60A5FA),
    ),
  ];
}
