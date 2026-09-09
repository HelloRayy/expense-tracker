import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budget/models/expense_model.dart';

/// Single transaction row in Dashboard with dismissible swipe-to-delete.
class ExpenseListItem extends StatelessWidget {
  final ExpenseModel exp;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final ValueChanged<int> onDelete;

  const ExpenseListItem({
    super.key,
    required this.exp,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Choose vector icon and accent color by note keyword
    final noteLower = exp.note.toLowerCase();
    final IconData itemIcon;
    final Color itemColor;
    if (noteLower.contains('kopi') || noteLower.contains('coffee')) {
      itemIcon = Icons.local_cafe_rounded;
      itemColor = PirschColors.mintGreen;
    } else if (noteLower.contains('makan') || noteLower.contains('nasi') || noteLower.contains('mie')) {
      itemIcon = Icons.restaurant_rounded;
      itemColor = PirschColors.coralOrange;
    } else if (noteLower.contains('shopee') || noteLower.contains('tokopedia') || noteLower.contains('belanja')) {
      itemIcon = Icons.shopping_bag_rounded;
      itemColor = PirschColors.warmYellow;
    } else if (noteLower.contains('transport') || noteLower.contains('bensin') || noteLower.contains('gojek') || noteLower.contains('grab')) {
      itemIcon = Icons.directions_car_rounded;
      itemColor = const Color(0xFF60A5FA);
    } else {
      itemIcon = Icons.receipt_long_rounded;
      itemColor = PirschColors.mintGreen;
    }

    return Dismissible(
      key: Key(exp.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: PirschColors.roseRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (dir) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Hapus Catatan?', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
            content: Text(
              'Yakin ingin menghapus catatan jajan ${CurrencyFormatter.format(exp.amount)} (${exp.note})?',
              style: TextStyle(color: textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Batal', style: TextStyle(color: textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PirschColors.roseRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Hapus', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        if (exp.id != null) {
          onDelete(exp.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Catatan jajan ${exp.note} dihapus'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: itemColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: itemColor.withValues(alpha: 0.25)),
              ),
              alignment: Alignment.center,
              child: Icon(itemIcon, color: itemColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.note,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    exp.formattedTime,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '- ${CurrencyFormatter.format(exp.amount)}',
              style: const TextStyle(
                color: PirschColors.roseRed,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state placeholder when no transactions have been logged.
class EmptyExpensesPlaceholder extends StatelessWidget {
  final Color elevatedColor;
  final Color textPrimary;
  final Color textSecondary;

  const EmptyExpensesPlaceholder({
    super.key,
    required this.elevatedColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: elevatedColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.savings_outlined, color: PirschColors.mintGreen, size: 36),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada catatan jajan',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Saldo jajanmu masih utuh. Ketuk tombol (+) di bawah untuk mencatat pengeluaran!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
