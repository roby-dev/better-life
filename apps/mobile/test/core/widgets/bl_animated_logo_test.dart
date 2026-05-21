import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/widgets/bl_animated_logo.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('BLAnimatedLogo', () {
    // ────────────────────────────────────────────────────────────────
    // T-S7-01  Widget renders and has correct default dimensions
    // ────────────────────────────────────────────────────────────────
    testWidgets('renders at default 170×170 size', (tester) async {
      await tester.pumpWidget(_wrap(const BLAnimatedLogo()));
      final box = tester.widget<SizedBox>(
        find.byKey(const Key('bl_animated_logo_root')),
      );
      expect(box.width, 170.0);
      expect(box.height, 170.0);
    });

    testWidgets('accepts custom size', (tester) async {
      await tester.pumpWidget(_wrap(const BLAnimatedLogo(size: 100.0)));
      final box = tester.widget<SizedBox>(
        find.byKey(const Key('bl_animated_logo_root')),
      );
      expect(box.width, 100.0);
      expect(box.height, 100.0);
    });

    // ────────────────────────────────────────────────────────────────
    // T-S7-02  Logo starts invisible (opacity 0 at t=0)
    // ────────────────────────────────────────────────────────────────
    testWidgets('logo entry starts at opacity 0', (tester) async {
      await tester.pumpWidget(_wrap(const BLAnimatedLogo()));
      // At t=0, the entry FadeTransition should be at value 0.
      final fade = tester.widgetList<FadeTransition>(
        find.byKey(const Key('bl_logo_entry_fade')),
      );
      expect(fade.isNotEmpty, isTrue);
      for (final f in fade) {
        expect(f.opacity.value, closeTo(0.0, 0.01));
      }
    });

    // ────────────────────────────────────────────────────────────────
    // T-S7-03  Logo is fully visible at t=1100ms
    // ────────────────────────────────────────────────────────────────
    testWidgets('logo entry reaches opacity 1 at 1100ms', (tester) async {
      await tester.pumpWidget(_wrap(const BLAnimatedLogo()));
      await tester.pump(const Duration(milliseconds: 1100));
      final fade = tester.widget<FadeTransition>(
        find.byKey(const Key('bl_logo_entry_fade')),
      );
      expect(fade.opacity.value, closeTo(1.0, 0.05));
    });

    // ────────────────────────────────────────────────────────────────
    // T-S7-04  Check stroke painter exists and progresses
    //          At t=0 → progress≈0; at t=400+700=1100ms → progress≈1
    // ────────────────────────────────────────────────────────────────
    testWidgets('check stroke painter is in the tree', (tester) async {
      await tester.pumpWidget(_wrap(const BLAnimatedLogo()));
      expect(
        find.byKey(const Key('bl_check_painter')),
        findsOneWidget,
      );
    });

    testWidgets('check painter progress is 0 at t=0', (tester) async {
      await tester.pumpWidget(_wrap(const BLAnimatedLogo()));
      final repaint = tester.widget<CustomPaint>(
        find.byKey(const Key('bl_check_painter')),
      );
      final painter = repaint.painter as BLCheckPainter;
      expect(painter.progress, closeTo(0.0, 0.01));
    });

    testWidgets('check painter progress advances after 400ms+700ms', (tester) async {
      await tester.pumpWidget(_wrap(const BLAnimatedLogo()));
      // Delay fires at 400ms, then animation runs 700ms
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 700));
      final repaint = tester.widget<CustomPaint>(
        find.byKey(const Key('bl_check_painter')),
      );
      final painter = repaint.painter as BLCheckPainter;
      expect(painter.progress, greaterThan(0.5));
    });

    // ────────────────────────────────────────────────────────────────
    // T-S7-05  Three halo rings present
    // ────────────────────────────────────────────────────────────────
    testWidgets('renders 3 halo ring widgets', (tester) async {
      await tester.pumpWidget(_wrap(const BLAnimatedLogo()));
      expect(find.byKey(const Key('bl_halo_0')), findsOneWidget);
      expect(find.byKey(const Key('bl_halo_1')), findsOneWidget);
      expect(find.byKey(const Key('bl_halo_2')), findsOneWidget);
    });

    // ────────────────────────────────────────────────────────────────
    // T-S7-06  Ten particle widgets present
    // ────────────────────────────────────────────────────────────────
    testWidgets('renders 10 particle widgets', (tester) async {
      await tester.pumpWidget(_wrap(const BLAnimatedLogo()));
      for (var i = 0; i < 10; i++) {
        expect(find.byKey(Key('bl_particle_$i')), findsOneWidget);
      }
    });

    // ────────────────────────────────────────────────────────────────
    // T-S7-07  Animations advance without crash (no pumpAndSettle)
    // ────────────────────────────────────────────────────────────────
    testWidgets('advancing to 2500ms does not crash', (tester) async {
      await tester.pumpWidget(_wrap(const BLAnimatedLogo()));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 400)); // total 1500ms
      await tester.pump(const Duration(milliseconds: 1000)); // total 2500ms
    });

    // ────────────────────────────────────────────────────────────────
    // T-S7-08  Dispose counter — controllers disposed on widget removal
    // ────────────────────────────────────────────────────────────────
    testWidgets('disposes without error when widget is removed', (tester) async {
      await tester.pumpWidget(_wrap(const BLAnimatedLogo()));
      await tester.pump(const Duration(milliseconds: 600));
      // Replace with an empty widget to trigger dispose()
      await tester.pumpWidget(_wrap(const SizedBox.shrink()));
      // No exception = dispose was clean.
    });

    // ────────────────────────────────────────────────────────────────
    // T-S7-09  BLCheckPainter shouldRepaint behaves correctly
    // ────────────────────────────────────────────────────────────────
    test('BLCheckPainter.shouldRepaint returns true when progress changes', () {
      final a = BLCheckPainter(progress: 0.0, size: 170.0);
      final b = BLCheckPainter(progress: 0.5, size: 170.0);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('BLCheckPainter.shouldRepaint returns false when progress is same', () {
      final a = BLCheckPainter(progress: 0.5, size: 170.0);
      final b = BLCheckPainter(progress: 0.5, size: 170.0);
      expect(a.shouldRepaint(b), isFalse);
    });

    // ────────────────────────────────────────────────────────────────
    // T-S7-10  AnimatedBuilder present (drives animations)
    // ────────────────────────────────────────────────────────────────
    testWidgets('widget contains AnimatedBuilder nodes', (tester) async {
      await tester.pumpWidget(_wrap(const BLAnimatedLogo()));
      expect(find.byType(AnimatedBuilder), findsAtLeast(1));
    });
  });
}
