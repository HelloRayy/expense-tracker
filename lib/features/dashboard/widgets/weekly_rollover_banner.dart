import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// Interactive banner on Dashboard informing the user that a new week has started
/// and prompting them to input/confirm their new weekly budget.
class WeeklyRolloverBanner extends StatelessWidget {
  final int carryoverBalance;
  final bool isDark;
  final VoidCallback onInputBudget;

  const WeeklyRolloverBanner({
    super.key,
    required this.carryoverBalance,
    required this.isDark,
    required this.onInputBudget,
  });

  @override
  Widget build(BuildContext context) {
    final hasCarryover = carryoverBalance > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B241E) : const Color(0xFFEBF7F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PirschColors.mintGreen.withValues(alpha: isDark ? 0.35 : 0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PirschColors.mintGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_repeat_rounded,
              color: PirschColors.mintGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Periode Baru Dimulai',
                  style: TextStyle(
                    color: PirschColors.mintGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasCarryover
                      ? 'Ada sisa ${CurrencyFormatter.format(carryoverBalance)} dari minggu lalu. Yuk atur budget minggu ini!'
                      : 'Yuk masukkan uang jajan untuk memulai minggu ini!',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFC7D4CC) : const Color(0xFF335C43),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onInputBudget,
            style: ElevatedButton.styleFrom(
              backgroundColor: PirschColors.mintGreen,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Input',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
