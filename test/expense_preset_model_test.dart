import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/core/constants/app_colors.dart';
import 'package:jajan_tracker/features/expense_catalog/models/expense_preset_model.dart';

void main() {
  group('ExpensePresetModel Tests', () {
    test('defaultPresets contains curated routine expenses', () {
      final presets = ExpensePresetModel.defaultPresets;
      expect(presets, isNotEmpty);

      final kopi = presets.firstWhere((p) => p.title == 'Kopi Kenangan');
      expect(kopi.amount, 15000);
      expect(kopi.category, 'Kopi');
      expect(kopi.icon, Icons.local_cafe_rounded);

      final padang = presets.firstWhere((p) => p.title == 'Nasi Padang');
      expect(padang.amount, 25000);
      expect(padang.category, 'Makanan');
    });

    test('serialization toMap and fromMap works symmetrically', () {
      const preset = ExpensePresetModel(
        id: 'test_card',
        title: 'Sate Padang',
        amount: 30000,
        category: 'Makanan',
        icon: Icons.restaurant_rounded,
        color: PirschColors.coralOrange,
      );

      final map = preset.toMap();
      expect(map['id'], 'test_card');
      expect(map['title'], 'Sate Padang');
      expect(map['amount'], 30000);
      expect(map['icon_name'], 'restaurant');

      final deserialized = ExpensePresetModel.fromMap(map);
      expect(deserialized.id, 'test_card');
      expect(deserialized.title, 'Sate Padang');
      expect(deserialized.amount, 30000);
      expect(deserialized.category, 'Makanan');
      expect(deserialized.icon, Icons.restaurant_rounded);
    });

    test('iconFromName falls back to default receipt icon', () {
      expect(ExpensePresetModel.iconFromName('cafe'), Icons.local_cafe_rounded);
      expect(ExpensePresetModel.iconFromName('unknown_icon'), Icons.receipt_long_rounded);
    });
  });
}
