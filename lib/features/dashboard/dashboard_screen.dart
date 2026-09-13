import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../budget/repository/budget_repository.dart';
import '../categories/models/expense_category.dart';
import '../categories/screens/category_assignment_screen.dart';
import '../expense_catalog/screens/expense_catalog_screen.dart';
import '../quick_log/quick_log_dialog.dart';
import '../settings/screens/budget_settings_detail_screen.dart';
import '../settings/screens/settings_screen.dart';
import '../settings/screens/shopee_settings_screen.dart';
import 'widgets/ambient_glow_background.dart';
import 'widgets/dashboard_action_bar.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/expense_list_item.dart';
import 'widgets/floating_capsule_navbar.dart';
import 'widgets/hero_balance_card.dart';
import 'widgets/weekly_budget_input_sheet.dart';
import 'widgets/weekly_rollover_banner.dart';

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
  BudgetPeriodView _selectedPeriod = BudgetPeriodView.daily;

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

  void _openPendingQuickLog() {
    if (widget.repository.pendingTransactions.isEmpty) {
      _openQuickLog();
      return;
    }
    final pending = widget.repository.pendingTransactions.first;
    final category = ExpenseCategory.fromId(pending.source) ?? ExpenseCategory.belanja;

    QuickLogDialog.show(
      context,
      repository: widget.repository,
      initialAmount: pending.amount,
      initialCategory: category,
      pendingTransactionId: pending.id,
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
              child: CircularProgressIndicator(color: PirschColors.primaryBlue),
            ),
          );
        }

        final budget = widget.repository.budget;
        final remaining = widget.repository.remainingBalance;
        final spent = widget.repository.totalSpent;
        final dailyAllowance = widget.repository.dailyAllowance;
        final remainingToday = widget.repository.remainingToday;
        final remainingWeekly = widget.repository.effectiveWeeklySpendable;
        final expenses = widget.repository.expenses;
        final displayedExpenses = _showAllTransactions ? expenses : expenses.take(5).toList();
        final isOverBudget = _selectedPeriod == BudgetPeriodView.daily
            ? (remaining < 0 || remainingToday < 0)
            : (remaining < 0 || remainingWeekly < 0);
        final isWarning = _selectedPeriod == BudgetPeriodView.daily
            ? (!isOverBudget && (remainingToday < 20000 || remaining < dailyAllowance))
            : (!isOverBudget && remainingWeekly < dailyAllowance);
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
                color: PirschColors.primaryBlue,
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

                          // Unconfirmed period rollover prompt banner
                          if (!widget.repository.isPeriodConfirmed)
                            WeeklyRolloverBanner(
                              carryoverBalance: widget.repository.carryoverBalance,
                              isDark: isDark,
                              onInputBudget: () => WeeklyBudgetInputSheet.show(context, widget.repository),
                            ),

                          // Hero Balance Card
                          HeroBalanceCard(
                            remaining: remaining,
                            spent: spent,
                            remainingToday: remainingToday,
                            remainingWeekly: remainingWeekly,
                            formattedPeriod: budget?.formattedPeriod ?? '',
                            isOverBudget: isOverBudget,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            periodView: _selectedPeriod,
                            onPeriodChanged: (view) {
                              setState(() {
                                _selectedPeriod = view;
                              });
                            },
                            onTapPeriod: _openBudgetDetail,
                            onTapMenu: _openSettings,
                          ),
                          const SizedBox(height: 14),

                          // 3-Action Quick Bar (Tabungan, Kategori, Catat)
                          DashboardActionBar(
                            weeklySavingsTarget: widget.repository.weeklySavingsTarget,
                            currentSaved: (widget.repository.weeklySavingsTarget -
                                    (widget.repository.totalSpent > widget.repository.spendableBudget
                                        ? (widget.repository.totalSpent - widget.repository.spendableBudget)
                                        : 0))
                                .clamp(0, widget.repository.weeklySavingsTarget),
                            pendingCount: widget.repository.pendingCount,
                            isDark: isDark,
                            cardColor: cardColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onTapSavings: _openBudgetDetail,
                            onTapCategory: () => _openCategoryAssignment(ExpenseCategory.all.first.id),
                            onTapQuickLog: widget.repository.pendingCount > 0
                                ? _openPendingQuickLog
                                : _openQuickLog,
                          ),
                          const SizedBox(height: 22),

                          // Recent Activity / Transaksi Terbaru Section Header (with See all)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Recent Activity',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (expenses.isNotEmpty)
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showAllTransactions = !_showAllTransactions;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Text(
                                      _showAllTransactions ? 'Show less' : 'See all',
                                      style: const TextStyle(
                                        color: PirschColors.primaryBlue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
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
                          ],

                          // Padding space for floating bottom bar with safe area
                          SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Gradient Fade (Scrim) to smoothly fade out scrolling items behind the floating navbar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 120 + MediaQuery.of(context).padding.bottom,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          bgColor.withValues(alpha: 0.0),
                          bgColor.withValues(alpha: 0.8),
                          bgColor,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Capsule Bottom Navigation Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 20 + MediaQuery.of(context).padding.bottom,
                child: Center(
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
              ),
            ],
          ),
        );
      },
    );
  }
}
