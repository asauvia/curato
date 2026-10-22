import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_admin/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final hairline = BorderSide(color: AppColors.border);
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: hairline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.border,
      colorScheme: ColorScheme.light(
        primary: AppColors.foreground,
        onPrimary: AppColors.background,
        secondary: AppColors.foreground,
        onSecondary: AppColors.background,
        error: AppColors.oxide,
        onError: AppColors.background,
        surface: AppColors.background,
        onSurface: AppColors.foreground,
        surfaceContainerHighest: AppColors.muted,
        outline: AppColors.border,
        outlineVariant: AppColors.border,
        surfaceTint: Colors.transparent,
      ),
      textTheme: GoogleFonts.instrumentSansTextTheme().copyWith(
        displayLarge: GoogleFonts.fraunces(
          color: AppColors.foreground,
          fontWeight: FontWeight.w400,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.fraunces(
          color: AppColors.foreground,
          fontWeight: FontWeight.w400,
          letterSpacing: -1.0,
        ),
        displaySmall: GoogleFonts.fraunces(
          color: AppColors.foreground,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: hairline,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: hairline,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.foreground, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.foreground,
          foregroundColor: AppColors.background,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          side: hairline,
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}
