import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Danger action card providing a clear button to reset the user's budget to Rp 0.
class BudgetResetCard extends StatelessWidget {
  final bool isDark;
  final Color textSecondary;
  final VoidCallback onReset;

  const BudgetResetCard({
    super.key,
    required this.isDark,
    required this.textSecondary,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: PirschColors.red(isDark).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PirschColors.red(isDark).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reset Nilai Budget',
            style: TextStyle(
              color: PirschColors.red(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Atur ulang uang mingguan dan target tabungan menjadi Rp 0.',
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onReset,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PirschColors.red(isDark).withValues(alpha: 0.35)),
              ),
              alignment: Alignment.center,
              child: Text(
                'Kembalikan ke Default (Rp 0)',
                style: TextStyle(
                  color: PirschColors.red(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
