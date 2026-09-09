import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/category_assign_evaluator.dart';

/// Sticky bottom confirmation bar for committing category assignments to database.
class CategorySaveBar extends StatelessWidget {
  final CategoryDiffResult diff;
  final bool isSaving;
  final VoidCallback onSave;
  final bool isDark;

  const CategorySaveBar({
    super.key,
    required this.diff,
    required this.isSaving,
    required this.onSave,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = PirschColors.card(isDark);
    final borderColor = PirschColors.border(isDark);
    final textSecondary = PirschColors.textSecondary(isDark);

    final String statusText;
    if (diff.hasChanges) {
      statusText = '${diff.totalChanges} perubahan belum disimpan';
    } else {
      statusText = 'Belum ada perubahan';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor, width: 1.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      color: diff.hasChanges ? PirschColors.green(isDark) : textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    diff.hasChanges ? 'Ketuk simpan untuk konfirmasi' : 'Pilih transaksi di atas',
                    style: TextStyle(color: textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: diff.hasChanges && !isSaving ? onSave : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PirschColors.pill(isDark),
                  foregroundColor: PirschColors.pillText(isDark),
                  disabledBackgroundColor: (isDark ? Colors.white12 : Colors.black12),
                  disabledForegroundColor: textSecondary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Simpan',
                        style: TextStyle(
                          color: diff.hasChanges
                              ? PirschColors.pillText(isDark)
                              : textSecondary.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
