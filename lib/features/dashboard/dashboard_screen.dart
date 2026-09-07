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

                          // Hero Balance Card (Pirsch 24px Radius)
                          _buildHeroBalanceCard(
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
                          const SizedBox(height: 16),

                          // Pirsch Nudge Banner
                          _buildNudgeBanner(
                            dailyAllowance: dailyAllowance,
                            isOverBudget: isOverBudget,
                            elevatedColor: elevatedColor,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
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
                              Text(
                                'Transaksi Terbaru',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
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
                                  '${expenses.length} Transaksi',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Transactions List
                          if (expenses.isEmpty)
                            _buildEmptyState(
                              elevatedColor: elevatedColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            )
                          else
                            ...expenses.map((exp) => _buildExpenseItem(
                                  exp: exp,
                                  cardColor: cardColor,
                                  elevatedColor: elevatedColor,
                                  borderColor: borderColor,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                )),

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOverBudget ? PirschColors.roseRed.withValues(alpha: 0.6) : borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Period Badge
          if (formattedPeriod.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: elevatedColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  formattedPeriod,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Main Hero Nominal
          Text(
            CurrencyFormatter.format(remaining),
            style: TextStyle(
              color: isOverBudget ? PirschColors.roseRed : textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),

          // Pirsch Minimal Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: elevatedColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget
                    ? PirschColors.roseRed
                    : pct > 0.8
                        ? PirschColors.warmYellow
                        : PirschColors.mintGreen,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3-Column Mini Metrics Strip (Pirsch Key Stats Layout)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: elevatedColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Col 1: Total Alokasi
                _buildStatColumn(
                  label: 'Alokasi',
                  value: CurrencyFormatter.formatCompact(totalBudget),
                  valueColor: textPrimary,
                  textSecondary: textSecondary,
                ),
                Container(width: 1, height: 28, color: borderColor),

                // Col 2: Terpakai
                _buildStatColumn(
                  label: 'Terpakai',
                  value: CurrencyFormatter.formatCompact(spent),
                  valueColor: isOverBudget ? PirschColors.roseRed : textSecondary,
                  textSecondary: textSecondary,
                ),
                Container(width: 1, height: 28, color: borderColor),

                // Col 3: Batas Aman Harian (Highlighted Mint)
                _buildStatColumn(
                  label: 'Batas Aman',
                  value: isOverBudget ? 'Rp 0 / hr' : '${CurrencyFormatter.formatCompact(dailyAllowance)} / hr',
                  valueColor: isOverBudget ? PirschColors.roseRed : PirschColors.mintGreen,
                  textSecondary: textSecondary,
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required Color valueColor,
    required Color textSecondary,
    bool isBold = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNudgeBanner({
    required int dailyAllowance,
    required bool isOverBudget,
    required Color elevatedColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final String title;
    final String description;
    final Color accentColor;
    final IconData iconData;

    if (isOverBudget) {
      iconData = Icons.warning_amber_rounded;
      accentColor = PirschColors.roseRed;
      title = 'Jatah jajan periode ini telah habis!';
      description = 'Tahan jajan dulu hingga tanggal gajian untuk menjaga uang pokok tetap aman.';
    } else if (dailyAllowance < 20000) {
      iconData = Icons.bolt_rounded;
      accentColor = PirschColors.warmYellow;
      title = 'Jatah jajan harian menipis';
      description = 'Batas aman tersisa ${CurrencyFormatter.format(dailyAllowance)}/hari. Prioritaskan kebutuhan penting.';
    } else {
      iconData = Icons.auto_awesome_rounded;
      accentColor = PirschColors.mintGreen;
      title = 'Pengeluaran Jajanmu Aman';
      description = 'Batas jajan aman ${CurrencyFormatter.format(dailyAllowance)}/hari. Tetap konsisten untuk bonus akhir periode.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: accentColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
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
            Text(
              'Kategori Pengeluaran',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
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
              decoration: BoxDecoration(
                color: PirschColors.mintGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PirschColors.mintGreen.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
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
