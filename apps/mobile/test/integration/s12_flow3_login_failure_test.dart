/// S12 — Flow 3: Login failure (401) → inline error, router stays on /login
///
/// Mocks a 401 from /api/auth/login. Fills credentials, taps CTA, and asserts
/// the AuthFailure title surfaces as an inline error. Router stays on /login.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_harness.dart';

void main() {
  testWidgets(
    'Flow 3 — login failure: mock 401 → inline error shown, stays on /login',
    (tester) async {
      // Arrange
      final harness = IntegrationHarness();
      harness.mockLoginFailure(401, 'Credenciales inválidas');

      await tester.pumpWidget(harness.build());
      await pumpPastSplash(tester);

      // Confirm we're on login screen.
      expect(find.text('Bienvenido de vuelta'), findsOneWidget);

      // Fill credentials.
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
        'wrongpassword',
      );
      await tester.pump();

      // Allow provider state to settle before tapping.
      await tester.pumpAndSettle();

      // Tap CTA (FilledButton is enabled once form is valid).
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Assert: inline error from AuthFailure title.
      expect(find.text('Credenciales inválidas'), findsOneWidget);

      // Assert: still on /login — heading still visible.
      expect(find.text('Bienvenido de vuelta'), findsOneWidget);
    },
  );
}
