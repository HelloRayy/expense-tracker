import 'package:flutter/material.dart';

/// Official Pirsch Design System Tokens extracted from https://pirsch.io
class PirschColors {
  // Core Brand Palette
  static const Color beige = Color(0xFFF8F5ED);       // Signature Warm Beige
  static const Color mintGreen = Color(0xFF6ECE9D);   // Signature Mint Emerald
  static const Color warmYellow = Color(0xFFFFDA6E);  // Warm Accent Yellow
  static const Color coralOrange = Color(0xFFF7A66B); // Warm Coral Orange
  static const Color roseRed = Color(0xFFE87B7B);     // Soft Rose Red (Overbudget)

  // Dark Theme Tokens (Deep Onyx)
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color darkCard = Color(0xFF141414);
  static const Color darkCardElevated = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0x1FFFFFFF);   // Hairline ~12% white
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFADADAD);

  // Light Theme Tokens (Warm Paper)
  static const Color lightBg = Color(0xFFF8F5ED);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF2EFE6);
  static const Color lightBorder = Color(0x0F000000);  // Hairline ~6% black
  static const Color lightTextPrimary = Color(0xFF0A0A0A);
  static const Color lightTextSecondary = Color(0xFF707070);

  // Dynamic Theme Helpers
  static Color bg(bool isDark) => isDark ? darkBg : lightBg;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color cardElevated(bool isDark) => isDark ? darkCardElevated : lightCardElevated;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
}

/// Backward compatibility aliases mapped to Pirsch Design Tokens
class AppColors {
  static const Color primary = PirschColors.mintGreen;
  static const Color primaryDark = Color(0xFF56B585);
  static const Color secondary = PirschColors.warmYellow;
  static const Color background = PirschColors.darkBg;
  static const Color surface = PirschColors.darkCard;
  static const Color surfaceLight = PirschColors.darkCardElevated;
  
  static const Color textPrimary = PirschColors.darkTextPrimary;
  static const Color textSecondary = PirschColors.darkTextSecondary;
  static const Color textMuted = Color(0xFF707070);

  static const Color danger = PirschColors.roseRed;
  static const Color warning = PirschColors.warmYellow;
  static const Color success = PirschColors.mintGreen;
}

