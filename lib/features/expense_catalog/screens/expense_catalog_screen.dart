import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../budget/repository/budget_repository.dart';
import '../models/expense_preset_model.dart';
import '../widgets/catalog_live_header.dart';
import '../widgets/catalog_preset_card.dart';
import '../widgets/create_preset_card_dialog.dart';

/// Standalone screen for card-based instant expense logging ("Masukin Kartu, Bukan Input Manual").
class ExpenseCatalogScreen extends StatefulWidget {
  final BudgetRepository repository;
  final String? initialCategory;

  const ExpenseCatalogScreen({
    super.key,
    required this.repository,
    this.initialCategory,
  });

  @override
  State<ExpenseCatalogScreen> createState() => _ExpenseCatalogScreenState();
}

class _ExpenseCatalogScreenState extends State<ExpenseCatalogScreen> {
  late String _selectedCategory;
  final List<ExpensePresetModel> _presets = [...ExpensePresetModel.defaultPresets];

  final List<String> _categories = [
    'Semua',
    'Makanan',
    'Kopi',
    'Transport',
    'Belanja',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Semua';
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'Semua';
    }
  }

  void _onSelectPreset(ExpensePresetModel preset) async {
    await widget.repository.addExpense(preset.amount, note: preset.title);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PirschColors.card(Theme.of(context).brightness == Brightness.dark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: PirschColors.mintGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${preset.title} berhasil dimasukkan!',
                  style: TextStyle(
                    color: PirschColors.textPrimary(Theme.of(context).brightness == Brightness.dark),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openCreateCardDialog() {
    CreatePresetCardDialog.show(
      context,
      onCreated: (newCard) {
        setState(() {
          _presets.insert(0, newCard);
          _selectedCategory = 'Semua';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = PirschColors.bg(isDark);
    final borderColor = PirschColors.border(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);

    final filteredPresets = _selectedCategory == 'Semua'
        ? _presets
        : _presets.where((p) => p.category == _selectedCategory).toList();

    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Live Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: CatalogLiveHeader(
                      remainingToday: widget.repository.remainingToday,
                      onBack: () => Navigator.of(context).pop(),
                      isDark: isDark,
                    ),
                  ),
                ),

                // Category Filter Bar & Add Card Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 16),
                    child: Row(
                      children: [
                        // Categories Scroll List
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: _categories.map((cat) {
                                final isSelected = cat == _selectedCategory;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(cat),
                                    selected: isSelected,
                                    onSelected: (_) => setState(() => _selectedCategory = cat),
                                    selectedColor: isDark ? Colors.white : Colors.black,
                                    backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFECE7DC),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? (isDark ? Colors.black : Colors.white)
                                          : textSecondary,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: isSelected ? Colors.transparent : borderColor),
                                    ),
                                    showCheckmark: false,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Add Custom Preset Card Button
                        IconButton(
                          tooltip: 'Buat Kartu Baru',
                          onPressed: _openCreateCardDialog,
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: PirschColors.mintGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: PirschColors.mintGreen.withValues(alpha: 0.4)),
                            ),
                            child: const Icon(Icons.add_rounded, color: PirschColors.mintGreen, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Presets 2-Column Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final preset = filteredPresets[index];
                        return CatalogPresetCard(
                          preset: preset,
                          onSelect: _onSelectPreset,
                          isDark: isDark,
                        );
                      },
                      childCount: filteredPresets.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }
}
