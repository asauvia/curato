import 'package:flutter/material.dart';
import 'package:curato_user/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light theme only (warm paper, hairline borders, Instrument Sans, pill buttons).
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.foreground,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.foreground,
      brightness: Brightness.light,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      primary: AppColors.foreground,
      onPrimary: AppColors.background,
      secondary: AppColors.foreground,
      outline: AppColors.border,
    ),
    textTheme: GoogleFonts.instrumentSansTextTheme()
        .apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary)
        .copyWith(
          displayLarge: GoogleFonts.fraunces(
            fontWeight: FontWeight.w400,
            letterSpacing: -1.5,
            color: AppColors.textPrimary,
          ),
          displayMedium: GoogleFonts.fraunces(
            fontWeight: FontWeight.w400,
            letterSpacing: -1.0,
            color: AppColors.textPrimary,
          ),
          titleLarge: GoogleFonts.fraunces(
            fontWeight: FontWeight.w400,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.foreground,
      surfaceTintColor: AppColors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.foreground,
        foregroundColor: AppColors.background,
        elevation: 0,
        shape: const StadiumBorder(),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.foreground,
        foregroundColor: AppColors.background,
        elevation: 0,
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.foreground,
        side: const BorderSide(color: AppColors.border),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.foreground,
        shape: const StadiumBorder(),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: const WidgetStatePropertyAll<bool>(true),
      // trackVisibility: const WidgetStatePropertyAll<bool>(true),
      thickness: const WidgetStatePropertyAll<double>(8.0),
      radius: const Radius.circular(8),
      thumbColor: WidgetStatePropertyAll<Color>(AppColors.primaryPink),
      // trackColor: WidgetStatePropertyAll<Color>(AppColors.borderLight),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.borderLight),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shadowColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    ),
  );
}
