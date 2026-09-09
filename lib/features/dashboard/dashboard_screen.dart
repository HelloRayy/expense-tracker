import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../budget/repository/budget_repository.dart';
import '../categories/screens/category_assignment_screen.dart';
import '../expense_catalog/screens/expense_catalog_screen.dart';
import '../quick_log/quick_log_dialog.dart';
import '../settings/screens/budget_settings_detail_screen.dart';
import '../settings/screens/settings_screen.dart';
import '../settings/screens/shopee_settings_screen.dart';
import 'widgets/ambient_glow_background.dart';
import 'widgets/category_section.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/expense_list_item.dart';
import 'widgets/floating_capsule_navbar.dart';
import 'widgets/hero_balance_card.dart';
import 'widgets/nudge_banner.dart';

/// Main Dashboard Screen.
/// Orchestrates top-level state, pull-to-refresh, lifecycle reloading,
/// and composited modular sub-widgets.
class DashboardScreen extends StatefulWidget {
  final BudgetRepository repository;

  const DashboardScreen({super.key, required this.repository});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  bool _showAllTransactions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.repository.loadData();
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(repository: widget.repository),
      ),
    );
  }

  void _openBudgetDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BudgetSettingsDetailScreen(repository: widget.repository),
      ),
    );
  }

  void _openShopee() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShopeeSettingsScreen(repository: widget.repository),
      ),
    );
  }

  void _openQuickLog() {
    QuickLogDialog.show(
      context,
      repository: widget.repository,
      onComplete: () => setState(() {}),
    );
  }

  void _openExpenseCatalog([String category = 'Semua']) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseCatalogScreen(
          repository: widget.repository,
          initialCategory: category,
        ),
      ),
    );
  }

  void _openCategoryAssignment(String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryAssignmentScreen(
          repository: widget.repository,
          selectedCategoryId: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = PirschColors.bg(isDark);
    final cardColor = PirschColors.card(isDark);
    final elevatedColor = PirschColors.cardElevated(isDark);
    final borderColor = PirschColors.border(isDark);
    final textPrimary = PirschColors.textPrimary(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);

    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        if (widget.repository.isLoading) {
          return Scaffold(
            backgroundColor: bgColor,
            body: const Center(
              child: CircularProgressIndicator(color: PirschColors.mintGreen),
            ),
          );
        }

        final budget = widget.repository.budget;
        final remaining = widget.repository.remainingBalance;
        final spent = widget.repository.totalSpent;
        final dailyAllowance = widget.repository.dailyAllowance;
        final remainingToday = widget.repository.remainingToday;
        final expenses = widget.repository.expenses;
        final displayedExpenses = _showAllTransactions ? expenses : expenses.take(5).toList();
        final isOverBudget = remaining < 0 || remainingToday < 0;
        final isWarning = !isOverBudget && (remainingToday < 20000 || remaining < dailyAllowance);
        final ambientColor = PirschColors.ambientGlowColor(
          isDark: isDark,
          isOverBudget: isOverBudget,
          isWarning: isWarning,
        );
        final dividerColor = PirschColors.divider(isDark);

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              // Ambient radial glow matching landing page aesthetic
              AmbientGlowBackground(glowColor: ambientColor),

              // Main scrollable body
              RefreshIndicator(
                color: PirschColors.mintGreen,
                backgroundColor: cardColor,
                onRefresh: widget.repository.loadData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Top App Bar
                    SliverSafeArea(
                      bottom: false,
                      sliver: SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: DashboardHeader(
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            elevatedColor: elevatedColor,
                            borderColor: borderColor,
                            onSettingsTap: _openSettings,
                          ),
                        ),
                      ),
                    ),

                    // Content Section
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 8),

                          // Hero Balance Card
                          HeroBalanceCard(
                            remaining: remaining,
                            spent: spent,
                            remainingToday: remainingToday,
                            formattedPeriod: budget?.formattedPeriod ?? '',
                            isOverBudget: isOverBudget,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onTapPeriod: _openBudgetDetail,
                            onTapMenu: _openSettings,
                          ),
                          const SizedBox(height: 12),

                          // Secondary Nudge & Action Card
                          NudgeBanner(
                            weeklyIncome: widget.repository.weeklyIncome,
                            dailyAllowance: dailyAllowance,
                            isOverBudget: isOverBudget,
                            cardColor: cardColor,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            isDark: isDark,
                            onConfigureBudget: _openBudgetDetail,
                            onQuickLog: _openQuickLog,
                          ),
                          const SizedBox(height: 24),

                          // Spending by Category (Horizontal Scroll)
                          CategorySection(
                            expenses: expenses,
                            cardColor: cardColor,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onSelectCategory: _openCategoryAssignment,
                          ),
                          const SizedBox(height: 24),

                          // Recent Transactions Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Transaksi Terbaru',
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
                              if (expenses.isNotEmpty)
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: expenses.length > 5
                                        ? () {
                                            setState(() {
                                              _showAllTransactions = !_showAllTransactions;
                                            });
                                          }
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: elevatedColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Text(
                                        expenses.length > 5 && !_showAllTransactions
                                            ? '5 dari ${expenses.length}'
                                            : '${expenses.length} Transaksi',
                                        style: TextStyle(
                                          color: expenses.length > 5
                                              ? PirschColors.mintGreen
                                              : textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Transactions List
                          if (expenses.isEmpty)
                            EmptyExpensesPlaceholder(
                              elevatedColor: elevatedColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            )
                          else ...[
                            ...displayedExpenses.map((exp) => ExpenseListItem(
                                  exp: exp,
                                  cardColor: cardColor,
                                  borderColor: borderColor,
                                  dividerColor: dividerColor,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  onDelete: (id) => widget.repository.deleteExpense(id),
                                )),
                            if (expenses.length > 5) ...[
                              const SizedBox(height: 10),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _showAllTransactions = !_showAllTransactions;
                                    });
                                  },
                                  icon: Icon(
                                    _showAllTransactions
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: PirschColors.mintGreen,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _showAllTransactions
                                        ? 'Tampilkan Lebih Sedikit'
                                        : 'Lihat Semua (${expenses.length} Transaksi)',
                                    style: const TextStyle(
                                      color: PirschColors.mintGreen,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],

                          // Padding space for floating bottom bar
                          const SizedBox(height: 110),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Capsule Bottom Navigation Bar
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: FloatingCapsuleNavbar(
                  isDark: isDark,
                  borderColor: borderColor,
                  textSecondary: textSecondary,
                  onTapShopee: _openShopee,
                  onTapQuickLog: _openQuickLog,
                  onTapCatalog: () => _openExpenseCatalog('Semua'),
                  onTapSettings: _openSettings,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
