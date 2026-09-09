import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budget/repository/budget_repository.dart';
import '../services/category_assign_evaluator.dart';
import '../widgets/category_save_bar.dart';
import '../widgets/category_transaction_tile.dart';

/// Standalone Screen for assigning/reassigning transactions to a selected category.
/// Holds reversible client-side pending selections and commits in a single atomic DB batch.
class CategoryAssignmentScreen extends StatefulWidget {
  final BudgetRepository repository;
  final String selectedCategoryId;

  const CategoryAssignmentScreen({
    super.key,
    required this.repository,
    required this.selectedCategoryId,
  });

  @override
  State<CategoryAssignmentScreen> createState() => _CategoryAssignmentScreenState();
}

class _CategoryAssignmentScreenState extends State<CategoryAssignmentScreen> {
  late Map<int, String?> _initialCategories;
  late Set<int> _pendingSelectedIds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initSelectionState();
  }

  void _initSelectionState() {
    _initialCategories = {};
    for (final exp in widget.repository.expenses) {
      if (exp.id != null) {
        _initialCategories[exp.id!] = exp.categoryId;
      }
    }
    _pendingSelectedIds = CategoryAssignEvaluator.buildInitialSelection(
      initialCategories: _initialCategories,
      selectedCategoryId: widget.selectedCategoryId,
    );
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_pendingSelectedIds.contains(id)) {
        _pendingSelectedIds.remove(id);
      } else {
        _pendingSelectedIds.add(id);
      }
    });
  }

  Future<void> _commitChanges() async {
    final diff = CategoryAssignEvaluator.computeDiff(
      initialCategories: _initialCategories,
      pendingSelectedIds: _pendingSelectedIds,
      selectedCategoryId: widget.selectedCategoryId,
    );

    if (!diff.hasChanges || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      await widget.repository.batchAssignCategory(
        assignIds: diff.toAssign,
        targetCategoryId: widget.selectedCategoryId,
        unassignIds: diff.toUnassign,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: PirschColors.card(Theme.of(context).brightness == Brightness.dark),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: PirschColors.mintGreen, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${diff.totalChanges} transaksi berhasil dimasukkan ke ${widget.selectedCategoryId}!',
                    style: TextStyle(
                      color: PirschColors.textPrimary(Theme.of(context).brightness == Brightness.dark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = PirschColors.bg(isDark);
    final textPrimary = PirschColors.textPrimary(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);
    final expenses = widget.repository.expenses;

    final diff = CategoryAssignEvaluator.computeDiff(
      initialCategories: _initialCategories,
      pendingSelectedIds: _pendingSelectedIds,
      selectedCategoryId: widget.selectedCategoryId,
    );

    // Calculate total spend currently checked for this category
    int totalSelectedAmount = 0;
    for (final exp in expenses) {
      if (exp.id != null && _pendingSelectedIds.contains(exp.id)) {
        totalSelectedAmount += exp.amount;
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 24),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: PirschColors.mintGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: PirschColors.mintGreen.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'Total: ${CurrencyFormatter.formatCompact(totalSelectedAmount)}',
                      style: const TextStyle(
                        color: PirschColors.mintGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Large Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.selectedCategoryId,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Centang transaksi untuk memasukkan ke kategori ini.',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // Transactions Checklist Body
            Expanded(
              child: expenses.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada transaksi pengeluaran.',
                        style: TextStyle(color: textSecondary, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      physics: const BouncingScrollPhysics(),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final exp = expenses[index];
                        final isChecked = exp.id != null && _pendingSelectedIds.contains(exp.id);

                        return CategoryTransactionTile(
                          expense: exp,
                          isChecked: isChecked,
                          selectedCategoryId: widget.selectedCategoryId,
                          onToggle: () {
                            if (exp.id != null) _toggleSelection(exp.id!);
                          },
                          isDark: isDark,
                        );
                      },
                    ),
            ),

            // Sticky Bottom Save Bar
            CategorySaveBar(
              diff: diff,
              isSaving: _isSaving,
              onSave: _commitChanges,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}
