/// S12 — Flow 7: Logout from Profile tab → back to /login
///
/// Pre-seeds token storage so the app boots directly into HomeShell.
/// Navigates to the Profile tab, taps "Cerrar sesión", and asserts the
/// router redirects to /login.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_harness.dart';

void main() {
  testWidgets(
    'Flow 7 — logout from Profile tab: tap logout → router redirects to /login',
    (tester) async {
      // Arrange: pre-seed token so we boot into HomeShell.
      final harness = IntegrationHarness();
      await harness.tokenStorage.write(IntegrationHarness.accessToken);

      await tester.pumpWidget(harness.build());
      await pumpPastSplash(tester);

      // Confirm on HomeShell Habits tab.
      expect(find.text('Mis Hábitos'), findsOneWidget);

      // Navigate to Profile tab (index 2).
      await tester.tap(find.text('Perfil'));
      await tester.pump();

      // Confirm Profile tab is active.
      expect(find.text('Mi Perfil'), findsOneWidget);

      // Tap logout.
      await tester.tap(find.byKey(const Key('profile_logout_button')));
      await tester.pumpAndSettle();

      // Assert: router redirected to /login.
      expect(find.text('Bienvenido de vuelta'), findsOneWidget);

      // Assert: HomeShell no longer in tree.
      expect(find.text('Mis Hábitos'), findsNothing);
    },
  );
}
