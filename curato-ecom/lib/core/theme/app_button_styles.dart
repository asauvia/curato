import 'package:flutter/material.dart';
import 'package:curato_user/core/constants/app_colors.dart';

/// Reusable button styles from the design system beyond the default theme.
class AppButtonStyles {
  /// Brass border/text on paper; inverts to filled brass on hover/press.
  /// Reserved for the single primary purchase action per screen (e.g. Add to Cart).
  static ButtonStyle brassOutline({EdgeInsetsGeometry? padding}) {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      padding: WidgetStatePropertyAll(
        padding ?? const EdgeInsets.symmetric(vertical: 12),
      ),
      side: const WidgetStatePropertyAll(
        BorderSide(color: AppColors.brass, width: 1.5),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
          return AppColors.brass;
        }
        return AppColors.background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
          return AppColors.background;
        }
        return AppColors.brass;
      }),
    );
  }
}
