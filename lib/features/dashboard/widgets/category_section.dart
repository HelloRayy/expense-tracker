import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budget/models/expense_model.dart';

/// Spending by Category horizontal card section for Dashboard.
/// Tapping any category card or header navigates to the standalone ExpenseCatalogScreen.
class CategorySection extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final ValueChanged<String> onSelectCategory;

  const CategorySection({
    super.key,
    required this.expenses,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    int foodTotal = 0;
    int coffeeTotal = 0;
    int transportTotal = 0;
    int shoppingTotal = 0;

    for (final exp in expenses) {
      final note = exp.note.toLowerCase();
      if (note.contains('kopi') || note.contains('coffee') || note.contains('minum') || note.contains('jus')) {
        coffeeTotal += exp.amount;
      } else if (note.contains('makan') || note.contains('lunch') || note.contains('dinner') || note.contains('nasi') || note.contains('mie')) {
        foodTotal += exp.amount;
      } else if (note.contains('ojek') || note.contains('gojek') || note.contains('grab') || note.contains('bensin') || note.contains('parkir')) {
        transportTotal += exp.amount;
      } else {
        shoppingTotal += exp.amount;
      }
    }

    final categories = [
      {'icon': Icons.restaurant_rounded, 'color': PirschColors.coralOrange, 'title': 'Makanan', 'total': foodTotal, 'category': 'Makanan'},
      {'icon': Icons.local_cafe_rounded, 'color': PirschColors.mintGreen, 'title': 'Kopi & Minum', 'total': coffeeTotal, 'category': 'Kopi'},
      {'icon': Icons.directions_car_rounded, 'color': const Color(0xFF60A5FA), 'title': 'Transport', 'total': transportTotal, 'category': 'Transport'},
      {'icon': Icons.shopping_bag_rounded, 'color': PirschColors.warmYellow, 'title': 'Belanja/QRIS', 'total': shoppingTotal, 'category': 'Belanja'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onSelectCategory('Semua'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Kategori Pengeluaran',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Buka katalog',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 16, color: textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Category Cards
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, index) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final cat = categories[i];
              final catColor = cat['color'] as Color;
              return InkWell(
                onTap: () => onSelectCategory(cat['category'] as String),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(cat['icon'] as IconData, size: 16, color: catColor),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: PirschColors.mintGreen),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat['title'] as String,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cat['total'] == 0 ? 'Rp 0' : CurrencyFormatter.formatCompact(cat['total'] as int),
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
