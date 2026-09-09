import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/expense_preset_model.dart';

/// Modal bottom sheet to create a new custom expense preset card.
class CreatePresetCardDialog extends StatefulWidget {
  final ValueChanged<ExpensePresetModel> onCreated;

  const CreatePresetCardDialog({super.key, required this.onCreated});

  static Future<void> show(BuildContext context, {required ValueChanged<ExpensePresetModel> onCreated}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreatePresetCardDialog(onCreated: onCreated),
    );
  }

  @override
  State<CreatePresetCardDialog> createState() => _CreatePresetCardDialogState();
}

class _CreatePresetCardDialogState extends State<CreatePresetCardDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Makanan';
  String? _error;

  final _categories = [
    {'name': 'Makanan', 'icon': Icons.restaurant_rounded, 'color': PirschColors.coralOrange},
    {'name': 'Kopi', 'icon': Icons.local_cafe_rounded, 'color': PirschColors.mintGreen},
    {'name': 'Transport', 'icon': Icons.two_wheeler_rounded, 'color': Color(0xFF60A5FA)},
    {'name': 'Belanja', 'icon': Icons.shopping_bag_rounded, 'color': PirschColors.warmYellow},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = CurrencyFormatter.parse(_amountController.text);

    if (title.isEmpty) {
      setState(() => _error = 'Nama jajan tidak boleh kosong');
      return;
    }
    if (amount <= 0) {
      setState(() => _error = 'Nominal harus lebih besar dari Rp 0');
      return;
    }

    final catInfo = _categories.firstWhere((c) => c['name'] == _selectedCategory);
    final newPreset = ExpensePresetModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      amount: amount,
      category: _selectedCategory,
      icon: catInfo['icon'] as IconData,
      color: catInfo['color'] as Color,
    );

    widget.onCreated(newPreset);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final sheetBg = PirschColors.card(isDark);
    final textPrimary = PirschColors.textPrimary(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);
    final borderColor = PirschColors.border(isDark);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Tambah Kartu Jajan Baru',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Buat kartu pengeluaran rutin untuk dimasukkan dengan sekali sentuh.',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Category Selector Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _categories.map((c) {
              final isSelected = c['name'] == _selectedCategory;
              final catColor = c['color'] as Color;
              return InkWell(
                onTap: () => setState(() => _selectedCategory = c['name'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? catColor.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? catColor : borderColor,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(c['icon'] as IconData, size: 14, color: isSelected ? catColor : textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        c['name'] as String,
                        style: TextStyle(
                          color: isSelected ? textPrimary : textSecondary,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Title Input
          TextField(
            controller: _titleController,
            style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              labelText: 'Nama Jajan / Pengeluaran',
              labelStyle: TextStyle(color: textSecondary, fontSize: 13),
              hintText: 'Contoh: Kopi Tuku, Sate Ayam',
              hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.4), fontSize: 13),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PirschColors.mintGreen),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Amount Input
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              labelText: 'Nominal (Rp)',
              labelStyle: TextStyle(color: textSecondary, fontSize: 13),
              hintText: '20000',
              hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.4), fontSize: 13),
              prefixText: 'Rp ',
              prefixStyle: TextStyle(color: PirschColors.green(isDark), fontWeight: FontWeight.w700),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PirschColors.mintGreen),
              ),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: PirschColors.roseRed, fontSize: 12, fontWeight: FontWeight.w600)),
          ],

          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: PirschColors.pill(isDark),
                foregroundColor: PirschColors.pillText(isDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text(
                'Simpan Kartu ke Katalog',
                style: TextStyle(color: PirschColors.pillText(isDark), fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
