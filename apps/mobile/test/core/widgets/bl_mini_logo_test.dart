import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/widgets/bl_mini_logo.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BLMiniLogo', () {
    testWidgets('renders an SvgPicture', (tester) async {
      await tester.pumpWidget(_wrap(const BLMiniLogo()));
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('defaults to 32×32', (tester) async {
      await tester.pumpWidget(_wrap(const BLMiniLogo()));
      final size = tester.getSize(find.byType(BLMiniLogo));
      expect(size.width, 32.0);
      expect(size.height, 32.0);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(_wrap(const BLMiniLogo(size: 48)));
      final size = tester.getSize(find.byType(BLMiniLogo));
      expect(size.width, 48.0);
      expect(size.height, 48.0);
    });
  });
}
