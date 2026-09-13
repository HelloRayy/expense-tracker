import 'package:flutter/material.dart';

/// Official Pirsch Design System Tokens extracted from https://pirsch.io
class PirschColors {
  // Core Brand Palette (Urbanist Neo-Fintech)
  static const Color primaryBlue = Color(0xFF6578C8);  // Signature Periwinkle Indigo (#6578C8)
  static const Color pureWhite = Color(0xFFFFFFFF);    // High contrast Card/Pill Accent (#FFFFFF)
  static const Color darkSurface = Color(0xFF242424);  // Elevated Surface & Container (#242424)
  static const Color deepOnyx = Color(0xFF0C0C0C);     // Ultra Deep Background Canvas (#0C0C0C)

  // Secondary & Semantic Accents
  static const Color mintGreen = Color(0xFF6578C8);    // Primary Accent aligned to Periwinkle
  static const Color incomeGreen = Color(0xFF4ADE80);  // Clean Financial Green (Positive)
  static const Color roseRed = Color(0xFFF87171);      // Modern Soft Coral Red (Expenses/Overbudget)
  static const Color coralOrange = Color(0xFFF7A66B); // Warm Coral Orange (Food / Dining category)
  static const Color warmYellow = Color(0xFFFFDA6E);   // Warning Accent
  static const Color beige = Color(0xFFF4F5FA);        // Clean Soft Grey-Lavender for Light Mode

  // Calibrated WCAG 2.1 AA Tokens
  static const Color accessibleGreen = Color(0xFF1D7A4A);
  static const Color accessibleAmber = Color(0xFF996100);
  static const Color accessibleCrimson = Color(0xFFDC2626);

  // Dark Theme Tokens (Deep Onyx #0C0C0C + Elevated Cards #242424)
  static const Color darkBg = Color(0xFF0C0C0E);
  static const Color darkCard = Color(0xFF18181B);
  static const Color darkCardElevated = Color(0xFF222226);
  static const Color darkBorder = Colors.transparent;   // Borderless matte aesthetic
  static const Color darkTextPrimary = Color(0xFFEDEDED); // Soft Off-White (Anti-glare WCAG AAA 16.7:1)
  static const Color darkTextSecondary = Color(0xFFA1A1AA); // Calibrated Zinc Grey (Anti-fatigue 7.6:1)
  static const Color darkDivider = Colors.transparent;  // Borderless list stacking
  static const Color darkPill = Color(0xFFFFFFFF);     // High-contrast white pill (like Top Up button)

  // Light Theme Tokens
  static const Color lightBg = Color(0xFFF5F6FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFECEEF5);
  static const Color lightBorder = Colors.transparent;
  static const Color lightDivider = Colors.transparent;
  static const Color lightTextPrimary = Color(0xFF0C0C0C);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightPill = Color(0xFF0C0C0C);

  // Dynamic Theme Helpers
  static Color bg(bool isDark) => isDark ? darkBg : lightBg;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color cardElevated(bool isDark) => isDark ? darkCardElevated : lightCardElevated;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color divider(bool isDark) => isDark ? darkDivider : lightDivider;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color pill(bool isDark) => isDark ? darkPill : lightPill;
  static Color pillText(bool isDark) => isDark ? const Color(0xFF0C0C0C) : const Color(0xFFFFFFFF);

  // Dynamic Semantic Colors
  static Color green(bool isDark) => isDark ? incomeGreen : accessibleGreen;
  static Color yellow(bool isDark) => isDark ? warmYellow : accessibleAmber;
  static Color red(bool isDark) => isDark ? roseRed : accessibleCrimson;

  // Ambient Radial Gradient Glow Tokens (Periwinkle Blue Bloom)
  static Color ambientGlowColor({
    required bool isDark,
    required bool isOverBudget,
    required bool isWarning,
  }) {
    if (isOverBudget) {
      return roseRed.withValues(alpha: isDark ? 0.16 : 0.08);
    }
    if (isWarning) {
      return warmYellow.withValues(alpha: isDark ? 0.14 : 0.08);
    }
    return primaryBlue.withValues(alpha: isDark ? 0.20 : 0.10);
  }
}

/// Backward compatibility aliases mapped to Pirsch Design Tokens
class AppColors {
  static const Color primary = PirschColors.primaryBlue;
  static const Color primaryDark = Color(0xFF4E5EAA);
  static const Color secondary = PirschColors.warmYellow;
  static const Color background = PirschColors.darkBg;
  static const Color surface = PirschColors.darkCard;
  static const Color surfaceLight = PirschColors.darkCardElevated;
  
  static const Color textPrimary = PirschColors.darkTextPrimary;
  static const Color textSecondary = PirschColors.darkTextSecondary;
  static const Color textMuted = Color(0xFF707070);

  static const Color danger = PirschColors.roseRed;
  static const Color warning = PirschColors.warmYellow;
  static const Color success = PirschColors.incomeGreen;
}

