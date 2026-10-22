import 'package:flutter/material.dart';
import 'package:curato_user/core/constants/app_colors.dart';

/// Reusable button styles from the design system beyond the default theme.
class AppButtonStyles {
  /// Brass border/text on paper; inverts to filled brass on hover/press;
  /// dims when disabled (e.g. out of stock).
  /// Reserved for the single primary purchase action per screen (e.g. Buy Now).
  static ButtonStyle brassOutline({EdgeInsetsGeometry? padding}) {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      padding: WidgetStatePropertyAll(
        padding ?? const EdgeInsets.symmetric(vertical: 12),
      ),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const BorderSide(color: AppColors.grey, width: 1.5);
        }
        return const BorderSide(color: AppColors.brass, width: 1.5);
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.background;
        }
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
          return AppColors.brass;
        }
        return AppColors.background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey;
        }
        if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
          return AppColors.background;
        }
        return AppColors.brass;
      }),
    );
  }

  /// Hairline border/ink text on paper. Secondary action alongside a
  /// brassOutline primary (e.g. Add to Cart next to Buy Now).
  static ButtonStyle inkOutline({EdgeInsetsGeometry? padding}) {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      padding: WidgetStatePropertyAll(
        padding ?? const EdgeInsets.symmetric(vertical: 12),
      ),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const BorderSide(color: AppColors.grey, width: 1.5);
        }
        return const BorderSide(color: AppColors.border, width: 1.5);
      }),
      backgroundColor: const WidgetStatePropertyAll(AppColors.background),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.grey;
        }
        return AppColors.foreground;
      }),
    );
  }
}
