import 'package:flutter/material.dart';

import 'package:better_life_app/core/theme/bl_tokens.dart';

/// Brand wordmark: "Better" in lavender-500 + "Life" in lavender-200.
///
/// Used on the Splash screen below the animated logo.
/// The two-tone effect is achieved with a [RichText] and two [TextSpan]s.
class BLWordmark extends StatelessWidget {
  const BLWordmark({
    super.key,
    this.fontSize = 28.0,
  });

  /// Font size for both text segments. Defaults to 28px (splash usage).
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: BLType.family,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -0.02 * fontSize,
        ),
        children: const [
          TextSpan(
            text: 'Better',
            style: TextStyle(color: BLColors.lavender500),
          ),
          TextSpan(
            text: 'Life',
            style: TextStyle(color: BLColors.lavender200),
          ),
        ],
      ),
    );
  }
}
