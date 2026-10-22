import 'package:flutter/material.dart';

/// Semantic verdict category with strict accessibility styling
enum VerdictType {
  true_,
  false_,
  misleading,
  unverified,
}

class AppColors {
  // Brand foundation
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);

  // Typography colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Verdict - True (Green)
  static const Color trueGreen = Color(0xFF16A34A);
  static const Color trueGreenLight = Color(0xFFF0FDF4);
  static const Color trueGreenBorder = Color(0xFFBBF7D0);

  // Verdict - False (Red)
  static const Color falseRed = Color(0xFFDC2626);
  static const Color falseRedLight = Color(0xFFFEF2F2);
  static const Color falseRedBorder = Color(0xFFFECACA);

  // Verdict - Misleading (Amber)
  static const Color misleadingAmber = Color(0xFFD97706);
  static const Color misleadingAmberLight = Color(0xFFFFFBEB);
  static const Color misleadingAmberBorder = Color(0xFFFDE68A);

  // Verdict - Can't verify (Grey-blue)
  static const Color unverifiedSlate = Color(0xFF64748B);
  static const Color unverifiedSlateLight = Color(0xFFF1F5F9);
  static const Color unverifiedSlateBorder = Color(0xFFCBD5E1);

  // Helpers for verdicts
  static Color verdictColor(VerdictType verdict) {
    switch (verdict) {
      case VerdictType.true_:
        return trueGreen;
      case VerdictType.false_:
        return falseRed;
      case VerdictType.misleading:
        return misleadingAmber;
      case VerdictType.unverified:
        return unverifiedSlate;
    }
  }

  static Color verdictLightColor(VerdictType verdict) {
    switch (verdict) {
      case VerdictType.true_:
        return trueGreenLight;
      case VerdictType.false_:
        return falseRedLight;
      case VerdictType.misleading:
        return misleadingAmberLight;
      case VerdictType.unverified:
        return unverifiedSlateLight;
    }
  }

  static Color verdictBorderColor(VerdictType verdict) {
    switch (verdict) {
      case VerdictType.true_:
        return trueGreenBorder;
      case VerdictType.false_:
        return falseRedBorder;
      case VerdictType.misleading:
        return misleadingAmberBorder;
      case VerdictType.unverified:
        return unverifiedSlateBorder;
    }
  }

  static IconData verdictIcon(VerdictType verdict) {
    switch (verdict) {
      case VerdictType.true_:
        return Icons.check_circle_rounded;
      case VerdictType.false_:
        return Icons.cancel_rounded;
      case VerdictType.misleading:
        return Icons.warning_rounded;
      case VerdictType.unverified:
        return Icons.help_outline_rounded;
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
      ),
      fontFamily: null, // default system readable font
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.falseRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.falseRed, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          side: const BorderSide(color: AppColors.border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        elevation: 2,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
