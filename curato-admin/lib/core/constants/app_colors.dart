import 'package:flutter/material.dart';

// Warm light palette taken from the Web site (src/app/globals.css).
// Light theme only.
class AppColors {
  // Web tokens
  static const Color background = Color(0xFFF7F4EF); // page background, warm paper
  static const Color foreground = Color(0xFF16130F); // primary text, primary button fill
  static const Color muted = Color(0xFFECE7DF); // raised panels
  static const Color mutedForeground = Color(0xFF6B6257); // secondary text
  static const Color border = Color(0xFFDAD2C4); // hairlines, used instead of card shadows
  static const Color signal = Color(0xFF4A6B4D); // live/status and success accents only
  static const Color signalTint = Color(0x1A4A6B4D); // light success fill
  static const Color brass = Color(0xFFA6823E); // warm accent
  static const Color oxide = Color(0xFFA23B2E); // error and destructive accent

  // Existing names, mapped onto the tokens above
  static const Color primary = foreground;
  static const Color secondary = foreground;
  static const Color textPrimary = foreground;
  static const Color textSecondary = mutedForeground;
  static const Color cardBg = background;
}
