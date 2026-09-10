import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budget/repository/budget_repository.dart';
import '../widgets/budget_reset_card.dart';
import '../widgets/budget_summary_card.dart';

/// Detail screen for configuring weekly budget income and savings target.
class BudgetSettingsDetailScreen extends StatefulWidget {
  final BudgetRepository repository;

  const BudgetSettingsDetailScreen({super.key, required this.repository});

  @override
  State<BudgetSettingsDetailScreen> createState() => _BudgetSettingsDetailScreenState();
}

class _BudgetSettingsDetailScreenState extends State<BudgetSettingsDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _incomeController;
  late TextEditingController _savingsController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    final current = widget.repository.budget;
    final income = current?.weeklyIncome ?? 0;
    final savings = current?.weeklySavingsTarget ?? 0;

    _incomeController = TextEditingController(
      text: income > 0 ? CurrencyFormatter.formatNumber(income) : '',
    );
    _savingsController = TextEditingController(
      text: savings > 0 ? CurrencyFormatter.formatNumber(savings) : '',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _incomeController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  void _save() {
    final income = CurrencyFormatter.parse(_incomeController.text);
    final savings = CurrencyFormatter.parse(_savingsController.text);

    if (income < 0) {
      setState(() => _errorMessage = 'Uang mingguan tidak boleh negatif');
      return;
    }

    if (income > 0 && savings >= income) {
      setState(() => _errorMessage = 'Target tabungan harus lebih kecil dari uang mingguan');
      return;
    }

    widget.repository.updateBudget(
      weeklyIncome: income,
      weeklySavingsTarget: savings,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budget mingguan berhasil disimpan!'),
        backgroundColor: PirschColors.mintGreen,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PirschColors.card(Theme.of(context).brightness == Brightness.dark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Reset Budget ke Rp 0?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: const Text(
          'Semua nominal uang mingguan dan target tabungan akan diatur kembali ke Rp 0.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _incomeController.text = '';
                _savingsController.text = '';
                _errorMessage = null;
              });
              widget.repository.updateBudget(weeklyIncome: 0, weeklySavingsTarget: 0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget direset ke Rp 0')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PirschColors.roseRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = PirschColors.bg(isDark);
    final elevatedColor = PirschColors.cardElevated(isDark);
    final borderColor = PirschColors.border(isDark);
    final textPrimary = PirschColors.textPrimary(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);

    final income = CurrencyFormatter.parse(_incomeController.text);
    final savings = CurrencyFormatter.parse(_savingsController.text);
    final spendable = (income - savings).clamp(0, income);
    final dailyEst = (spendable / 7).round();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: textPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Large Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Atur Budget',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // Segmented Underline Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: PirschColors.divider(isDark),
                    width: 0.8,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: textPrimary,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: textPrimary,
                unselectedLabelColor: textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Uang Mingguan'),
                  Tab(text: 'Target Tabungan'),
                ],
              ),
            ),

            // Tab View Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Uang Mingguan
                  _buildTabContent(
                    label: 'Total Uang Mingguan yang Dipegang',
                    controller: _incomeController,
                    placeholder: '0',
                    prefixColor: PirschColors.green(isDark),
                    helpText: 'Masukkan total seluruh uang atau pemasukan yang Anda pegang untuk siklus minggu ini.',
                    spendable: spendable,
                    dailyEst: dailyEst,
                    savings: savings,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    elevatedColor: elevatedColor,
                    borderColor: borderColor,
                  ),

                  // Tab 2: Target Tabungan
                  _buildTabContent(
                    label: 'Target Tabungan di Akhir Minggu',
                    controller: _savingsController,
                    placeholder: '0',
                    prefixColor: PirschColors.yellow(isDark),
                    helpText: 'Nominal yang wajib tersisa di akhir minggu. Rumus adaptive akan otomatis menjaga agar target ini tidak tersentuh!',
                    spendable: spendable,
                    dailyEst: dailyEst,
                    savings: savings,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    elevatedColor: elevatedColor,
                    borderColor: borderColor,
                  ),
                ],
              ),
            ),

            // Sticky Bottom Pill Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PirschColors.pill(isDark),
                    foregroundColor: PirschColors.pillText(isDark),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Simpan',
                    style: TextStyle(
                      color: PirschColors.pillText(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
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

  Widget _buildTabContent({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    required Color prefixColor,
    required String helpText,
    required int spendable,
    required int dailyEst,
    required int savings,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color elevatedColor,
    required Color borderColor,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),

          // Direct Input Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  'Rp ',
                  style: TextStyle(
                    color: prefixColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      ThousandsSeparatorInputFormatter(),
                    ],
                    onChanged: (_) => setState(() => _errorMessage = null),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: TextStyle(
                        color: textSecondary.withValues(alpha: 0.4),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear_rounded, size: 20, color: textSecondary),
                    splashRadius: 20,
                    onPressed: () => setState(() => controller.clear()),
                  ),
              ],
            ),
          ),

          // Underline Divider
          Divider(
            height: 1,
            thickness: 0.8,
            color: PirschColors.divider(isDark),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: PirschColors.roseRed,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 12),
          Text(
            helpText,
            style: TextStyle(
              color: textSecondary.withValues(alpha: 0.8),
              fontSize: 12,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),
          // Live Calculation Card
          BudgetSummaryCard(
            spendable: spendable,
            dailyEst: dailyEst,
            savings: savings,
            isDark: isDark,
            elevatedColor: elevatedColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),

          const SizedBox(height: 32),

          // Danger Action Card
          BudgetResetCard(
            isDark: isDark,
            textSecondary: textSecondary,
            onReset: _resetToDefault,
          ),
        ],
      ),
    );
  }
}
