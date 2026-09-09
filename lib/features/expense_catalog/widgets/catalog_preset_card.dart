import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/expense_preset_model.dart';

/// Interactive preset card for quick one-tap expense logging.
class CatalogPresetCard extends StatefulWidget {
  final ExpensePresetModel preset;
  final ValueChanged<ExpensePresetModel> onSelect;
  final bool isDark;

  const CatalogPresetCard({
    super.key,
    required this.preset,
    required this.onSelect,
    required this.isDark,
  });

  @override
  State<CatalogPresetCard> createState() => _CatalogPresetCardState();
}

class _CatalogPresetCardState extends State<CatalogPresetCard> with SingleTickerProviderStateMixin {
  bool _isJustAdded = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _animController.forward().then((_) => _animController.reverse());

    setState(() => _isJustAdded = true);
    widget.onSelect(widget.preset);

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _isJustAdded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = PirschColors.card(widget.isDark);
    final borderColor = PirschColors.border(widget.isDark);
    final textPrimary = PirschColors.textPrimary(widget.isDark);
    final textSecondary = PirschColors.textSecondary(widget.isDark);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: widget.preset.color.withValues(alpha: 0.18),
          highlightColor: widget.preset.color.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isJustAdded ? PirschColors.mintGreen : borderColor,
                width: _isJustAdded ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Icon + Compact Tap Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.preset.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.preset.color.withValues(alpha: 0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(widget.preset.icon, color: widget.preset.color, size: 18),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isJustAdded
                            ? PirschColors.mintGreen
                            : (widget.isDark ? const Color(0xFF222226) : const Color(0xFFEBE6DA)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isJustAdded ? Icons.check_rounded : Icons.add_rounded,
                            size: 14,
                            color: _isJustAdded ? Colors.black : textPrimary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _isJustAdded ? 'Masuk!' : 'Masuk',
                            style: TextStyle(
                              color: _isJustAdded ? Colors.black : textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Bottom Content: Title & Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.preset.title,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '- ${CurrencyFormatter.format(widget.preset.amount)}',
                            style: TextStyle(
                              color: PirschColors.red(widget.isDark),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.preset.category,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
