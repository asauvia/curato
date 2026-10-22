import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curato_user/core/constants/app_colors.dart';
import 'package:curato_user/core/theme/app_button_styles.dart';

void main() {
  test('brassOutline resolves brass border/text on paper by default, inverts on hover', () {
    final style = AppButtonStyles.brassOutline();

    expect(style.side?.resolve({}), const BorderSide(color: AppColors.brass, width: 1.5));
    expect(style.backgroundColor?.resolve({}), AppColors.background);
    expect(style.foregroundColor?.resolve({}), AppColors.brass);

    expect(style.backgroundColor?.resolve({WidgetState.hovered}), AppColors.brass);
    expect(style.foregroundColor?.resolve({WidgetState.hovered}), AppColors.background);
  });

  test('brassOutline dims to grey when disabled, not brass', () {
    final style = AppButtonStyles.brassOutline();

    expect(style.side?.resolve({WidgetState.disabled}), const BorderSide(color: AppColors.grey, width: 1.5));
    expect(style.backgroundColor?.resolve({WidgetState.disabled}), AppColors.background);
    expect(style.foregroundColor?.resolve({WidgetState.disabled}), AppColors.grey);
  });

  test('inkOutline resolves hairline border/ink text on paper, dims when disabled', () {
    final style = AppButtonStyles.inkOutline();

    expect(style.side?.resolve({}), const BorderSide(color: AppColors.border, width: 1.5));
    expect(style.backgroundColor?.resolve({}), AppColors.background);
    expect(style.foregroundColor?.resolve({}), AppColors.foreground);

    expect(style.side?.resolve({WidgetState.disabled}), const BorderSide(color: AppColors.grey, width: 1.5));
    expect(style.foregroundColor?.resolve({WidgetState.disabled}), AppColors.grey);
  });

  test('brassOutline uses the given padding, defaulting to vertical 12', () {
    expect(
      AppButtonStyles.brassOutline().padding?.resolve({}),
      const EdgeInsets.symmetric(vertical: 12),
    );
    expect(
      AppButtonStyles.brassOutline(padding: const EdgeInsets.symmetric(vertical: 8)).padding?.resolve({}),
      const EdgeInsets.symmetric(vertical: 8),
    );
  });
}
