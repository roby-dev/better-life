import 'package:flutter/material.dart';

import 'package:better_life_app/core/theme/bl_tokens.dart';
import 'package:better_life_app/features/auth/domain/validators.dart';

/// Displays 4 strength-meter bars + a text label.
///
/// [strength] is the raw score from [strengthOf] (0–4). The caller
/// is responsible for computing it — this widget is purely presentational.
///
/// Bar color rules (from design handoff):
/// - Score 1 (Débil):      bar 1 → [BLColors.danger]   (#E26B7C)
/// - Score 2 (Aceptable):  bars 1–2 → [BLColors.warning] (#D9A95B)
/// - Score 3 (Buena):      bars 1–3 → [BLColors.lavender300]
/// - Score 4 (Excelente):  bars 1–4 → [BLColors.lightPrimaryBg]
///
/// Inactive bars use the light track colour.
class BLStrengthMeter extends StatelessWidget {
  const BLStrengthMeter({
    super.key,
    required this.strength,
  });

  /// Strength score 0–4, typically from [strengthOf].
  final int strength;

  static const _activeColors = [
    BLColors.danger,         // score 1 — Débil
    BLColors.warning,        // score 2 — Aceptable
    BLColors.lavender300,    // score 3 — Buena
    BLColors.lightPrimaryBg, // score 4 — Excelente
  ];

  Color get _activeColor =>
      strength > 0 ? _activeColors[strength - 1] : BLColors.lightTrack;

  String get _label =>
      strength > 0 && strength <= strengthLabels.length - 1
          ? strengthLabels[strength]
          : '';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── 4 bars ──────────────────────────────────────────────────────
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              final active = i < strength;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 4.0 : 0),
                  child: Container(
                    key: Key('bar_$i'),
                    height: 3,
                    decoration: BoxDecoration(
                      color: active ? _activeColor : BLColors.lightTrack,
                      borderRadius: BorderRadius.circular(BLRadius.pill),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        // ── Label ────────────────────────────────────────────────────────
        SizedBox(
          width: 64,
          child: Text(
            _label,
            textAlign: TextAlign.right,
            style: BLType.label.copyWith(
              fontSize: 11,
              letterSpacing: 0.04 * 11,
              color: strength > 0 ? _activeColor : BLColors.lightTextMuted,
            ),
          ),
        ),
      ],
    );
  }
}
