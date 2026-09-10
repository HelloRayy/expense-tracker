import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Secondary Nudge & Action Card for Dashboard.
/// Tappable contextual card with leading status icon and compact action indicator.
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
    final VoidCallback buttonAction;
    final IconData statusIcon;
    final Color statusColor;

    if (isUnset) {
      message = 'Atur budget mingguanmu';
      buttonAction = onConfigureBudget;
      statusIcon = Icons.tune_rounded;
      statusColor = PirschColors.yellow(isDark);
    } else if (isOverBudget) {
      message = 'Batas budget terlampaui';
      buttonAction = onQuickLog;
      statusIcon = Icons.warning_amber_rounded;
      statusColor = PirschColors.red(isDark);
    } else if (dailyAllowance < 20000) {
      message = 'Jatah harian menipis';
      buttonAction = onQuickLog;
      statusIcon = Icons.trending_down_rounded;
      statusColor = PirschColors.yellow(isDark);
    } else {
      message = 'Ada pengeluaran baru?';
      buttonAction = onQuickLog;
      statusIcon = Icons.add_circle_outline_rounded;
      statusColor = PirschColors.green(isDark);
    }

    return Container(
      width: double.infinity,
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: buttonAction,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  statusIcon,
                  size: 18,
                  color: statusColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: textPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
