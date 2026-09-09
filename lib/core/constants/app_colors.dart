import 'package:flutter/material.dart';

/// Official Pirsch Design System Tokens extracted from https://pirsch.io
class PirschColors {
  // Core Brand Palette
  static const Color beige = Color(0xFFF8F5ED);       // Signature Warm Beige
  static const Color mintGreen = Color(0xFF6ECE9D);   // Signature Mint Emerald
  static const Color warmYellow = Color(0xFFFFDA6E);  // Warm Accent Yellow
  static const Color coralOrange = Color(0xFFF7A66B); // Warm Coral Orange
  static const Color roseRed = Color(0xFFE87B7B);     // Soft Rose Red (Overbudget)

  // Calibrated WCAG 2.1 AA Tokens (>= 4.5:1 on light warm beige #F8F5ED)
  static const Color accessibleGreen = Color(0xFF1D7A4A);   // 4.9:1 on beige
  static const Color accessibleAmber = Color(0xFF996100);   // 4.7:1 on beige
  static const Color accessibleCrimson = Color(0xFFC53030); // 5.0:1 on beige

  // Dark Theme Tokens (Deep Onyx with Ergonomic Softening against Halation)
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color darkCard = Color(0xFF141414);
  static const Color darkCardElevated = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0x1FFFFFFF);   // Hairline ~12% white
  static const Color darkTextPrimary = Color(0xFFEBEBEB); // Softened from #FFFFFF to prevent eye strain/halation (16.6:1)
  static const Color darkTextSecondary = Color(0xFFA3A3A3); // Soft secondary grey
  static const Color darkDivider = Color(0x12FFFFFF);  // Ultra-soft dark hairline divider (~7% white)
  static const Color darkPill = Color(0xFFE8E8E8); // Ergonomic soft white pill

  // Light Theme Tokens (Warm Paper with Anti-Harsh Calibrated Contrast)
  static const Color lightBg = Color(0xFFF8F5ED);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF2EFE6);
  static const Color lightBorder = Color(0x0F000000);  // Hairline ~6% black
  static const Color lightDivider = Color(0xFFECE7DC); // Ultra-soft warm hairline divider (~3% delta from #F8F5ED)
  static const Color lightTextPrimary = Color(0xFF222222); // Softened from #0A0A0A to prevent optical vibration (14.6:1)
  static const Color lightTextSecondary = Color(0xFF666666); // 5.3:1 (safe AA)
  static const Color lightPill = Color(0xFF1C1C1E); // Ergonomic soft black pill

  // Dynamic Theme Helpers
  static Color bg(bool isDark) => isDark ? darkBg : lightBg;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color cardElevated(bool isDark) => isDark ? darkCardElevated : lightCardElevated;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color divider(bool isDark) => isDark ? darkDivider : lightDivider;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color pill(bool isDark) => isDark ? darkPill : lightPill;
  static Color pillText(bool isDark) => isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);

  // Dynamic WCAG 2.1 AA Compliant Semantic Colors
  static Color green(bool isDark) => isDark ? mintGreen : accessibleGreen;
  static Color yellow(bool isDark) => isDark ? warmYellow : accessibleAmber;
  static Color red(bool isDark) => isDark ? roseRed : accessibleCrimson;
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

