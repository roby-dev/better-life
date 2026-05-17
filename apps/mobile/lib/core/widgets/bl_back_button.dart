import 'package:flutter/material.dart';

import 'package:better_life_app/core/theme/bl_tokens.dart';

/// 40×40 rounded back-navigation button.
///
/// When [onPressed] is null it calls `Navigator.maybePop(context)`.
class BLBackButton extends StatelessWidget {
  const BLBackButton({
    super.key,
    this.onPressed,
  });

  /// Custom callback. If null, falls back to `Navigator.maybePop`.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.maybePop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: BLColors.lightPrimaryBg.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(BLRadius.iconButton),
          border: Border.all(
            color: BLColors.lightBorder,
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.chevron_left_rounded,
          size: 22,
          color: BLColors.lightIconFocus,
        ),
      ),
    );
  }
}
