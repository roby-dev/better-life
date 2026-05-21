import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/widgets/bl_back_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BLBackButton', () {
    testWidgets('is exactly 40×40', (tester) async {
      await tester.pumpWidget(_wrap(const BLBackButton()));
      final size = tester.getSize(find.byType(BLBackButton));
      expect(size.width, 40.0);
      expect(size.height, 40.0);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        BLBackButton(onPressed: () => tapped = true),
      ));
      await tester.tap(find.byType(BLBackButton));
      expect(tapped, isTrue);
    });

    testWidgets('renders a back chevron icon', (tester) async {
      await tester.pumpWidget(_wrap(const BLBackButton()));
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    });
  });
}
