import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/theme/bl_tokens.dart';
import 'package:better_life_app/core/theme/bl_theme.dart';

void main() {
  group('BLTheme.light()', () {
    test('primary color equals BLColors.lavender500', () {
      final theme = BLTheme.light();
      expect(theme.colorScheme.primary, equals(BLColors.lavender500));
    });

    test('onSurface equals BLColors.lavender500', () {
      final theme = BLTheme.light();
      expect(theme.colorScheme.onSurface, equals(BLColors.lavender500));
    });

    test('bodyMedium fontFamily contains PlusJakartaSans', () {
      final theme = BLTheme.light();
      expect(
        theme.textTheme.bodyMedium?.fontFamily,
        contains('PlusJakartaSans'),
      );
    });

    testWidgets('smoke: MaterialApp with BLTheme.light() renders without throwing',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: BLTheme.light(),
          home: const Scaffold(body: Text('hi')),
        ),
      );
      expect(find.text('hi'), findsOneWidget);
    });
  });
}
