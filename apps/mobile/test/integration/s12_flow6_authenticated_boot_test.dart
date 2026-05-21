/// S12 — Flow 6: Authenticated boot → /home/habits (no /login flash)
///
/// Pre-seeds [InMemoryTokenStorage] with a valid token before the app boots.
/// After the splash gate, the router must land on HomeShell (Habits tab),
/// bypassing /login entirely. Verifies the AuthNotifier.bootstrap() path.
library;

import 'package:flutter_test/flutter_test.dart';

import '_harness.dart';

void main() {
  testWidgets(
    'Flow 6 — authenticated boot: pre-seeded token → splash → /home/habits',
    (tester) async {
      // Arrange: pre-seed the token storage before the app boots.
      final harness = IntegrationHarness();
      await harness.tokenStorage.write(IntegrationHarness.accessToken);

      // Act
      await tester.pumpWidget(harness.build());
      await pumpPastSplash(tester);

      // Assert: landed on HomeShell — Habits tab visible.
      expect(find.text('Mis Hábitos'), findsOneWidget);

      // Assert: did NOT land on login screen.
      expect(find.text('Bienvenido de vuelta'), findsNothing);
    },
  );
}
