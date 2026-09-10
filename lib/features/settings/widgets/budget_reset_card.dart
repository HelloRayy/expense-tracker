import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Collapsible danger action card to prevent accidental budget resets.
class BudgetResetCard extends StatefulWidget {
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
  State<BudgetResetCard> createState() => _BudgetResetCardState();
}

class _BudgetResetCardState extends State<BudgetResetCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final redColor = PirschColors.red(widget.isDark);
    final borderColor = widget.isDark ? const Color(0x1FFFFFFF) : const Color(0x0F000000);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _isExpanded
            ? redColor.withValues(alpha: widget.isDark ? 0.08 : 0.04)
            : (widget.isDark ? const Color(0xFF141414) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? redColor.withValues(alpha: 0.3) : borderColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Accordion Header (Always visible)
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.restart_alt_rounded,
                      size: 20,
                      color: _isExpanded ? redColor : widget.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Reset Nilai Budget',
                        style: TextStyle(
                          color: _isExpanded
                              ? redColor
                              : PirschColors.textPrimary(widget.isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.textSecondary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Collapsible Content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      height: 16,
                      thickness: 0.8,
                      color: redColor.withValues(alpha: 0.15),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tindakan ini hanya akan mereset pengaturan uang mingguan dan target tabungan menjadi Rp 0. Catatan riwayat pengeluaran tidak akan terhapus.',
                      style: TextStyle(
                        color: widget.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: widget.onReset,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: redColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: redColor.withValues(alpha: 0.4)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Konfirmasi Reset ke Rp 0',
                          style: TextStyle(
                            color: redColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}
