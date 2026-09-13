import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../categories/models/expense_category.dart';

/// Interactive centered capsule pill for selecting an expense category
/// within QuickLogDialog / Kalkulator Jajan bottom sheet.
class CategoryPillSelector extends StatelessWidget {
  final ExpenseCategory selectedCategory;
  final ValueChanged<ExpenseCategory> onCategoryChanged;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const CategoryPillSelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  void _showPicker(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sheetBg = isDark ? const Color(0xFF161618) : Colors.white;
        final itemBg = isDark ? const Color(0xFF1F1F23) : const Color(0xFFF4F5FA);

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.1),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Pilih Kategori',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 14),

              // Category options list
              ...ExpenseCategory.all.map((cat) {
                final isSelected = cat.id == selectedCategory.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected ? itemBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onCategoryChanged(cat);
                        Navigator.of(ctx).pop();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: cat.color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(cat.icon, size: 18, color: cat.color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cat.displayName,
                                style: TextStyle(
                                  color: isSelected ? textPrimary : textSecondary,
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: PirschColors.primaryBlue,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pillBg = isDark ? const Color(0xFF1E1E22) : const Color(0xFFEFF2F8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPicker(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selectedCategory.icon,
                size: 15,
                color: selectedCategory.color,
              ),
              const SizedBox(width: 6),
              Text(
                selectedCategory.displayName,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
