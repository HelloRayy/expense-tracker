import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/ui_keys.dart';
import '../../../core/services/app_settings_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budget/models/expense_model.dart';
import '../../budget/repository/budget_repository.dart';
import '../../categories/models/expense_category.dart';

enum RekapPeriod { mingguIni, bulanIni, semua }

/// Dedicated Rekap / Analytics Screen with floating capsule dock and
/// native horizontal PageView slide between periods.
class RekapScreen extends StatefulWidget {
  final BudgetRepository repository;

  const RekapScreen({super.key, required this.repository});

  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
  late final PageController _pageController;
  RekapPeriod _selectedPeriod = RekapPeriod.mingguIni;
  bool _isLoading = true;

  final Map<RekapPeriod, List<ExpenseModel>> _periodExpensesMap = {
    RekapPeriod.mingguIni: [],
    RekapPeriod.bulanIni: [],
    RekapPeriod.semua: [],
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPeriod.index);
    _loadAllPeriodData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPeriodData() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();

    // 1. Minggu Ini
    final budget = widget.repository.budget;
    final startWeek = budget?.startDate ??
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endWeek = budget?.endDate ??
        startWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    // 2. Bulan Ini
    final startMonth = DateTime(now.year, now.month, 1);
    final endMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final results = await Future.wait([
      widget.repository.getExpensesForPeriod(startWeek, endWeek),
      widget.repository.getExpensesForPeriod(startMonth, endMonth),
      widget.repository.getAllExpensesHistory(),
    ]);

    if (mounted) {
      setState(() {
        _periodExpensesMap[RekapPeriod.mingguIni] = results[0].where((e) => !e.isIncome).toList();
        _periodExpensesMap[RekapPeriod.bulanIni] = results[1].where((e) => !e.isIncome).toList();
        _periodExpensesMap[RekapPeriod.semua] = results[2].where((e) => !e.isIncome).toList();
        _isLoading = false;
      });
    }
  }

  void _onDockTabTapped(RekapPeriod period) {
    if (_selectedPeriod == period) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedPeriod = period);
    _pageController.animateToPage(
      period.index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  List<ExpenseModel> _getExpenses(RekapPeriod period) => _periodExpensesMap[period] ?? [];

  int _getTotalSpent(List<ExpenseModel> expenses) =>
      expenses.fold<int>(0, (sum, e) => sum + e.amount);

  int _getDailyAverage(RekapPeriod period, List<ExpenseModel> expenses) {
    if (expenses.isEmpty) return 0;
    final total = _getTotalSpent(expenses);
    final now = DateTime.now();
    int days;
    switch (period) {
      case RekapPeriod.mingguIni:
        days = now.weekday;
        break;
      case RekapPeriod.bulanIni:
        days = now.day;
        break;
      case RekapPeriod.semua:
        final earliest = expenses
            .map((e) => e.createdAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        days = now.difference(earliest).inDays + 1;
        break;
    }
    return days > 0 ? (total / days).round() : total;
  }

  String _getPeriodLabel(RekapPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case RekapPeriod.mingguIni:
        final budget = widget.repository.budget;
        if (budget != null) return budget.formattedPeriod;
        final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        return '${monday.day} - ${DateFormat('d MMM yyyy', 'id_ID').format(sunday)}';
      case RekapPeriod.bulanIni:
        try {
          return DateFormat('MMMM yyyy', 'id_ID').format(now);
        } catch (_) {
          return '${now.month}/${now.year}';
        }
      case RekapPeriod.semua:
        return 'Seluruh Riwayat Transaksi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = PirschColors.bg(isDark);
    final cardColor = PirschColors.card(isDark);
    final borderColor = PirschColors.border(isDark);
    final textPrimary = PirschColors.textPrimary(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);

    return Scaffold(
      key: UIKeys.rekapScreen,
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Rekap Pengeluaran',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textSecondary, size: 22),
            onPressed: _loadAllPeriodData,
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Body: Period Subtitle + Native Horizontal Swipe PageView
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _getPeriodLabel(_selectedPeriod),
                      key: ValueKey(_selectedPeriod),
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Horizontal Swipe PageView
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PageView(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedPeriod = RekapPeriod.values[index];
                          });
                        },
                        children: [
                          _buildPeriodPage(
                            RekapPeriod.mingguIni,
                            cardColor,
                            borderColor,
                            textPrimary,
                            textSecondary,
                            isDark,
                          ),
                          _buildPeriodPage(
                            RekapPeriod.bulanIni,
                            cardColor,
                            borderColor,
                            textPrimary,
                            textSecondary,
                            isDark,
                          ),
                          _buildPeriodPage(
                            RekapPeriod.semua,
                            cardColor,
                            borderColor,
                            textPrimary,
                            textSecondary,
                            isDark,
                          ),
                        ],
                      ),
              ),
            ],
          ),

          // Bottom Gradient Fade (Scrim) to smoothly fade out scrolling items behind the floating dock
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 110 + MediaQuery.of(context).padding.bottom,
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

          // Floating Capsule Dock (matching homepage dock style)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20 + MediaQuery.of(context).padding.bottom,
            child: Center(
              child: _buildFloatingDock(isDark, borderColor, textPrimary, textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDock(
    bool isDark,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      key: UIKeys.rekapPeriodTabBar,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDockItem(RekapPeriod.mingguIni, 'Minggu Ini', isDark, textPrimary, textSecondary),
          const SizedBox(width: 4),
          _buildDockItem(RekapPeriod.bulanIni, 'Bulan Ini', isDark, textPrimary, textSecondary),
          const SizedBox(width: 4),
          _buildDockItem(RekapPeriod.semua, 'Semua', isDark, textPrimary, textSecondary),
        ],
      ),
    );
  }

  Widget _buildDockItem(
    RekapPeriod period,
    String label,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onDockTabTapped(period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : const Color(0xFF0C0C0C))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? const Color(0xFF0C0C0C) : Colors.white)
                : textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodPage(
    RekapPeriod period,
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final expenses = _getExpenses(period);
    if (expenses.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAllPeriodData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: _buildEmptyState(textPrimary, textSecondary),
            ),
          ],
        ),
      );
    }

    final totalSpent = _getTotalSpent(expenses);
    final dailyAverage = _getDailyAverage(period, expenses);

    return RefreshIndicator(
      onRefresh: _loadAllPeriodData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          96 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          // 1. Total Summary Card
          _buildSummaryCard(
            expenses,
            totalSpent,
            dailyAverage,
            cardColor,
            borderColor,
            textPrimary,
            textSecondary,
            isDark,
          ),
          const SizedBox(height: 16),

          // 2. Category Breakdown Card
          _buildCategoryCard(
            expenses,
            totalSpent,
            cardColor,
            borderColor,
            textPrimary,
            textSecondary,
            isDark,
          ),
          const SizedBox(height: 16),

          // 3. Wallet Breakdown Card (E-Wallet vs Cash) - only if cash wallet enabled in Settings
          if (AppSettingsController.instance.cashWalletEnabled) ...[
            _buildWalletBreakdownCard(
              expenses,
              totalSpent,
              cardColor,
              borderColor,
              textPrimary,
              textSecondary,
              isDark,
            ),
            const SizedBox(height: 16),
          ],

          // 4. Top Expenses Card
          _buildTopExpensesCard(
            expenses,
            cardColor,
            borderColor,
            textPrimary,
            textSecondary,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    List<ExpenseModel> expenses,
    int totalSpent,
    int dailyAverage,
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      key: UIKeys.rekapSummaryCard,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL PENGELUARAN',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PirschColors.roseRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${expenses.length} Transaksi',
                  style: const TextStyle(
                    color: PirschColors.roseRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(totalSpent),
            style: TextStyle(
              color: textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rata-rata / Hari', style: TextStyle(color: textSecondary, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(dailyAverage),
                      style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: borderColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Budget Mingguan', style: TextStyle(color: textSecondary, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(widget.repository.spendableBudget),
                      style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    List<ExpenseModel> expenses,
    int totalSpent,
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    // Group expenses by category
    final categoryTotals = <String, int>{};
    final categoryCounts = <String, int>{};

    for (final exp in expenses) {
      final cat = ExpenseCategory.fromId(exp.categoryId) ?? ExpenseCategory.lainnya;
      categoryTotals[cat.displayName] = (categoryTotals[cat.displayName] ?? 0) + exp.amount;
      categoryCounts[cat.displayName] = (categoryCounts[cat.displayName] ?? 0) + 1;
    }

    // Sort categories by highest spent
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      key: UIKeys.rekapCategoryBreakdown,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Pengeluaran',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),

          // Multi-Segmented Proportional Bar
          if (totalSpent > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: sortedEntries.map((entry) {
                    final cat = ExpenseCategory.fromId(entry.key) ?? ExpenseCategory.lainnya;
                    final flex = ((entry.value / totalSpent) * 1000).round();
                    return Expanded(
                      flex: flex > 0 ? flex : 1,
                      child: Container(color: cat.color),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Category rows
          ...sortedEntries.map((entry) {
            final cat = ExpenseCategory.fromId(entry.key) ?? ExpenseCategory.lainnya;
            final percentage = totalSpent > 0 ? ((entry.value / totalSpent) * 100).toStringAsFixed(1) : '0';
            final count = categoryCounts[entry.key] ?? 1;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$count transaksi • $percentage%',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(entry.value),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWalletBreakdownCard(
    List<ExpenseModel> expenses,
    int totalSpent,
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    int ewalletTotal = 0;
    int cashTotal = 0;

    for (final exp in expenses) {
      if (exp.walletType == 'cash') {
        cashTotal += exp.amount;
      } else {
        ewalletTotal += exp.amount;
      }
    }

    final ewalletPercent = totalSpent > 0 ? ((ewalletTotal / totalSpent) * 100).toStringAsFixed(0) : '0';
    final cashPercent = totalSpent > 0 ? ((cashTotal / totalSpent) * 100).toStringAsFixed(0) : '0';

    return Container(
      key: UIKeys.rekapWalletBreakdown,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Sumber Dompet',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // E-Wallet Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF4F4F6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.account_balance_wallet_rounded, color: PirschColors.primaryBlue, size: 20),
                          Text('$ewalletPercent%', style: const TextStyle(color: PirschColors.primaryBlue, fontWeight: FontWeight.w700, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('E-Wallet', style: TextStyle(color: textSecondary, fontSize: 11)),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.format(ewalletTotal),
                          style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Cash Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF4F4F6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.payments_rounded, color: PirschColors.mintGreen, size: 20),
                          Text('$cashPercent%', style: const TextStyle(color: PirschColors.mintGreen, fontWeight: FontWeight.w700, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Uang Tunai', style: TextStyle(color: textSecondary, fontSize: 11)),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.format(cashTotal),
                          style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopExpensesCard(
    List<ExpenseModel> expenses,
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final sortedByAmount = List<ExpenseModel>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final top5 = sortedByAmount.take(5).toList();

    return Container(
      key: UIKeys.rekapTopExpensesList,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengeluaran Terbesar',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Top ${top5.length}',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...top5.asMap().entries.map((entry) {
            final index = entry.key;
            final exp = entry.value;
            final cat = ExpenseCategory.fromId(exp.categoryId) ?? ExpenseCategory.lainnya;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? PirschColors.coralOrange.withValues(alpha: 0.2)
                          : (isDark ? Colors.white10 : Colors.black12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: index == 0 ? PirschColors.coralOrange : textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp.note,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${cat.displayName} • ${exp.formattedTime}',
                          style: TextStyle(color: textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(exp.amount),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textPrimary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 56, color: textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'Belum Ada Pengeluaran',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Catatan pengeluaran pada periode ini akan muncul di sini.',
            style: TextStyle(color: textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
