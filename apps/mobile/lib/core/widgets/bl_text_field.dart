import 'package:flutter/material.dart';

import 'package:better_life_app/core/theme/bl_tokens.dart';

/// A branded text field with label, leading icon, focus/error/valid states,
/// and an optional trailing widget (e.g., eye-toggle button).
///
/// Visual states:
/// - Idle:  10%-opacity lavender border, no shadow.
/// - Focus: lavender400 border + 4-px shadow ring, 180ms ease.
/// - Error: danger border (#E26B7C) always; error message 12px below.
/// - Valid: 20×20 circular badge with white check at trailing end
///          (only when no [trailing] widget is provided).
class BLTextField extends StatefulWidget {
  const BLTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.leadingIcon,
    this.trailing,
    this.onChanged,
    this.errorText,
    this.isValid = false,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final String placeholder;
  final IconData? leadingIcon;

  /// Optional trailing widget (e.g., eye-toggle). When provided the valid
  /// badge is suppressed so both never compete for the same slot.
  final Widget? trailing;

  final ValueChanged<String>? onChanged;

  /// When non-null, the field enters Error state regardless of focus.
  final String? errorText;

  /// When true AND [errorText] is null AND [trailing] is null, the valid
  /// badge (20×20 circle + check) is shown at the trailing end.
  final bool isValid;

  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueSubmitted<String>? onSubmitted;

  @override
  State<BLTextField> createState() => _BLTextFieldState();
}

typedef ValueSubmitted<T> = void Function(T value);

class _BLTextFieldState extends State<BLTextField> {
  late final FocusNode _focus;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() => _focused = _focus.hasFocus);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focus.removeListener(_onFocusChange);
      _focus.dispose();
    }
    super.dispose();
  }

  Color get _borderColor {
    if (widget.errorText != null) return BLColors.danger;
    if (_focused) return BLColors.lightBorderFocus;
    return BLColors.lightBorder;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final showBadge =
        widget.isValid && !hasError && widget.trailing == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ─────────────────────────────────────────────────────────
        Text(
          widget.label.toUpperCase(),
          style: BLType.label.copyWith(color: BLColors.lightTextMuted),
        ),
        const SizedBox(height: 8),
        // ── Field row ─────────────────────────────────────────────────────
        AnimatedContainer(
          duration: BLAnim.fieldFocus,
          curve: Curves.ease,
          decoration: BoxDecoration(
            color: BLColors.lightSurface,
            borderRadius: BorderRadius.circular(BLRadius.field),
            border: Border.all(color: _borderColor, width: 1.5),
            boxShadow: _focused && !hasError
                ? [
                    BoxShadow(
                      color: BLColors.lightBorderFocus.withValues(alpha: 0.06),
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Leading icon
              if (widget.leadingIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 8),
                  child: Icon(
                    widget.leadingIcon,
                    size: 18,
                    color: _focused
                        ? BLColors.lightIconFocus
                        : BLColors.lightIconIdle,
                  ),
                )
              else
                const SizedBox(width: 14),
              // Input
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  onChanged: widget.onChanged,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  style: BLType.field.copyWith(color: BLColors.lightText),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: BLType.field.copyWith(
                      color: BLColors.lightTextFaint,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              // Trailing (eye-toggle) or valid badge
              if (widget.trailing != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: widget.trailing,
                )
              else if (showBadge)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: _ValidBadge(),
                )
              else
                const SizedBox(width: 14),
            ],
          ),
        ),
        // ── Error text ────────────────────────────────────────────────────
        SizedBox(
          height: 18,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.errorText!,
                    style: BLType.caption.copyWith(
                      fontSize: 12,
                      color: BLColors.danger,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

class _ValidBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: BLColors.lightPrimaryBg,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 12,
        color: BLColors.lightPrimaryFg,
      ),
    );
  }
}
