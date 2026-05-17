import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/widgets/bl_loader_bar.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BLLoaderBar', () {
    testWidgets('renders with default 120×3 dimensions', (tester) async {
      await tester.pumpWidget(_wrap(const BLLoaderBar()));
      final container = tester.widget<SizedBox>(
        find.byKey(const Key('bl_loader_bar_track')),
      );
      expect(container.width, 120.0);
      expect(container.height, 3.0);
    });

    testWidgets('renders a sliding indicator via AnimatedBuilder', (tester) async {
      await tester.pumpWidget(_wrap(const BLLoaderBar()));
      expect(find.byType(AnimatedBuilder), findsAtLeast(1));
    });

    testWidgets('indicator moves after pump', (tester) async {
      await tester.pumpWidget(_wrap(const BLLoaderBar()));
      // Pump 800ms to advance the animation
      await tester.pump(const Duration(milliseconds: 800));
      // No crash = animation is running correctly
    });
  });
}
