import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Top App Bar Header for Dashboard.
/// Displays user avatar profile, title 'Mental Budget', and quick settings action button.
class DashboardHeader extends StatelessWidget {
  final Color textPrimary;
  final Color textSecondary;
  final Color elevatedColor;
  final Color borderColor;
  final VoidCallback onSettingsTap;

  const DashboardHeader({
    super.key,
    required this.textPrimary,
    required this.textSecondary,
    required this.elevatedColor,
    required this.borderColor,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User Profile & Greeting
        Expanded(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PirschColors.mintGreen.withValues(alpha: 0.15),
                  border: Border.all(
                    color: PirschColors.mintGreen.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person_rounded, color: PirschColors.mintGreen, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Halo, Raditya Rayhan',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Mental Budget',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Settings / Tune Action Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSettingsTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: elevatedColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.tune_rounded, color: textPrimary, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}
