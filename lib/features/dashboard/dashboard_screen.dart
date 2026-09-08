import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../budget/dialogs/edit_budget_dialog.dart';
import '../budget/models/expense_model.dart';
import '../budget/repository/budget_repository.dart';
import '../quick_log/quick_log_dialog.dart';
import '../settings/shopee_settings_screen.dart';

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
        final totalBudget = budget?.totalBudget ?? 1500000;
        final spent = widget.repository.totalSpent;
        final pct = widget.repository.spendingPercentage;
        final dailyAllowance = widget.repository.dailyAllowance;
        final daysLeft = budget?.daysRemaining ?? 1;
        final expenses = widget.repository.expenses;
        final displayedExpenses = _showAllTransactions ? expenses : expenses.take(5).toList();
        final isOverBudget = remaining < 0;

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
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
                          child: _buildHeader(
                            context: context,
                            daysLeft: daysLeft,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            elevatedColor: elevatedColor,
                            borderColor: borderColor,
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

                          // Hero Balance Card (Refined Reference Layout)
                          _buildHeroBalanceCard(
                            context: context,
                            remaining: remaining,
                            totalBudget: totalBudget,
                            spent: spent,
                            pct: pct,
                            dailyAllowance: dailyAllowance,
                            daysLeft: daysLeft,
                            formattedPeriod: budget?.formattedPeriod ?? '',
                            isOverBudget: isOverBudget,
                            cardColor: cardColor,
                            elevatedColor: elevatedColor,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          const SizedBox(height: 12),

                          // Secondary Nudge & Action Card (Reference Pill Button Layout)
                          _buildNudgeBanner(
                            context: context,
                            dailyAllowance: dailyAllowance,
                            remaining: remaining,
                            isOverBudget: isOverBudget,
                            cardColor: cardColor,
                            elevatedColor: elevatedColor,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 24),

                          // Spending by Category (Horizontal Scroll)
                          _buildCategorySection(
                            expenses: expenses,
                            cardColor: cardColor,
                            elevatedColor: elevatedColor,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
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

                          // Transactions List (Capped to top 5 by default)
                          if (expenses.isEmpty)
                            _buildEmptyState(
                              elevatedColor: elevatedColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            )
                          else ...[
                            ...displayedExpenses.map((exp) => _buildExpenseItem(
                                  exp: exp,
                                  cardColor: cardColor,
                                  elevatedColor: elevatedColor,
                                  borderColor: borderColor,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
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
                child: _buildFloatingCapsuleNavbar(
                  context: context,
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required int daysLeft,
    required Color textPrimary,
    required Color textSecondary,
    required Color elevatedColor,
    required Color borderColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User Profile & Greeting (Expanded to prevent overflow)
        Expanded(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PirschColors.mintGreen.withValues(alpha: 0.15),
                  border: Border.all(color: PirschColors.mintGreen.withValues(alpha: 0.4), width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person_rounded, color: PirschColors.mintGreen, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Halo, Jajaner',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Mental Budget',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Live Status Pill & Quick Action Icons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Mint Dot Status Pill (Pirsch Live Indicator)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: PirschColors.mintGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PirschColors.mintGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: PirschColors.mintGreen,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Sisa $daysLeft hari',
                    style: const TextStyle(
                      color: PirschColors.mintGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Shopee Watcher Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ShopeeSettingsScreen(repository: widget.repository),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: elevatedColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.storefront_rounded, color: textPrimary, size: 18),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroBalanceCard({
    required BuildContext context,
    required int remaining,
    required int totalBudget,
    required int spent,
    required double pct,
    required int dailyAllowance,
    required int daysLeft,
    required String formattedPeriod,
    required bool isOverBudget,
    required Color cardColor,
    required Color elevatedColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Greeting & Period Dropdown (Left) + 3-Dots Menu (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Sobat',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    InkWell(
                      onTap: () => EditBudgetDialog.show(context, widget.repository),
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'batas jajan ',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'hari ini ⌄',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: textSecondary,
                            ),
                          ),
                          if (formattedPeriod.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '• $formattedPeriod',
                              style: TextStyle(
                                color: textSecondary.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 3-dots Menu Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => EditBudgetDialog.show(context, widget.repository),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Hero Nominal: Left-aligned
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  isOverBudget ? 'Rp 0' : CurrencyFormatter.format(dailyAllowance),
                  style: TextStyle(
                    color: isOverBudget ? PirschColors.roseRed : textPrimary,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '/ hari',
                  style: TextStyle(
                    color: isOverBudget ? PirschColors.roseRed.withValues(alpha: 0.7) : textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sub-metrics Row below Hero: ↙ Sisa Saldo & ↗ Terpakai (Side-by-Side)
          Row(
            children: [
              // Left: ↙ Sisa Saldo (Green)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.south_west_rounded,
                    size: 15,
                    color: PirschColors.mintGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    CurrencyFormatter.format(remaining),
                    style: TextStyle(
                      color: isOverBudget ? PirschColors.roseRed : PirschColors.mintGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),

              // Right: ↗ Terpakai (Red)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.north_east_rounded,
                    size: 15,
                    color: PirschColors.roseRed,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    CurrencyFormatter.format(spent),
                    style: const TextStyle(
                      color: PirschColors.roseRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNudgeBanner({
    required BuildContext context,
    required int dailyAllowance,
    required int remaining,
    required bool isOverBudget,
    required Color cardColor,
    required Color elevatedColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    final String message;
    if (isOverBudget) {
      message = 'Batas jajan habis, tahan jajan dulu!';
    } else if (dailyAllowance < 20000) {
      message = 'Jatah menipis, catat pengeluaran!';
    } else {
      message = 'Ada jajan yang belum dicatat?';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: isDark ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => QuickLogDialog.show(
                context,
                repository: widget.repository,
                onComplete: () => setState(() {}),
              ),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  'Catat sekarang',
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required List<ExpenseModel> expenses,
    required Color cardColor,
    required Color elevatedColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    // Group expense amounts by category keywords
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
      {'icon': Icons.restaurant_rounded, 'color': PirschColors.coralOrange, 'title': 'Makanan', 'total': foodTotal, 'preset': 'Makan'},
      {'icon': Icons.local_cafe_rounded, 'color': PirschColors.mintGreen, 'title': 'Kopi & Minum', 'total': coffeeTotal, 'preset': 'Kopi'},
      {'icon': Icons.directions_car_rounded, 'color': const Color(0xFF60A5FA), 'title': 'Transport', 'total': transportTotal, 'preset': 'Transport'},
      {'icon': Icons.shopping_bag_rounded, 'color': PirschColors.warmYellow, 'title': 'Belanja/QRIS', 'total': shoppingTotal, 'preset': 'Jajan'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            Text(
              'Sentuh untuk catat',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
                onTap: () {
                  QuickLogDialog.show(context, repository: widget.repository);
                },
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

  Widget _buildExpenseItem({
    required ExpenseModel exp,
    required Color cardColor,
    required Color elevatedColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
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
          widget.repository.deleteExpense(exp.id!);
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

  Widget _buildEmptyState({
    required Color elevatedColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
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

  Widget _buildFloatingCapsuleNavbar({
    required BuildContext context,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color textSecondary,
  }) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Nav 1: Home (Active)
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home_rounded, color: PirschColors.mintGreen, size: 26),
            onPressed: () {},
          ),

          // Nav 2: Shopee / Integrations
          IconButton(
            tooltip: 'Shopee & Scanner',
            icon: Icon(Icons.storefront_rounded, color: textSecondary, size: 24),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShopeeSettingsScreen(repository: widget.repository),
                ),
              );
            },
          ),

          // Nav Center: (+) Prominent Quick Log Button
          GestureDetector(
            onTap: () {
              QuickLogDialog.show(context, repository: widget.repository);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: PirschColors.mintGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 28),
            ),
          ),

          // Nav 4: History / Category
          IconButton(
            tooltip: 'Riwayat & Filter',
            icon: Icon(Icons.receipt_long_rounded, color: textSecondary, size: 24),
            onPressed: () {
              // Can open search or filter
            },
          ),

          // Nav 5: Settings / Edit Budget
          IconButton(
            tooltip: 'Pengaturan Budget',
            icon: Icon(Icons.tune_rounded, color: textSecondary, size: 24),
            onPressed: () {
              EditBudgetDialog.show(context, widget.repository);
            },
          ),
        ],
      ),
    );
  }
}
