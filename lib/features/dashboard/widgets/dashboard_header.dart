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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PirschColors.mintGreen.withValues(alpha: 0.15),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person_rounded, color: PirschColors.mintGreen, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Raditya Rayhan',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                        letterSpacing: -0.2,
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
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: elevatedColor,
                borderRadius: BorderRadius.circular(12),
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
