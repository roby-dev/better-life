import 'package:flutter/material.dart';

/// Maps backend icon name strings to Flutter [IconData].
///
/// Returns [Icons.label] for any unrecognized name.
IconData iconFromName(String name) {
  return switch (name) {
    'heart' => Icons.favorite,
    'book' => Icons.book,
    'briefcase' => Icons.work,
    'wallet' => Icons.account_balance_wallet,
    'users' => Icons.people,
    'sparkle' => Icons.auto_awesome,
    'bolt' => Icons.bolt,
    'tag' => Icons.label,
    _ => Icons.label,
  };
}
