import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (warm monochrome palette from the Web site)
  static const Color primary = Color(0xFF16130F); // foreground ink, primary button fill
  static const Color secondary = Color(0xFF6B6257); // muted-foreground

  // Neutral Colors
  static const Color background = Color(0xFFF7F4EF); // warm paper page background
  static const Color surface = Color(0xFFF7F4EF); // cards sit on paper, separated by hairlines
  static const Color muted = Color(0xFFECE7DF); // raised panels
  static const Color border = Color(0xFFDAD2C4); // 1px hairlines
  static const Color error = Color(0xFFA23B2E); // oxide, replaces the unrelated Material red

  // Text Colors
  static const Color textPrimary = Color(0xFF16130F);
  static const Color textSecondary = Color(0xFF6B6257);
  static const Color textLight = Color(0xFF857D76);

  // Status Colors
  static const Color signal = Color(0xFF4A6B4D); // live/status indicator and success accents
  static const Color success = signal;
  static const Color brass = Color(0xFFA6823E); // brass accent
  static const Color oxide = Color(0xFFA23B2E); // oxide accent
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
