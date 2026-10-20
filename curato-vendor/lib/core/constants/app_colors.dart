import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (warm monochrome palette from the Web site)
  static const Color primary = Color(0xFF0C0806); // foreground ink, primary button fill
  static const Color secondary = Color(0xFF5C534D); // muted-foreground

  // Neutral Colors
  static const Color background = Color(0xFFFAFAF9); // warm paper page background
  static const Color surface = Color(0xFFFAFAF9); // cards sit on paper, separated by hairlines
  static const Color muted = Color(0xFFF1F0ED); // raised panels
  static const Color border = Color(0xFFDCDBD6); // 1px hairlines
  static const Color error = Color(0xFFEF4444);

  // Text Colors
  static const Color textPrimary = Color(0xFF0C0806);
  static const Color textSecondary = Color(0xFF5C534D);
  static const Color textLight = Color(0xFF857D76);

  // Status Colors
  static const Color signal = Color(0xFF2C965D); // live/status indicator and success accents
  static const Color success = signal;
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
