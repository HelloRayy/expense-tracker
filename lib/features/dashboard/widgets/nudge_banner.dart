import 'package:flutter/material.dart';

/// Secondary Nudge & Action Card for Dashboard.
/// Displays contextual reminders and a pill action button (e.g., 'Atur budget' or 'Catat sekarang').
class NudgeBanner extends StatelessWidget {
  final int weeklyIncome;
  final int dailyAllowance;
  final bool isOverBudget;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final bool isDark;
  final VoidCallback onConfigureBudget;
  final VoidCallback onQuickLog;

  const NudgeBanner({
    super.key,
    required this.weeklyIncome,
    required this.dailyAllowance,
    required this.isOverBudget,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.isDark,
    required this.onConfigureBudget,
    required this.onQuickLog,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnset = weeklyIncome <= 0;
    final String message;
    final String buttonLabel;
    final VoidCallback buttonAction;

    if (isUnset) {
      message = 'Yuk atur budget mingguanmu!';
      buttonLabel = 'Atur budget';
      buttonAction = onConfigureBudget;
    } else if (isOverBudget) {
      message = 'Batas jajan habis, tahan jajan dulu!';
      buttonLabel = 'Catat sekarang';
      buttonAction = onQuickLog;
    } else if (dailyAllowance < 20000) {
      message = 'Jatah menipis, catat pengeluaran!';
      buttonLabel = 'Catat sekarang';
      buttonAction = onQuickLog;
    } else {
      message = 'Ada jajan yang belum dicatat?';
      buttonLabel = 'Catat sekarang';
      buttonAction = onQuickLog;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: isDark ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: buttonAction,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
