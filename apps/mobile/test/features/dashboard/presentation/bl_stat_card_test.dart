import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/widgets/bl_stat_card.dart';

void main() {
  group('BLStatCard', () {
    testWidgets('renders icon, label, and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BLStatCard(
              icon: Icons.check_circle,
              label: 'Total de hábitos',
              value: '5',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('TOTAL DE HÁBITOS'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('displays value with arbitrary string content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BLStatCard(
              icon: Icons.trending_up,
              label: 'Tasa de cumplimiento',
              value: '60%',
            ),
          ),
        ),
      );

      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('renders correctly with different icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BLStatCard(
              icon: Icons.today,
              label: 'Completados hoy',
              value: '3',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.today), findsOneWidget);
      expect(find.text('COMPLETADOS HOY'), findsOneWidget);
    });
  });
}