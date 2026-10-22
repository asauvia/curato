import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curato_user/core/constants/app_colors.dart';
import 'package:curato_user/core/theme/app_theme.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  test('design tokens use the modern-luxury-showroom palette', () {
    expect(AppColors.background, const Color(0xFFF7F4EF));
    expect(AppColors.foreground, const Color(0xFF16130F));
    expect(AppColors.muted, const Color(0xFFECE7DF));
    expect(AppColors.mutedForeground, const Color(0xFF6B6257));
    expect(AppColors.border, const Color(0xFFDAD2C4));
    expect(AppColors.signal, const Color(0xFF4A6B4D));
    expect(AppColors.brass, const Color(0xFFA6823E));
    expect(AppColors.oxide, const Color(0xFFA23B2E));
    // legacy alias must track the new foreground value, not a stale literal
    expect(AppColors.maroonFestive, const Color(0xFF16130F));
    expect(AppColors.creamBg, const Color(0xFFF7F4EF));
  });

  test('display headings use Fraunces, body text keeps Instrument Sans', () {
    final textTheme = AppTheme.lightTheme.textTheme;
    expect(textTheme.displayLarge?.fontFamily, contains('Fraunces'));
    expect(textTheme.displayMedium?.fontFamily, contains('Fraunces'));
    expect(textTheme.titleLarge?.fontFamily, contains('Fraunces'));
    expect(textTheme.bodyMedium?.fontFamily, contains('Instrument Sans'));
  });
}
