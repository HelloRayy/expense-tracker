import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budget/repository/budget_repository.dart';
import '../models/expense_category.dart';
import '../widgets/category_transaction_tile.dart';

/// Standalone Screen for assigning/reassigning transactions to categories.
/// Features swipeable tabs (Makanan, Kopi & Minum, Transport, Belanja),
/// unboxed transaction items with bottom border only,
/// and a floating full-width CTA without background container.
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

class _CategoryAssignmentScreenState extends State<CategoryAssignmentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<ExpenseCategory> _categories = ExpenseCategory.all;

  late Map<int, String?> _initialCategories;
  late Map<int, String?> _pendingCategories;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initSelectionState();

    final initialIndex = _categories.indexWhere(
      (c) => c.id.toLowerCase() == widget.selectedCategoryId.toLowerCase(),
    );
    _tabController = TabController(
      length: _categories.length,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
      vsync: this,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initSelectionState() {
    _initialCategories = {};
    _pendingCategories = {};
    for (final exp in widget.repository.expenses) {
      if (exp.id != null) {
        _initialCategories[exp.id!] = exp.categoryId;
        _pendingCategories[exp.id!] = exp.categoryId;
      }
    }
  }

  void _toggleSelection(int id, String categoryId) {
    setState(() {
      if (_pendingCategories[id] == categoryId) {
        // Uncheck -> unassigned (null)
        _pendingCategories[id] = null;
      } else {
        // Check -> assign to this category
        _pendingCategories[id] = categoryId;
      }
    });
  }

  int get _totalChanges {
    int count = 0;
    for (final entry in _pendingCategories.entries) {
      if (entry.value != _initialCategories[entry.key]) {
        count++;
      }
    }
    return count;
  }

  Future<void> _commitChanges() async {
    final Map<int, String?> diffUpdates = {};
    for (final entry in _pendingCategories.entries) {
      if (entry.value != _initialCategories[entry.key]) {
        diffUpdates[entry.key] = entry.value;
      }
    }

    if (diffUpdates.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      await widget.repository.batchAssignMultiCategories(diffUpdates);

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
                    '${diffUpdates.length} transaksi berhasil diperbarui!',
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
    final dividerColor = PirschColors.divider(isDark);
    final expenses = widget.repository.expenses;

    final currentCategory = _categories[_tabController.index];

    // Calculate total spend currently assigned to the active tab category
    int totalForCurrentTab = 0;
    for (final exp in expenses) {
      if (exp.id != null && _pendingCategories[exp.id] == currentCategory.id) {
        totalForCurrentTab += exp.amount;
      }
    }

    final totalChanges = _totalChanges;
    final hasChanges = totalChanges > 0;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 20, 0),
                  child: Row(
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
                    ],
                  ),
                ),

                // Category Title Header with Total Badge
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              currentCategory.displayName,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Text(
                            'Total: ${CurrencyFormatter.formatCompact(totalForCurrentTab)}',
                            style: TextStyle(
                              color: PirschColors.green(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Centang transaksi untuk memasukkan ke kategori ini.',
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Slideable Tab Switcher
                Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: dividerColor, width: 1.0)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    physics: const BouncingScrollPhysics(),
                    indicatorColor: PirschColors.mintGreen,
                    indicatorWeight: 2.5,
                    labelColor: textPrimary,
                    unselectedLabelColor: textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                    tabs: _categories.map((cat) {
                      return Tab(text: cat.displayName);
                    }).toList(),
                  ),
                ),

                // Swipeable Tab Content (PageView / TabBarView)
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: _categories.map((cat) {
                      if (expenses.isEmpty) {
                        return Center(
                          child: Text(
                            'Belum ada transaksi pengeluaran.',
                            style: TextStyle(color: textSecondary, fontSize: 14),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 96),
                        physics: const BouncingScrollPhysics(),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final exp = expenses[index];
                          final isChecked = exp.id != null &&
                              _pendingCategories[exp.id] == cat.id;

                          return CategoryTransactionTile(
                            expense: exp,
                            initialCategoryId: _initialCategories[exp.id],
                            isChecked: isChecked,
                            selectedCategoryId: cat.id,
                            onToggle: () {
                              if (exp.id != null) _toggleSelection(exp.id!, cat.id);
                            },
                            isDark: isDark,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // Floating Full-Width CTA (Hidden by default, slides up when changes exist)
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: AnimatedSlide(
                offset: hasChanges ? Offset.zero : const Offset(0, 1.8),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: hasChanges ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: hasChanges && !_isSaving ? _commitChanges : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PirschColors.pill(isDark),
                        foregroundColor: PirschColors.pillText(isDark),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        elevation: 8,
                        shadowColor: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              totalChanges > 1
                                  ? 'Simpan ($totalChanges Perubahan)'
                                  : 'Simpan (1 Perubahan)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
