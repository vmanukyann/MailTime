import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const blue = Color(0xFF2563EB);
  static const blueDark = Color(0xFF1E40AF);
  static const silver = Color(0xFFE2E8F0);
  static const silverDark = Color(0xFF94A3B8);
  static const white = Color(0xFFFFFFFF);
  static const slate = Color(0xFF0F172A);
  static const slateSoft = Color(0xFF334155);
  static const background = Color(0xFFF7FAFF);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light();
    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.manrope(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        color: AppColors.slate,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.slate,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.slate,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.slate,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.slateSoft,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.slateSoft,
      ),
    );

    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.blue,
        secondary: AppColors.silverDark,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSurface: AppColors.slate,
        background: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.slate,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.silver),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.silver),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue,
          side: const BorderSide(color: AppColors.blue),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.silver,
        labelStyle: textTheme.bodyMedium!.copyWith(color: AppColors.slate),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}
