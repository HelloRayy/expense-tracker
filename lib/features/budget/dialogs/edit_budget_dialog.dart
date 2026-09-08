import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../repository/budget_repository.dart';

class EditBudgetDialog extends StatefulWidget {
  final BudgetRepository repository;

  const EditBudgetDialog({super.key, required this.repository});

  static Future<void> show(BuildContext context, BudgetRepository repo) {
    return showDialog(
      context: context,
      builder: (ctx) => EditBudgetDialog(repository: repo),
    );
  }

  @override
  State<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  late TextEditingController _incomeController;
  late TextEditingController _savingsController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final current = widget.repository.budget;
    _incomeController = TextEditingController(
      text: (current?.weeklyIncome ?? 100000).toString(),
    );
    _savingsController = TextEditingController(
      text: (current?.weeklySavingsTarget ?? 30000).toString(),
    );
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  void _save() {
    final income = CurrencyFormatter.parse(_incomeController.text);
    final savings = CurrencyFormatter.parse(_savingsController.text);

    if (income <= 0) {
      setState(() => _errorMessage = 'Uang mingguan harus lebih dari Rp 0');
      return;
    }

    if (savings >= income) {
      setState(() => _errorMessage = 'Target tabungan harus lebih kecil dari uang mingguan');
      return;
    }

    widget.repository.updateBudget(
      weeklyIncome: income,
      weeklySavingsTarget: savings,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final income = CurrencyFormatter.parse(_incomeController.text);
    final savings = CurrencyFormatter.parse(_savingsController.text);
    final spendable = (income - savings).clamp(0, income);
    final dailyEst = (spendable / 7).round();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Atur Budget Minggu Ini',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Uang Mingguan (Total yang Dipegang)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => _errorMessage = null),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Target Tabungan Mingguan',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _savingsController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => _errorMessage = null),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(
                  color: PirschColors.mintGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: PirschColors.roseRed, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Budget Belanja Seminggu:',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      Text(
                        CurrencyFormatter.format(spendable),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimasi Kuota Awal / Hari:',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      Text(
                        CurrencyFormatter.format(dailyEst),
                        style: const TextStyle(
                          color: PirschColors.mintGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 Tips: Sistem akan otomatis mendistribusikan sisa budget belanja ke sisa hari setiap pagi, sehingga target tabungan pasti tercapai!',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.3),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
