import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budget/models/expense_model.dart';

/// Interactive transaction tile in CategoryAssignmentScreen with checkbox and category status.
class CategoryTransactionTile extends StatelessWidget {
  final ExpenseModel expense;
  final bool isChecked;
  final String selectedCategoryId;
  final VoidCallback onToggle;
  final bool isDark;

  const CategoryTransactionTile({
    super.key,
    required this.expense,
    required this.isChecked,
    required this.selectedCategoryId,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = PirschColors.textPrimary(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);
    final cardBg = PirschColors.card(isDark);
    final borderColor = PirschColors.border(isDark);

    final bool isReassigning = isChecked &&
        expense.categoryId != null &&
        expense.categoryId != selectedCategoryId;

    final bool isPreviousMember = !isChecked &&
        expense.categoryId == selectedCategoryId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isChecked ? cardBg : cardBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChecked ? PirschColors.mintGreen.withValues(alpha: 0.5) : borderColor,
          width: isChecked ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Custom Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isChecked ? PirschColors.mintGreen : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isChecked ? PirschColors.mintGreen : textSecondary.withValues(alpha: 0.5),
                      width: 2.0,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, size: 16, color: Colors.black)
                      : null,
                ),
                const SizedBox(width: 14),

                // Note and Time Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        expense.note,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            expense.formattedTime,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (isReassigning)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: PirschColors.warmYellow.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Pindah dari ${expense.categoryId}',
                                style: const TextStyle(
                                  color: PirschColors.warmYellow,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else if (isPreviousMember)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: PirschColors.roseRed.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Akan dicabut',
                                style: TextStyle(
                                  color: PirschColors.roseRed,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else if (expense.categoryId != null && !isChecked)
                            Text(
                              '• ${expense.categoryId}',
                              style: TextStyle(
                                color: textSecondary.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  '- ${CurrencyFormatter.format(expense.amount)}',
                  style: TextStyle(
                    color: isChecked ? PirschColors.red(isDark) : textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
