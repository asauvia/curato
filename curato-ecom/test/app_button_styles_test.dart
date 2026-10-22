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
