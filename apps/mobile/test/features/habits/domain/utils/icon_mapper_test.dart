import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/features/habits/domain/utils/icon_mapper.dart';

void main() {
  group('iconFromName', () {
    test('maps heart to favorite', () {
      expect(iconFromName('heart'), Icons.favorite);
    });

    test('maps book to book', () {
      expect(iconFromName('book'), Icons.book);
    });

    test('maps briefcase to work', () {
      expect(iconFromName('briefcase'), Icons.work);
    });

    test('maps wallet to account_balance_wallet', () {
      expect(iconFromName('wallet'), Icons.account_balance_wallet);
    });

    test('maps users to people', () {
      expect(iconFromName('users'), Icons.people);
    });

    test('maps sparkle to auto_awesome', () {
      expect(iconFromName('sparkle'), Icons.auto_awesome);
    });

    test('maps bolt to bolt', () {
      expect(iconFromName('bolt'), Icons.bolt);
    });

    test('maps tag to label', () {
      expect(iconFromName('tag'), Icons.label);
    });

    test('returns label fallback for unknown names', () {
      expect(iconFromName('unknown'), Icons.label);
      expect(iconFromName(''), Icons.label);
    });
  });
}
