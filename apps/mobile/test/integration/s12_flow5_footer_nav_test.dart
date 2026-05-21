/// S12 — Flow 5: Footer navigation Login ↔ SignUp (pure router test, no HTTP)
///
/// From /login, taps "Regístrate" → lands on /register.
/// From /register, taps "Inicia sesión" → lands back on /login.
library;

import 'package:flutter_test/flutter_test.dart';

import '_harness.dart';

void main() {
  group('Flow 5 — footer nav Login ↔ SignUp', () {
    testWidgets(
      'from /login, tap "Regístrate" → lands on /register (SignUp screen)',
      (tester) async {
        final harness = IntegrationHarness();

        await tester.pumpWidget(harness.build());
        await pumpPastSplash(tester);

        // On /login.
        expect(find.text('Bienvenido de vuelta'), findsOneWidget);

        // Ensure footer link is visible (it's inside a SingleChildScrollView).
        await tester.ensureVisible(find.text('Regístrate'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Regístrate'));
        await tester.pumpAndSettle();

        // Now on /register.
        expect(find.text('Crea tu cuenta'), findsOneWidget);
      },
    );

    testWidgets(
      'from /register, tap "Inicia sesión" → lands on /login',
      (tester) async {
        final harness = IntegrationHarness();

        await tester.pumpWidget(harness.build());
        await pumpPastSplash(tester);

        // Navigate to /register first.
        await tester.ensureVisible(find.text('Regístrate'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Regístrate'));
        await tester.pumpAndSettle();

        expect(find.text('Crea tu cuenta'), findsOneWidget);

        // Now tap "Inicia sesión" footer on SignUp screen.
        await tester.ensureVisible(find.text('Inicia sesión'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Inicia sesión'));
        await tester.pumpAndSettle();

        // Back on /login.
        expect(find.text('Bienvenido de vuelta'), findsOneWidget);
      },
    );
  });
}
