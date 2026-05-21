import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/widgets/bl_wordmark.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BLWordmark', () {
    testWidgets('renders BetterLife text as RichText', (tester) async {
      await tester.pumpWidget(_wrap(const BLWordmark()));
      // The wordmark is "Better" + "Life" in two colours; rendered as RichText.
      expect(find.byType(RichText), findsAtLeast(1));
    });

    testWidgets('contains the word Better in RichText spans', (tester) async {
      await tester.pumpWidget(_wrap(const BLWordmark()));
      // RichText text is not found by find.text; instead inspect the widget.
      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      final fullText = richTexts.map((r) => r.text.toPlainText()).join();
      expect(fullText, contains('Better'));
    });

    testWidgets('contains the word Life in RichText spans', (tester) async {
      await tester.pumpWidget(_wrap(const BLWordmark()));
      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      final fullText = richTexts.map((r) => r.text.toPlainText()).join();
      expect(fullText, contains('Life'));
    });
  });
}
