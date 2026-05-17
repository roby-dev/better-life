import 'package:flutter/material.dart';

import 'package:better_life_app/core/theme/bl_tokens.dart';

/// Full-width primary CTA button (54px height).
///
/// - Disabled state: 18%-opacity fill, muted label.
/// - Loading state: disables tap, shows 18px [CircularProgressIndicator].
class BLPrimaryButton extends StatelessWidget {
  const BLPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;

  /// Callback. When null OR [isLoading] is true the button is disabled.
  final VoidCallback? onPressed;

  /// When true, the label is replaced by an 18px [CircularProgressIndicator]
  /// and the button is disabled.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveCallback = (isLoading || onPressed == null) ? null : onPressed;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: effectiveCallback,
        style: FilledButton.styleFrom(
          backgroundColor: BLColors.lightPrimaryBg,
          disabledBackgroundColor: BLColors.lightPrimaryBgDisabled,
          foregroundColor: BLColors.lightPrimaryFg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BLRadius.button),
          ),
          textStyle: BLType.button,
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    BLColors.lightPrimaryFg,
                  ),
                ),
              )
            : Text(label),
      ),
    );
  }
}
