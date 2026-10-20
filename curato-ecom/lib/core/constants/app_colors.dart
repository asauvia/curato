import 'package:flutter/material.dart';

class AppColors {
  // Web palette (warm paper, light theme only). Tokens match Asauvia's globals.css.
  static const Color background = Color(0xFFFAFAF9);        // Page background (warm paper)
  static const Color foreground = Color(0xFF0C0806);        // Primary text, primary button fill
  static const Color muted = Color(0xFFF1F0ED);             // Raised panels
  static const Color mutedForeground = Color(0xFF5C534D);   // Secondary text
  static const Color border = Color(0xFFDCDBD6);            // Hairlines (used instead of card shadows)
  static const Color signal = Color(0xFF2C965D);            // Live/status indicator and success accents only

  // Legacy names, kept so existing widgets compile. They now resolve to the palette above.
  static const Color creamBg = background;
  static const Color maroonFestive = foreground;
  static const Color brightRedAccent = foreground;
  static const Color goldAccent = foreground;
  static const Color silver = border;
  static const Color charcoal = foreground;
  static const Color cardBgBeige = muted;
  static const Color cardBorderTint = border;
  static const Color headerFooterBg = background;

  static const Color primaryIndigo1 = foreground;

  static const Color primaryIndigo = foreground;
  static const Color primaryBlue = foreground;
  static const Color mrpBrown = mutedForeground;
  static const Color accentOrange = foreground;
  static const Color accentOrangeHover = mutedForeground;
  static const Color primaryPink = foreground;

  // Backgrounds
  static const Color bgPrimaryLight = background;
  static const Color bgSecondaryLight = muted;
  static const Color bgPrimaryDark = foreground;

  // Text
  static const Color textPrimary = foreground;
  static const Color textSecondary = mutedForeground;
  static const Color textOnPrimary = background;

  // Borders
  static const Color borderLight = border;
  static const Color borderHover = mutedForeground;

  // Gradients (flat on the warm palette)
  static const LinearGradient initialGradient = LinearGradient(
    colors: [foreground, mutedForeground],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient indigoBlueGradient = LinearGradient(
    colors: [foreground, foreground],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [foreground, mutedForeground],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy Compatibility (Required for existing Auth/Shell screens)
  static const Color accentPink = primaryPink;
  static const Color blackDark = foreground;
  static const Color navyDark = foreground;
  static const Color midnightIndigo = foreground;
  static const Color accentYellow = Color(0xffffd600);
  static const Color borderDark = border;
  static const Color inputBgDark = muted;
  static const Color bgSecondaryDark = muted;
  static const Color textPrimaryDark = foreground;
  static const Color textSecondaryDark = mutedForeground;

  static const RadialGradient bgRadialGradient = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.5,
    colors: [background, muted],
  );

  static const LinearGradient darkNavbarGradient = LinearGradient(
    colors: [background, muted],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [foreground, mutedForeground],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  static const MaterialColor successGreen = Colors.green;
  static const MaterialColor errorRed = Colors.red;

  // Warm neutral swatch (replaces Material's cool grey)
  static const MaterialColor grey = MaterialColor(0xFF5C534D, <int, Color>{
    50: Color(0xFFFAFAF9),
    100: Color(0xFFF1F0ED),
    200: Color(0xFFE8E7E3),
    300: Color(0xFFDCDBD6),
    400: Color(0xFFB3AEA8),
    500: Color(0xFF8C857E),
    600: Color(0xFF5C534D),
    700: Color(0xFF443D38),
    800: Color(0xFF2A2420),
    900: Color(0xFF0C0806),
  });

  // Shades
  static const Color grey50 = Color(0xFFFAFAF9);
  static const Color grey100 = Color(0xFFF1F0ED);
  static const Color grey200 = Color(0xFFE8E7E3);
  static const Color grey300 = Color(0xFFDCDBD6);
  static const Color grey400 = Color(0xFFB3AEA8);
  static const Color grey500 = Color(0xFF8C857E);
  static const Color grey600 = Color(0xFF5C534D);
  static const Color grey700 = Color(0xFF443D38);
  static const Color grey800 = Color(0xFF2A2420);
  static const Color grey900 = Color(0xFF0C0806);

  static const Color red50 = Color(0xFFFFEBEE);
  static const Color red100 = Color(0xFFFFCDD2);
  static const Color red200 = Color(0xFFEF9A9A);
  static const Color red300 = Color(0xFFE57373);
  static const Color red400 = Color(0xFFEF5350);
  static const Color red500 = Color(0xFFF44336);
  static const Color red600 = Color(0xFFE53935);
  static const Color red700 = Color(0xFFD32F2F);
  static const Color red800 = Color(0xFFC62828);
  static const Color red900 = Color(0xFFB71C1C);

  static const Color green50 = Color(0xFFE8F5E9);
  static const Color green100 = Color(0xFFC8E6C9);
  static const Color green200 = Color(0xFFA5D6A7);
  static const Color green300 = Color(0xFF81C784);
  static const Color green400 = Color(0xFF66BB6A);
  static const Color green500 = Color(0xFF4CAF50);
  static const Color green600 = Color(0xFF43A047);
  static const Color green700 = Color(0xFF388E3C);
  static const Color green800 = Color(0xFF2E7D32);
  static const Color green900 = Color(0xFF1B5E20);

  // Info/blue shades now map to the warm palette
  static const Color blue50 = Color(0xFFF1F0ED);
  static const Color blue100 = Color(0xFFDCDBD6);
  static const Color blue200 = Color(0xFFDCDBD6);
  static const Color blue300 = Color(0xFF8C857E);
  static const Color blue400 = Color(0xFF5C534D);
  static const Color blue500 = Color(0xFF0C0806);
  static const Color blue600 = Color(0xFF0C0806);
  static const Color blue700 = Color(0xFF0C0806);
  static const Color blue800 = Color(0xFF0C0806);
  static const Color blue900 = Color(0xFF0C0806);

  // Opacity Constants
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  static const Color white38 = Color(0x62FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white12 = Color(0x1FFFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);

  static const Color black87 = Color(0xDE000000);
  static const Color black54 = Color(0x8A000000);
  static const Color black45 = Color(0x73000000);
  static const Color black38 = Color(0x62000000);
  static const Color black26 = Color(0x42000000);
  static const Color black12 = Color(0x1F000000);
}
