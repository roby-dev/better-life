/// S12 — Flow 2: Login happy path → /home/habits
///
/// Mocks a 200 from /api/auth/login. Fills email + password on the
/// Login screen, taps CTA, and asserts the HomeShell Habits tab is visible.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_harness.dart';

void main() {
  testWidgets(
    'Flow 2 — login happy path: valid creds + mock 200 → HomeShell Habits tab',
    (tester) async {
      // Arrange
      final harness = IntegrationHarness();
      harness.mockLoginSuccess();

      await tester.pumpWidget(harness.build());
      await pumpPastSplash(tester);

      // Confirm we're on login screen.
      expect(find.text('Bienvenido de vuelta'), findsOneWidget);

      // Fill credentials via the inner TextField (BLTextField wraps it).
      // find.byKey targets the BLTextField wrapper; enterText descends to
      // the EditableText and calls onChanged which updates loginFormProvider.
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('login_email_field')),
          matching: find.byType(TextField),
        ),
        'user@example.com',
      );
      await tester.pump();

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('login_password_field')),
          matching: find.byType(TextField),
        ),
        'password123',
      );
      await tester.pump();

      // Allow provider state to settle before tapping.
      await tester.pumpAndSettle();

      // Tap the FilledButton CTA (the button is enabled when form is valid).
      // Use warnIfMissed: false because a disabled button still receives the tap
      // call but it's a no-op; we verify the outcome by the navigation result.
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Assert: on HomeShell — Habits tab visible.
      expect(find.text('Mis Hábitos'), findsOneWidget);
    },
  );
}
