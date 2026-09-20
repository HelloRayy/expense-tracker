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

/// Dedicated Rekap / Analytics Screen for visualizing expenses from SQLite.
class RekapScreen extends StatefulWidget {
  final BudgetRepository repository;

  const RekapScreen({super.key, required this.repository});

  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
  RekapPeriod _selectedPeriod = RekapPeriod.mingguIni;
  bool _isLoading = true;
  List<ExpenseModel> _periodExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadPeriodData();
  }

  Future<void> _loadPeriodData() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    List<ExpenseModel> expenses;

    switch (_selectedPeriod) {
      case RekapPeriod.mingguIni:
        final budget = widget.repository.budget;
        final start = budget?.startDate ??
            DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        final end = budget?.endDate ??
            start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        expenses = await widget.repository.getExpensesForPeriod(start, end);
        break;

      case RekapPeriod.bulanIni:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        expenses = await widget.repository.getExpensesForPeriod(start, end);
        break;

      case RekapPeriod.semua:
        expenses = await widget.repository.getAllExpensesHistory();
        break;
    }

    // Filter out income records, focus on actual expenses
    final actualExpenses = expenses.where((e) => !e.isIncome).toList();

    if (mounted) {
      setState(() {
        _periodExpenses = actualExpenses;
        _isLoading = false;
      });
    }
  }

  void _onPeriodChanged(RekapPeriod period) {
    if (_selectedPeriod == period) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedPeriod = period);
    _loadPeriodData();
  }

  int get _totalSpent => _periodExpenses.fold<int>(0, (sum, e) => sum + e.amount);

  int get _dailyAverage {
    if (_periodExpenses.isEmpty) return 0;
    final now = DateTime.now();
    int days;
    switch (_selectedPeriod) {
      case RekapPeriod.mingguIni:
        days = now.weekday; // Number of days elapsed in current week
        break;
      case RekapPeriod.bulanIni:
        days = now.day; // Number of days elapsed in current month
        break;
      case RekapPeriod.semua:
        if (_periodExpenses.isEmpty) return 0;
        final earliest = _periodExpenses
            .map((e) => e.createdAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        days = now.difference(earliest).inDays + 1;
        break;
    }
    return days > 0 ? (_totalSpent / days).round() : _totalSpent;
  }

  String get _periodLabel {
    final now = DateTime.now();
    switch (_selectedPeriod) {
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
            onPressed: _loadPeriodData,
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: Column(
        children: [
          // Period Tab Selector (Minggu Ini, Bulan Ini, Semua)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              key: UIKeys.rekapPeriodTabBar,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B1B1E) : const Color(0xFFEEEEF0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  _buildPeriodTab(RekapPeriod.mingguIni, 'Minggu Ini', isDark, textPrimary, textSecondary),
                  _buildPeriodTab(RekapPeriod.bulanIni, 'Bulan Ini', isDark, textPrimary, textSecondary),
                  _buildPeriodTab(RekapPeriod.semua, 'Semua', isDark, textPrimary, textSecondary),
                ],
              ),
            ),
          ),

          // Period Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _periodLabel,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _periodExpenses.isEmpty
                    ? _buildEmptyState(textPrimary, textSecondary)
                    : RefreshIndicator(
                        onRefresh: _loadPeriodData,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                          children: [
                            // 1. Total Summary Card
                            _buildSummaryCard(cardColor, borderColor, textPrimary, textSecondary, isDark),
                            const SizedBox(height: 16),

                            // 2. Category Breakdown Card
                            _buildCategoryCard(cardColor, borderColor, textPrimary, textSecondary, isDark),
                            const SizedBox(height: 16),

                            // 3. Wallet Breakdown Card (E-Wallet vs Cash) - only if cash wallet enabled in Settings
                            if (AppSettingsController.instance.cashWalletEnabled) ...[
                              _buildWalletBreakdownCard(cardColor, borderColor, textPrimary, textSecondary, isDark),
                              const SizedBox(height: 16),
                            ],

                            // 4. Top Expenses Card
                            _buildTopExpensesCard(cardColor, borderColor, textPrimary, textSecondary, isDark),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(
    RekapPeriod period,
    String label,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onPeriodChanged(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF2C2C32) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? textPrimary : textSecondary,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
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
                  '${_periodExpenses.length} Transaksi',
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
            CurrencyFormatter.format(_totalSpent),
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
                      CurrencyFormatter.format(_dailyAverage),
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
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    // Group expenses by category
    final categoryTotals = <String, int>{};
    final categoryCounts = <String, int>{};

    for (final exp in _periodExpenses) {
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
          if (_totalSpent > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: sortedEntries.map((entry) {
                    final cat = ExpenseCategory.fromId(entry.key) ?? ExpenseCategory.lainnya;
                    final flex = ((entry.value / _totalSpent) * 1000).round();
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
            final percentage = _totalSpent > 0 ? ((entry.value / _totalSpent) * 100).toStringAsFixed(1) : '0';
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
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    int ewalletTotal = 0;
    int cashTotal = 0;

    for (final exp in _periodExpenses) {
      if (exp.walletType == 'cash') {
        cashTotal += exp.amount;
      } else {
        ewalletTotal += exp.amount;
      }
    }

    final ewalletPercent = _totalSpent > 0 ? ((ewalletTotal / _totalSpent) * 100).toStringAsFixed(0) : '0';
    final cashPercent = _totalSpent > 0 ? ((cashTotal / _totalSpent) * 100).toStringAsFixed(0) : '0';

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
                          const Text('', style: TextStyle(color: PirschColors.mintGreen, fontWeight: FontWeight.w700, fontSize: 12)),
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
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final sortedByAmount = List<ExpenseModel>.from(_periodExpenses)
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
