import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Mini brand logo rendered from the SVG asset.
///
/// Defaults to 32×32 (per design handoff for screen header rows).
class BLMiniLogo extends StatelessWidget {
  const BLMiniLogo({
    super.key,
    this.size = 32.0,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/betterlife_logo.svg',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
