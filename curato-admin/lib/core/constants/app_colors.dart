import 'package:flutter/material.dart';

// Warm light palette taken from the Web site (src/app/globals.css).
// Light theme only.
class AppColors {
  // Web tokens
  static const Color background = Color(0xFFFAFAF9); // page background, warm paper
  static const Color foreground = Color(0xFF0C0806); // primary text, primary button fill
  static const Color muted = Color(0xFFF1F0ED); // raised panels
  static const Color mutedForeground = Color(0xFF5C534D); // secondary text
  static const Color border = Color(0xFFDCDBD6); // hairlines, used instead of card shadows
  static const Color signal = Color(0xFF2C965D); // live/status and success accents only
  static const Color signalTint = Color(0x1A2C965D); // light success fill

  // Existing names, mapped onto the tokens above
  static const Color primary = foreground;
  static const Color secondary = foreground;
  static const Color textPrimary = foreground;
  static const Color textSecondary = mutedForeground;
  static const Color cardBg = background;
}
