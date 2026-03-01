import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// COLOR PALETTE
// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0057FF);
  static const Color primaryDark = Color(0xFF003DBF);
  static const Color accent = Color(0xFF00C9A7);
  static const Color accentLight = Color(0xFFE6FAF7);

  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF0F3F7);

  static const Color textPrimary = Color(0xFF0D1B2E);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFFADB5BD);
  static const Color divider = Color(0xFFE8ECF0);

  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF1DB954);
  static const Color warning = Color(0xFFF59E0B);
  static const Color star = Color(0xFFF59E0B);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0057FF), Color(0xFF0099CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    colors: [Color(0xFF0057FF), Color(0xFF00C9A7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

// ─────────────────────────────────────────────
// SPACING
// ─────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// ─────────────────────────────────────────────
// BORDER RADIUS
// ─────────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;
}

// ─────────────────────────────────────────────
// TEXT STYLES
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
// BOX DECORATIONS
// ─────────────────────────────────────────────
class AppDecorations {
  AppDecorations._();

  static BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 16,
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
