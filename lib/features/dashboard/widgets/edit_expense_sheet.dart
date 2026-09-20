import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../budget/models/expense_model.dart';
import '../../budget/repository/budget_repository.dart';
import '../../categories/models/expense_category.dart';

class EditExpenseSheet extends StatefulWidget {
  final ExpenseModel expense;
  final BudgetRepository repository;

  const EditExpenseSheet({
    super.key,
    required this.expense,
    required this.repository,
  });

  static Future<void> show(
    BuildContext context, {
    required ExpenseModel expense,
    required BudgetRepository repository,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF141417) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => EditExpenseSheet(
        expense: expense,
        repository: repository,
      ),
    );
  }

  @override
  State<EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _EditExpenseSheetState extends State<EditExpenseSheet> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String? _selectedCategoryId;
  late String _selectedWallet;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense.amount > 0 ? widget.expense.amount.toString() : '',
    );
    _noteController = TextEditingController(text: widget.expense.note);
    _selectedCategoryId = widget.expense.categoryId;
    _selectedWallet = widget.expense.walletType;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int get _parsedAmount {
    final clean = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  Future<void> _handleSave() async {
    final amount = _parsedAmount;
    if (amount <= 0) return;

    setState(() => _isSaving = true);
    try {
      final updated = widget.expense.copyWith(
        amount: amount,
        note: _noteController.text.trim().isEmpty
            ? (widget.expense.isIncome ? 'Top Up Saldo' : 'Jajan')
            : _noteController.text.trim(),
        categoryId: _selectedCategoryId,
        clearCategory: _selectedCategoryId == null,
        walletType: _selectedWallet,
      );

      await widget.repository.updateExpense(updated);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: Text(
          'Yakin ingin menghapus ${CurrencyFormatter.format(widget.expense.amount)} (${widget.expense.note})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: PirschColors.roseRed,
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.expense.id != null) {
      await widget.repository.deleteExpense(widget.expense.id!);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF09090B);
    final textSecondary = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final isIncome = widget.expense.isIncome;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle drag bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isIncome ? 'Edit Top Up Saldo' : 'Edit Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              IconButton(
                onPressed: _handleDelete,
                icon: const Icon(Icons.delete_outline, color: PirschColors.roseRed),
                tooltip: 'Hapus',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nominal Input Field
          Text(
            'Nominal',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isIncome ? PirschColors.incomeGreen : textPrimary,
            ),
            decoration: InputDecoration(
              prefixText: isIncome ? '+Rp ' : 'Rp ',
              prefixStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isIncome ? PirschColors.incomeGreen : textSecondary,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF4F4F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Catatan Input Field
          Text(
            'Catatan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _noteController,
            style: TextStyle(color: textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: isIncome ? 'Top Up Saldo' : 'Misal: Nasi Padang',
              hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6)),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF4F4F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Metode Pembayaran / Dompet Selector
          Text(
            'Sumber Dompet',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildWalletChoice(
                  label: 'E-Wallet',
                  icon: Icons.account_balance_wallet_rounded,
                  isSelected: _selectedWallet == 'ewallet',
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => setState(() => _selectedWallet = 'ewallet'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildWalletChoice(
                  label: 'Uang Tunai',
                  icon: Icons.payments_rounded,
                  isSelected: _selectedWallet == 'cash',
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => setState(() => _selectedWallet = 'cash'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Kategori (hanya jika bukan income)
          if (!isIncome) ...[
            Text(
              'Kategori',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategory.all.map((cat) {
                final isSelected = _selectedCategoryId == cat.id;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, size: 16, color: isSelected ? Colors.white : textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        cat.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : textPrimary,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: cat.color,
                  backgroundColor: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF4F4F5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = selected ? cat.id : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 12),
          ],

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: isIncome ? PirschColors.incomeGreen : (isDark ? Colors.white : Colors.black),
                foregroundColor: isIncome ? Colors.white : (isDark ? Colors.black : Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Simpan Perubahan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletChoice({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08))
              : (isDark ? const Color(0xFF1E1E22) : const Color(0xFFF4F4F5)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? PirschColors.primaryBlue
                : (isDark ? Colors.white10 : Colors.black12),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? PirschColors.primaryBlue : textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
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
