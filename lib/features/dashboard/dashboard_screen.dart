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
    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        if (widget.repository.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final budget = widget.repository.budget;
        final remaining = widget.repository.remainingBalance;
        final totalBudget = budget?.totalBudget ?? 1;
        final spent = widget.repository.totalSpent;
        final pct = widget.repository.spendingPercentage;
        final dailyAllowance = widget.repository.dailyAllowance;
        final daysLeft = budget?.daysRemaining ?? 1;
        final expenses = widget.repository.expenses;

        final isOverBudget = remaining < 0;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Uang Jajan',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  budget?.formattedPeriod ?? '',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              // Shopee Reminder Shortcut
              IconButton(
                tooltip: 'Pengingat ShopeePay',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('🛍️', style: TextStyle(fontSize: 16)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ShopeeSettingsScreen(
                        repository: widget.repository,
                      ),
                    ),
                  );
                },
              ),
              // Edit Budget Button
              IconButton(
                tooltip: 'Atur Budget',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  EditBudgetDialog.show(context, widget.repository);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: widget.repository.loadData,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              children: [
                // Hero Balance Card
                _buildHeroCard(
                  remaining: remaining,
                  totalBudget: totalBudget,
                  spent: spent,
                  pct: pct,
                  dailyAllowance: dailyAllowance,
                  daysLeft: daysLeft,
                  isOverBudget: isOverBudget,
                ),
                const SizedBox(height: 18),

                // Fast Action Quick-Log Button
                InkWell(
                  onTap: () {
                    QuickLogDialog.show(context, repository: widget.repository);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Catat Jajan Sekarang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // History Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Riwayat Jajan Periode Ini',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${expenses.length} pengeluaran',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Expense List or Empty State
                if (expenses.isEmpty)
                  _buildEmptyState()
                else
                  ...expenses.map((exp) => _buildExpenseItem(exp)),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard({
    required int remaining,
    required int totalBudget,
    required int spent,
    required double pct,
    required int dailyAllowance,
    required int daysLeft,
    required bool isOverBudget,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOverBudget
              ? AppColors.danger.withValues(alpha: 0.5)
              : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOverBudget ? '⚠️ Saldo Jajan Habis / Minus' : 'Sisa Saldo Jajan',
                style: TextStyle(
                  color: isOverBudget ? AppColors.danger : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Sisa $daysLeft hari',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(remaining),
            style: TextStyle(
              color: isOverBudget ? AppColors.danger : AppColors.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget
                    ? AppColors.danger
                    : pct > 0.8
                        ? AppColors.warning
                        : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Total spent vs budget
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terpakai: ${CurrencyFormatter.format(spent)} (${(pct * 100).toInt()}%)',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              Text(
                'Budget: ${CurrencyFormatter.formatCompact(totalBudget)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Daily Safe Allowance Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isOverBudget
                        ? 'Stop jajan dulu sampai gajian berikutnya!'
                        : 'Aman jajan ${CurrencyFormatter.format(dailyAllowance)} / hari',
                    style: TextStyle(
                      color: isOverBudget ? AppColors.danger : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(ExpenseModel exp) {
    return Dismissible(
      key: Key(exp.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (dir) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Hapus Catatan?', style: TextStyle(color: AppColors.textPrimary)),
            content: Text(
              'Yakin ingin menghapus catatan jajan ${CurrencyFormatter.format(exp.amount)} (${exp.note})?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: const Text('💸', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.note,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exp.formattedTime,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '- ${CurrencyFormatter.format(exp.amount)}',
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.savings_outlined, color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum ada catatan jajan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Saldo jajanmu masih utuh. Tap tombol di atas buat quick-log pas jajan!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
