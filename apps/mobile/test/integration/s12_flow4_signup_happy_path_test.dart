/// S12 — Flow 4: SignUp happy path → /home/habits
///
/// Navigates from Login footer "Regístrate" to SignUp. Fills name/email/password
/// with valid data, mocks a 201 from /api/v1/auth/register, taps CTA, and asserts
/// HomeShell Habits tab is visible.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_harness.dart';

void main() {
  testWidgets(
    'Flow 4 — signup happy path: from login → register → fill → mock 201 → HomeShell',
    (tester) async {
      // Arrange
      final harness = IntegrationHarness();
      harness.mockRegisterSuccess();

      await tester.pumpWidget(harness.build());
      await pumpPastSplash(tester);

      // Should be on /login.
      expect(find.text('Bienvenido de vuelta'), findsOneWidget);

      // Navigate to /register via footer "Regístrate" link.
      // The link is inside a SingleChildScrollView — ensure it's visible.
      await tester.ensureVisible(find.text('Regístrate'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Regístrate'));
      await tester.pumpAndSettle();

      // Confirm on /register.
      expect(find.text('Crea tu cuenta'), findsOneWidget);

      // Fill name field.
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('signup_name_field')),
          matching: find.byType(TextField),
        ),
        'Ana Test',
      );
      await tester.pump();

      // Fill email field.
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('signup_email_field')),
          matching: find.byType(TextField),
        ),
        'ana@test.com',
      );
      await tester.pump();

      // Fill password with score ≥ 2 (length≥8 + digit → Aceptable).
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('signup_password_field')),
          matching: find.byType(TextField),
        ),
        'password1',
      );
      await tester.pump();

      // Ensure the CTA button is visible and tap it.
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Assert: HomeShell Habits tab visible.
      expect(find.text('Mis Hábitos'), findsOneWidget);
    },
  );
}
