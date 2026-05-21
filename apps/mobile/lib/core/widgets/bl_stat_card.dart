import 'package:flutter/material.dart';

import 'package:better_life_app/core/theme/bl_tokens.dart';

/// Reusable stat card displaying an icon, label, and numeric value.
///
/// Used by the Dashboard screen to show habit-completion statistics.
class BLStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const BLStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BLColors.lightSurface,
        borderRadius: BorderRadius.circular(BLRadius.field),
        border: Border.all(color: BLColors.lightBorder),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: BLColors.lavender400,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: BLType.label.copyWith(
                    color: BLColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: BLType.h1.copyWith(
                    color: BLColors.lightText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}