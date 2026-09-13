import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budget/models/expense_model.dart';

/// Modern transaction row matching Reference Design 1:
/// - Circular avatar icon with subtle tinted background
/// - Note title and categorized subtitle (e.g. Food • 12:21 PM)
/// - Right-aligned amount with color and "Expense" label below
class ExpenseListItem extends StatelessWidget {
  final ExpenseModel exp;
  final Color cardColor;
  final Color borderColor;
  final Color? dividerColor;
  final Color textPrimary;
  final Color textSecondary;
  final ValueChanged<int> onDelete;

  const ExpenseListItem({
    super.key,
    required this.exp,
    required this.cardColor,
    required this.borderColor,
    this.dividerColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine category icon and category display name
    final noteLower = exp.note.toLowerCase();
    final IconData itemIcon;
    final String categoryName;

    if (exp.categoryId != null && exp.categoryId!.isNotEmpty) {
      categoryName = exp.categoryId!;
      if (categoryName.contains('Makan') || categoryName.contains('Food')) {
        itemIcon = Icons.restaurant_rounded;
      } else if (categoryName.contains('Kopi') || categoryName.contains('Minum')) {
        itemIcon = Icons.local_cafe_rounded;
      } else if (categoryName.contains('Transpor')) {
        itemIcon = Icons.directions_car_rounded;
      } else if (categoryName.contains('Belanja')) {
        itemIcon = Icons.shopping_bag_rounded;
      } else {
        itemIcon = Icons.receipt_long_rounded;
      }
    } else if (noteLower.contains('kopi') || noteLower.contains('coffee')) {
      itemIcon = Icons.local_cafe_rounded;
      categoryName = 'Kopi & Minum';
    } else if (noteLower.contains('makan') || noteLower.contains('nasi') || noteLower.contains('mie') || noteLower.contains('ayam')) {
      itemIcon = Icons.restaurant_rounded;
      categoryName = 'Makanan';
    } else if (noteLower.contains('shopee') || noteLower.contains('tokopedia') || noteLower.contains('belanja')) {
      itemIcon = Icons.shopping_bag_rounded;
      categoryName = 'Belanja';
    } else if (noteLower.contains('transport') || noteLower.contains('bensin') || noteLower.contains('gojek') || noteLower.contains('grab') || noteLower.contains('uber')) {
      itemIcon = Icons.directions_car_rounded;
      categoryName = 'Transport';
    } else {
      itemIcon = Icons.receipt_long_rounded;
      categoryName = 'Belum berkategori';
    }

    // Time formatted as HH:mm
    final hour = exp.createdAt.hour.toString().padLeft(2, '0');
    final minute = exp.createdAt.minute.toString().padLeft(2, '0');
    final timeFormatted = '$hour:$minute';

    return Dismissible(
      key: Key(exp.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: PirschColors.roseRed.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (dir) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Hapus Catatan?',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Yakin ingin menghapus catatan ${CurrencyFormatter.format(exp.amount)} (${exp.note})?',
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
                child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            // Circular Avatar Container matching Reference Image 1
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF18181B) : const Color(0xFFEFF2F8),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                itemIcon,
                color: isDark ? Colors.white : const Color(0xFF242424),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Middle Column: Note & Category + Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (exp.note.trim().isEmpty || exp.note.trim() == 'Jajan') ? 'Pengeluaran' : exp.note,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$categoryName • $timeFormatted',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right Column: Amount (-Rp 18.000) & Status Tag ("Expense")
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${CurrencyFormatter.format(exp.amount)}',
                  style: const TextStyle(
                    color: PirschColors.roseRed,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Expense',
                  style: TextStyle(
                    color: textSecondary.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: elevatedColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded, color: PirschColors.primaryBlue, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada transaksi terbaru',
            style: TextStyle(
              color: textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Catatan pengeluaranmu akan muncul di sini. Ketuk tombol (+) untuk mencatat!',
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
