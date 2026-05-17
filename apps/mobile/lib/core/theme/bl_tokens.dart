// BetterLife — Design tokens for Flutter
// Auto-derived from the HTML prototypes. Use as a starting point; adapt
// to your project's existing ThemeData / brand system if one exists.

import 'package:flutter/material.dart';

class BLColors {
  // Brand lavender ramp (from Adobe Color reference)
  static const lavender100 = Color(0xFFC6C6F0);
  static const lavender200 = Color(0xFFA7A7CC);
  static const lavender300 = Color(0xFF8686A3);
  static const lavender400 = Color(0xFF64647A);
  static const lavender500 = Color(0xFF434352);

  // Semantic
  static const danger  = Color(0xFFE26B7C);
  static const warning = Color(0xFFD9A95B);

  // Light theme
  static const lightBgTop    = Color(0xFFFFFFFF);
  static const lightBgBottom = Color(0xFFF4F2F8);
  static const lightSurface  = Color(0xFFFFFFFF);
  static const lightText     = lavender500;
  static final lightTextMuted = lavender500.withValues(alpha: 0.55);
  static final lightTextFaint = lavender500.withValues(alpha: 0.40);
  static final lightBorder    = lavender500.withValues(alpha: 0.10);
  static const lightBorderFocus = lavender400;
  static final lightIconIdle  = const Color(0xFF64647A).withValues(alpha: 0.55);
  static const lightIconFocus = lavender400;
  static const lightPrimaryBg = lavender500;
  static const lightPrimaryFg = Color(0xFFFFFFFF);
  static final lightPrimaryBgDisabled = lavender500.withValues(alpha: 0.18);
  static final lightTrack     = lavender500.withValues(alpha: 0.08);

  // Dark theme
  static const darkBgTop          = Color(0xFF16151F);
  static const darkBgBottom       = Color(0xFF0E0D16);
  static const darkBgRadialCenter = Color(0xFF1F1E2C);
  static final darkSurface        = Colors.white.withValues(alpha: 0.04);
  static const darkText           = Color(0xFFE6E5F2);
  static final darkTextMuted      = const Color(0xFFE8E7F5).withValues(alpha: 0.55);
  static final darkTextFaint      = const Color(0xFFE8E7F5).withValues(alpha: 0.40);
  static final darkBorder         = lavender100.withValues(alpha: 0.10);
  static const darkBorderFocus    = lavender200;
  static final darkIconIdle       = const Color(0xFFE8E7F5).withValues(alpha: 0.45);
  static const darkIconFocus      = lavender100;
  static const darkPrimaryBg      = lavender100;
  static const darkPrimaryFg      = lavender500;
  static final darkPrimaryBgDisabled = lavender100.withValues(alpha: 0.18);
  static final darkTrack          = lavender100.withValues(alpha: 0.10);
}

class BLRadius {
  static const field      = 14.0;
  static const button     = 14.0;
  static const iconButton = 12.0;
  static const pill       = 999.0;
}

class BLSpacing {
  static const screenX        = 28.0;
  static const screenTop      = 54.0;
  static const screenBottom   = 40.0;
  static const sectionGap     = 28.0;
  static const fieldGap       = 18.0;
  static const formButtonGap  = 28.0;
}

class BLType {
  // Font family: ensure 'PlusJakartaSans' is registered in pubspec.yaml.
  static const family = 'PlusJakartaSans';

  static const TextStyle h1 = TextStyle(
    fontFamily: family,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.9, // 30 * -0.03em
  );

  static const TextStyle body = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.075,
  );

  static const TextStyle field = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.08,
  );

  static const TextStyle button = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.08,
  );

  static const TextStyle label = TextStyle(
    fontFamily: family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.54, // 11 * 0.14em
  );

  static const TextStyle tagline = TextStyle(
    fontFamily: family,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 3.2, // 10 * 0.32em
  );

  static const TextStyle caption = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle link = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.07,
  );
}

class BLAnim {
  static const logoEntry      = Duration(milliseconds: 1100);
  static const checkDraw      = Duration(milliseconds:  700);
  static const checkDelay     = Duration(milliseconds:  400);
  static const wordmarkIn     = Duration(milliseconds:  900);
  static const wordmarkDelay  = Duration(milliseconds:  350);
  static const taglineIn      = Duration(milliseconds:  700);
  static const taglineDelay   = Duration(milliseconds:  650);
  static const particleFloat  = Duration(milliseconds: 2400);
  static const haloPulse      = Duration(milliseconds: 4400);
  static const haloStagger    = Duration(milliseconds: 1100);
  static const loaderSlide    = Duration(milliseconds: 1600);
  static const fieldFocus     = Duration(milliseconds:  180);
  static const buttonHover    = Duration(milliseconds:  140);

  // Easing
  static const Curve emphasized = Cubic(0.2, 0.9, 0.25, 1.0);
  static const Curve check      = Cubic(0.2, 0.7, 0.2,  1.0);
  static const Curve loader     = Cubic(0.4, 0.0, 0.2,  1.0);
}
