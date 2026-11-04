import 'package:flutter/material.dart';

/// MediVision AI Theme Colors
/// Refined, minimal, production healthcare palette:
/// Clean whites, warm slate neutrals, medical teal, and restrained semantic accents.
class AppColors {
  AppColors._();

  // Primary Palette - Sophisticated Clinical Slate Navy
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryDark = Color(0xFF020617); // Slate 950
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color primaryContainer = Color(0xFFF1F5F9); // Slate 100

  // Secondary Palette - Calm Clinical Teal
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color secondaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color secondaryDark = Color(0xFF0F766E); // Teal 700
  static const Color secondaryContainer = Color(0xFFF0FDFA); // Teal 50
  static const Color secondarySage = Color(0xFFCCFBF1); // Teal 100

  // Convenience Aliases for Medical/Green palette
  static const Color primaryGreen = Color(0xFF0D9488);
  static const Color forestGreen = Color(0xFF0F766E);
  static const Color mintAccent = Color(0xFF14B8A6);

  // Semantic Accents - Restrained & purposeful
  static const Color accentIndigo = Color(0xFF4F46E5); // Indigo 600
  static const Color accentEmerald = Color(0xFF059669); // Emerald 600
  static const Color accentAmber = Color(0xFFD97706); // Amber 600
  static const Color accentRose = Color(0xFFE11D48); // Rose 600
  static const Color accentCyan = Color(0xFF0891B2); // Cyan 600

  // Background & Surfaces - Clean & Minimal
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color mainBackground = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Slate 100

  // Border & Dividers - Ultra-clean 1px structure
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderSubtle = Color(0xFFF1F5F9); // Slate 100
  static const Color divider = Color(0xFFE2E8F0);

  // Text Colors - Strong, accessible contrast hierarchy
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color primaryText = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color secondaryText = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic Status Badges
  static const Color success = Color(0xFF059669);
  static const Color successBackground = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningBackground = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBackground = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoBackground = Color(0xFFEFF6FF);

  // Subtle, high-end shadows (zero harsh artificial glows)
  static const Color shadow = Color(0x060F172A);
  static const Color shadowMedium = Color(0x0C0F172A);
}
