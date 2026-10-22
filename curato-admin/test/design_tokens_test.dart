import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curato_admin/core/constants/app_colors.dart';
import 'package:curato_admin/core/theme/app_theme.dart';

void main() {
  test('design tokens use the modern-luxury-showroom palette', () {
    expect(AppColors.background, const Color(0xFFF7F4EF));
    expect(AppColors.foreground, const Color(0xFF16130F));
    expect(AppColors.muted, const Color(0xFFECE7DF));
    expect(AppColors.mutedForeground, const Color(0xFF6B6257));
    expect(AppColors.border, const Color(0xFFDAD2C4));
    expect(AppColors.signal, const Color(0xFF4A6B4D));
    expect(AppColors.signalTint, const Color(0x1A4A6B4D));
    expect(AppColors.brass, const Color(0xFFA6823E));
    expect(AppColors.oxide, const Color(0xFFA23B2E));
  });

  test('display headings use Fraunces and the error color is oxide', () {
    final textTheme = AppTheme.lightTheme.textTheme;
    expect(textTheme.displayLarge?.fontFamily, contains('Fraunces'));
    expect(textTheme.displayMedium?.fontFamily, contains('Fraunces'));
    expect(textTheme.displaySmall?.fontFamily, contains('Fraunces'));
    expect(AppTheme.lightTheme.colorScheme.error, const Color(0xFFA23B2E));
  });
}
