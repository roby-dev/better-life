import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/widgets/bl_strength_meter.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BLStrengthMeter', () {
    testWidgets('score 0 — no label shown', (tester) async {
      await tester.pumpWidget(_wrap(const BLStrengthMeter(strength: 0)));
      expect(find.text('Débil'), findsNothing);
      expect(find.text('Aceptable'), findsNothing);
    });

    testWidgets('score 1 — shows Débil', (tester) async {
      await tester.pumpWidget(_wrap(const BLStrengthMeter(strength: 1)));
      expect(find.text('Débil'), findsOneWidget);
    });

    testWidgets('score 2 — shows Aceptable', (tester) async {
      await tester.pumpWidget(_wrap(const BLStrengthMeter(strength: 2)));
      expect(find.text('Aceptable'), findsOneWidget);
    });

    testWidgets('score 3 — shows Buena', (tester) async {
      await tester.pumpWidget(_wrap(const BLStrengthMeter(strength: 3)));
      expect(find.text('Buena'), findsOneWidget);
    });

    testWidgets('score 4 — shows Excelente', (tester) async {
      await tester.pumpWidget(_wrap(const BLStrengthMeter(strength: 4)));
      expect(find.text('Excelente'), findsOneWidget);
    });

    testWidgets('renders exactly 4 bar segments', (tester) async {
      await tester.pumpWidget(_wrap(const BLStrengthMeter(strength: 2)));
      // Each bar is identified by a key 'bar_N'
      expect(find.byKey(const Key('bar_0')), findsOneWidget);
      expect(find.byKey(const Key('bar_1')), findsOneWidget);
      expect(find.byKey(const Key('bar_2')), findsOneWidget);
      expect(find.byKey(const Key('bar_3')), findsOneWidget);
    });
  });
}
