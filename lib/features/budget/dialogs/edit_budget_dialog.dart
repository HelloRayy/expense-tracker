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
  late TextEditingController _amountController;
  late int _selectedPayday;

  @override
  void initState() {
    super.initState();
    final current = widget.repository.budget;
    _amountController = TextEditingController(
      text: current?.totalBudget.toString() ?? '1500000',
    );
    _selectedPayday = current?.paydayDay ?? 25;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount <= 0) return;

    widget.repository.updateBudget(
      totalBudget: amount,
      paydayDay: _selectedPayday,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Atur Alokasi Uang Jajan',
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
              'Nominal Budget Jajan Per Bulan',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
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
            const SizedBox(height: 18),
            const Text(
              'Tanggal Gajian (Awal Periode)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedPayday,
                  dropdownColor: AppColors.surface,
                  isExpanded: true,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  items: List.generate(31, (i) => i + 1).map((day) {
                    return DropdownMenuItem<int>(
                      value: day,
                      child: Text('Tanggal $day setiap bulan'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPayday = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 Tips: Hanya masukkan porsi uang jajan (uang ngopi, jajan sore, checkout impulsif). Uang pokok seperti kos & cicilan jangan digabung ke sini.',
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
