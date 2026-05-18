/// S12 — Flow 1: Cold start unauthenticated → Splash → /login
///
/// No token in storage. After the splash gate (≥2500ms), the router
/// must land on the Login screen. Asserts "Iniciar sesión" heading is visible.
library;

import 'package:flutter_test/flutter_test.dart';

import '_harness.dart';

void main() {
  testWidgets(
    'Flow 1 — cold start unauthenticated: splash → /login shows login screen',
    (tester) async {
      // Arrange: empty storage (default).
      final harness = IntegrationHarness();

      // Act
      await tester.pumpWidget(harness.build());
      await pumpPastSplash(tester);

      // Assert: landed on /login — heading visible.
      expect(find.text('Iniciar sesión'), findsWidgets);
      expect(find.text('Bienvenido de vuelta'), findsOneWidget);
    },
  );
}
