import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ROAMGENIE — PREMIUM TRAVEL COLOR SYSTEM
// Palette: Deep Ocean Navy · Sky Teal · Sunset Orange CTA · Off-white BG
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Brand primaries — Deep Ocean Blue
  static const Color primary     = Color(0xFF0D47A1); // Deep ocean blue
  static const Color primaryDark = Color(0xFF002171); // Navy dark
  static const Color primaryLight= Color(0xFF5472D3); // Cornflower blue

  // ── Accent — tropical teal / sky
  static const Color accent      = Color(0xFF00BFA5); // Tropical teal
  static const Color accentLight = Color(0xFFE0F7F4); // Teal tint

  // ── CTA — warm sunset orange
  static const Color sunset      = Color(0xFFFF6D00); // Warm sunset orange (CTA)
  static const Color sunsetLight = Color(0xFFFFF0E5); // Sunset tint
  static const Color gold        = Color(0xFFFFB300); // Golden amber

  // ── Surfaces
  static const Color background  = Color(0xFFF4F6FA); // Premium off-white bg
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFECF0F9); // Blue-tinted grey
  static const Color card        = Color(0xFFFFFFFF);

  // ── Text
  static const Color textPrimary   = Color(0xFF0A1931); // Deep navy text
  static const Color textSecondary = Color(0xFF546280); // Muted slate
  static const Color textMuted     = Color(0xFFAAB4C8); // Lightest text
  static const Color divider       = Color(0xFFE2E8F4); // Blue-tinted divider

  // ── Semantic
  static const Color error   = Color(0xFFD32F2F);
  static const Color success = Color(0xFF00897B); // Teal-green success
  static const Color warning = Color(0xFFFF8F00);
  static const Color star    = Color(0xFFFFB300);

  // ── Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF002171), Color(0xFF0D47A1), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00695C), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFE65100), Color(0xFFFF6D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF00BFA5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SPACING
// ─────────────────────────────────────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// BORDER RADIUS
// ─────────────────────────────────────────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double full = 999.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// TEXT STYLES
// ─────────────────────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BOX DECORATIONS
// ─────────────────────────────────────────────────────────────────────────────
class AppDecorations {
  AppDecorations._();

  static BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF0B5FFF).withValues(alpha: 0.06),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration inputField = BoxDecoration(
    color: AppColors.surfaceGrey,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border.all(color: AppColors.divider),
  );

  static BoxDecoration inputFieldFocused = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border.all(color: AppColors.primary, width: 1.5),
  );
}
