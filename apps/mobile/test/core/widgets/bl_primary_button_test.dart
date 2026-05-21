import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/widgets/bl_primary_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BLPrimaryButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(
        BLPrimaryButton(label: 'Iniciar sesión', onPressed: () {}),
      ));
      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('triggers onPressed when enabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        BLPrimaryButton(label: 'Tap me', onPressed: () => tapped = true),
      ));
      await tester.tap(find.byType(FilledButton));
      expect(tapped, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const BLPrimaryButton(label: 'Disabled'),
      ));
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true', (tester) async {
      await tester.pumpWidget(_wrap(
        const BLPrimaryButton(label: 'Loading', isLoading: true),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('is disabled when isLoading is true', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        BLPrimaryButton(
          label: 'Loading',
          isLoading: true,
          onPressed: () => tapped = true,
        ),
      ));
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNull);
      expect(tapped, isFalse);
    });
  });
}
