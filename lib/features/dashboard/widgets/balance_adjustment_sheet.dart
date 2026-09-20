import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/ui_keys.dart';
import '../../../core/services/app_settings_controller.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budget/repository/budget_repository.dart';

/// Modal bottom sheet to Top Up balance or Adjust Real Balance (Koreksi Saldo).
class BalanceAdjustmentSheet extends StatefulWidget {
  final BudgetRepository repository;
  final String initialWalletType; // 'ewallet' | 'cash'

  const BalanceAdjustmentSheet({
    super.key,
    required this.repository,
    this.initialWalletType = 'ewallet',
  });

  static Future<void> show(
    BuildContext context,
    BudgetRepository repository, {
    String initialWalletType = 'ewallet',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BalanceAdjustmentSheet(
        repository: repository,
        initialWalletType: initialWalletType,
      ),
    );
  }

  @override
  State<BalanceAdjustmentSheet> createState() => _BalanceAdjustmentSheetState();
}

class _BalanceAdjustmentSheetState extends State<BalanceAdjustmentSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _selectedWallet; // 'ewallet' | 'cash'

  // Tab 1: Top Up controllers
  late TextEditingController _topUpAmountController;
  late TextEditingController _topUpNoteController;
  bool _topUpToSavings = false;

  // Tab 2: Koreksi Saldo controllers
  late TextEditingController _realBalanceController;
  final bool _reconcileToSavings = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedWallet = widget.initialWalletType;
    _tabController = TabController(length: 2, vsync: this);
    _topUpAmountController = TextEditingController();
    _topUpNoteController = TextEditingController(
      text: _selectedWallet == 'cash' ? 'Tambah Uang Tunai' : 'Top Up Saldo',
    );
    _realBalanceController = TextEditingController();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _errorMessage = null;
        });
      }
    });

    _topUpAmountController.addListener(() => setState(() {}));
    _realBalanceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topUpAmountController.dispose();
    _topUpNoteController.dispose();
    _realBalanceController.dispose();
    super.dispose();
  }

  Future<void> _submitTopUp() async {
    final amount = CurrencyFormatter.parse(_topUpAmountController.text);
    if (amount <= 0) {
      setState(() => _errorMessage = 'Masukkan nominal yang valid');
      return;
    }

    final defaultNote = _selectedWallet == 'cash' ? 'Tambah Uang Tunai' : 'Top Up Saldo';
    final note = _topUpNoteController.text.trim().isEmpty
        ? defaultNote
        : _topUpNoteController.text.trim();

    await widget.repository.addTopUp(
      amount,
      allocateToSavings: _topUpToSavings,
      note: note,
      walletType: _selectedWallet,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
    final walletLabel = _selectedWallet == 'cash' ? 'Tunai' : 'E-Wallet';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saldo $walletLabel +${CurrencyFormatter.format(amount)} berhasil dicatat!'),
        backgroundColor: PirschColors.incomeGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitAdjustment() async {
    final walletLabel = _selectedWallet == 'cash' ? 'Tunai' : 'E-Wallet';
    if (_realBalanceController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Masukkan saldo riil $walletLabel Anda');
      return;
    }

    final actualBalance = CurrencyFormatter.parse(_realBalanceController.text);
    final currentTargetBalance = _selectedWallet == 'cash'
        ? widget.repository.cashBalance
        : widget.repository.ewalletBalance;
    final diff = actualBalance - currentTargetBalance;

    if (diff == 0) {
      setState(() => _errorMessage = 'Saldo riil sama dengan saldo aplikasi (tidak ada selisih)');
      return;
    }

    await widget.repository.adjustRealBalance(
      actualBalance: actualBalance,
      allocateToSavings: _reconcileToSavings,
      walletType: _selectedWallet,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          diff > 0
              ? 'Saldo $walletLabel disesuaikan: +${CurrencyFormatter.format(diff)}'
              : 'Saldo $walletLabel disesuaikan: -${CurrencyFormatter.format(diff.abs())}',
        ),
        backgroundColor: diff > 0 ? PirschColors.incomeGreen : PirschColors.roseRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = PirschColors.card(isDark);
    final borderColor = PirschColors.border(isDark);
    final textPrimary = PirschColors.textPrimary(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);

    return Container(
      key: UIKeys.balanceSheet,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
          left: BorderSide(color: borderColor, width: 1),
          right: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Wallet Selector Pill Strip (E-Wallet vs Tunai) (Only when cashWalletEnabled)
            if (AppSettingsController.instance.cashWalletEnabled) ...[
              Center(
                child: Container(
                  key: UIKeys.balanceSheetWalletSelector,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildWalletChip(
                        key: UIKeys.balanceSheetWalletEwallet,
                        label: 'E-Wallet',
                        icon: Icons.account_balance_wallet_rounded,
                        isSelected: _selectedWallet == 'ewallet',
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          setState(() {
                            _selectedWallet = 'ewallet';
                            _topUpNoteController.text = 'Top Up Saldo';
                            _errorMessage = null;
                          });
                        },
                      ),
                      const SizedBox(width: 4),
                      _buildWalletChip(
                        key: UIKeys.balanceSheetWalletCash,
                        label: 'Uang Tunai',
                        icon: Icons.payments_rounded,
                        isSelected: _selectedWallet == 'cash',
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          setState(() {
                            _selectedWallet = 'cash';
                            _topUpNoteController.text = 'Tambah Uang Tunai';
                            _errorMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Tab Header (Top Up vs Koreksi Saldo)
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: TabBar(
                key: UIKeys.balanceSheetTabs,
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C30) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                labelColor: textPrimary,
                unselectedLabelColor: textSecondary,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Top Up Cepat'),
                  Tab(text: 'Koreksi Saldo'),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Error alert if any
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: PirschColors.roseRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PirschColors.roseRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: PirschColors.roseRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: PirschColors.roseRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Tab Views
            SizedBox(
              height: 330,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTopUpView(isDark, borderColor, textPrimary, textSecondary),
                  _buildAdjustmentView(isDark, borderColor, textPrimary, textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpView(
    bool isDark,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final amount = CurrencyFormatter.parse(_topUpAmountController.text);
    final daysRemaining = widget.repository.budget?.daysRemainingInWeek ?? 1;
    final dailyBoost = daysRemaining > 0 ? (amount / daysRemaining).round() : amount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tambah Uang / Top Up',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Catat top up masuk ke e-wallet tanpa mengganggu catatan pengeluaran.',
          style: TextStyle(fontSize: 12, color: textSecondary),
        ),
        const SizedBox(height: 16),

        // Nominal Input
        Text(
          'Nominal Top Up',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        ),
        const SizedBox(height: 6),
        TextField(
          key: UIKeys.balanceSheetTopUpInput,
          controller: _topUpAmountController,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
          decoration: InputDecoration(
            prefixText: 'Rp ',
            prefixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
            hintText: '0',
            hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: PirschColors.primaryBlue, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Checkbox: Alokasikan ke Tabungan
        InkWell(
          onTap: () {
            setState(() {
              _topUpToSavings = !_topUpToSavings;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _topUpToSavings,
                    onChanged: (val) => setState(() => _topUpToSavings = val ?? false),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    activeColor: PirschColors.incomeGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simpan langsung ke Tabungan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        _topUpToSavings
                            ? 'Saldo jajan tidak bertambah; target tabungan otomatis naik.'
                            : 'Saldo jajan bertambah (+${CurrencyFormatter.format(dailyBoost)}/hari).',
                        style: TextStyle(
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            key: UIKeys.balanceSheetSubmitTopUp,
            onPressed: _submitTopUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: PirschColors.incomeGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Simpan Top Up',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustmentView(
    bool isDark,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isCash = _selectedWallet == 'cash';
    final targetBalance = isCash ? widget.repository.cashBalance : widget.repository.ewalletBalance;
    final walletName = isCash ? 'Uang Tunai' : 'E-Wallet';
    final actualBalance = _realBalanceController.text.trim().isEmpty
        ? null
        : CurrencyFormatter.parse(_realBalanceController.text);
    final diff = actualBalance != null ? actualBalance - targetBalance : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Koreksi Saldo Riil $walletName',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Ketik saldo asli $walletName Anda saat ini. Aplikasi akan menghitung selisih dan menyesuaikannya.',
          style: TextStyle(fontSize: 12, color: textSecondary),
        ),
        const SizedBox(height: 14),

        // Current App Balance Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Saldo $walletName di Aplikasi:', style: TextStyle(fontSize: 12, color: textSecondary)),
            Text(
              CurrencyFormatter.format(targetBalance),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Real Wallet Balance Input
        Text(
          'Saldo Asli $walletName Saat Ini',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        ),
        const SizedBox(height: 6),
        TextField(
          key: UIKeys.balanceSheetRealBalanceInput,
          controller: _realBalanceController,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
          decoration: InputDecoration(
            prefixText: 'Rp ',
            prefixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
            hintText: CurrencyFormatter.formatNumber(targetBalance),
            hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.4)),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: PirschColors.primaryBlue, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Live Diff Preview Box
        if (diff != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (diff >= 0 ? PirschColors.incomeGreen : PirschColors.roseRed).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (diff >= 0 ? PirschColors.incomeGreen : PirschColors.roseRed).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  diff >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 16,
                  color: diff >= 0 ? PirschColors.incomeGreen : PirschColors.roseRed,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diff >= 0
                            ? 'Lebih banyak +${CurrencyFormatter.format(diff)}'
                            : 'Kurang -${CurrencyFormatter.format(diff.abs())}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: diff >= 0 ? PirschColors.incomeGreen : PirschColors.roseRed,
                        ),
                      ),
                      Text(
                        diff >= 0
                            ? 'Akan dicatat sebagai Top Up / Saldo Masuk'
                            : 'Akan dicatat sebagai Pengeluaran Terlupa',
                        style: TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const Spacer(),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            key: UIKeys.balanceSheetSubmitAdjustment,
            onPressed: _submitAdjustment,
            style: ElevatedButton.styleFrom(
              backgroundColor: PirschColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Sinkronkan Saldo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletChip({
    Key? key,
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2C2C30) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? PirschColors.primaryBlue : textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? textPrimary : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
