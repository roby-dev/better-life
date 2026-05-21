import 'package:flutter/material.dart';

import 'bl_tokens.dart';

const _lightScheme = ColorScheme(
  brightness: Brightness.light,
  // CTA fill, headings color (matches handoff lightPrimaryBg)
  primary: BLColors.lavender500, // #434352
  onPrimary: Color(0xFFFFFFFF), // lightPrimaryFg
  primaryContainer: BLColors.lavender100, // #C6C6F0 — soft chips
  onPrimaryContainer: BLColors.lavender500,
  // Focus/border emphasis (matches handoff lightBorderFocus / iconFocus)
  secondary: BLColors.lavender400, // #64647A
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: BLColors.lavender200, // #A7A7CC
  onSecondaryContainer: BLColors.lavender500,
  tertiary: BLColors.lavender300, // #8686A3
  onTertiary: Color(0xFFFFFFFF),
  error: BLColors.danger, // #E26B7C
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFADCE1),
  onErrorContainer: BLColors.lavender500,
  surface: Color(0xFFFFFFFF), // lightSurface / lightBgTop
  onSurface: BLColors.lavender500, // #434352 — body text LOCKED
  surfaceContainerHighest: Color(0xFFF4F2F8), // lightBgBottom
  onSurfaceVariant: BLColors.lavender400,
  outline: BLColors.lavender200, // borders default
  outlineVariant: Color(0x1A434352), // lightBorder (10% lavender500)
  surfaceTint: BLColors.lavender500,
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: BLColors.lavender500,
  onInverseSurface: Color(0xFFFFFFFF),
  inversePrimary: BLColors.lavender100,
);

class BLTheme {
  const BLTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightScheme,
      scaffoldBackgroundColor: BLColors.lightBgTop,
      fontFamily: BLType.family,
      textTheme: const TextTheme(
        displayLarge: BLType.h1,
        bodyMedium: BLType.body,
        labelLarge: BLType.button,
        labelMedium: BLType.label,
        labelSmall: BLType.tagline,
        bodySmall: BLType.caption,
      ).apply(
        bodyColor: BLColors.lightText,
        displayColor: BLColors.lightText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BLColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLRadius.field),
          borderSide: const BorderSide(color: Color(0x1A434352)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLRadius.field),
          borderSide: const BorderSide(
            color: BLColors.lightBorderFocus,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLRadius.field),
          borderSide: const BorderSide(color: BLColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BLRadius.field),
          borderSide: const BorderSide(color: BLColors.danger, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BLColors.lightPrimaryBg,
          foregroundColor: BLColors.lightPrimaryFg,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BLRadius.button),
          ),
          textStyle: BLType.button,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: BLColors.lightText,
        elevation: 0,
      ),
    );
  }
}
