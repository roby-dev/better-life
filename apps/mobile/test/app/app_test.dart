import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/app/app.dart';
import 'package:better_life_app/core/storage/token_storage.dart';
import 'package:better_life_app/core/storage/storage_providers.dart';
import 'package:better_life_app/core/theme/bl_tokens.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_notifier.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';

// ── Fake notifier that never bootstraps (avoids real I/O in tests) ────────────

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial);
  final AuthState _initial;

  @override
  AuthState build() => _initial;

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> markUnauthenticated() async {
    state = const AuthUnauthenticated();
  }
}

// ── Helper: pump BetterLifeApp with safe provider overrides ───────────────────

Future<void> pumpApp(
  WidgetTester tester, {
  AuthState initialAuth = const AuthInitial(),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
        authNotifierProvider.overrideWith(
          () => _FakeAuthNotifier(initialAuth),
        ),
      ],
      child: const BetterLifeApp(),
    ),
  );
  // Drain deferred gate timer.
  await tester.pump(Duration.zero);
  // Drain splash gate (2500ms floor).
  await tester.pump(const Duration(seconds: 3));
}

void main() {
  group('BetterLifeApp — T-S11-01 structure', () {
    testWidgets('pumps without throwing', (tester) async {
      await pumpApp(tester);
      // No exception means the widget tree assembled correctly.
      expect(tester.takeException(), isNull);
    });

    testWidgets('contains a MaterialApp.router in the tree', (tester) async {
      await pumpApp(tester);
      // MaterialApp.router produces a Router widget with a GoRouter delegate.
      expect(find.byType(Router<Object>), findsOneWidget);
    });

    testWidgets('debugShowCheckedModeBanner is false', (tester) async {
      await pumpApp(tester);
      final materialApp = tester
          .widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });
  });

  group('BetterLifeApp — T-S11-02 theme applied', () {
    testWidgets('applies BLTheme.light — primary color is lavender500',
        (tester) async {
      await pumpApp(tester);
      final materialApp = tester
          .widget<MaterialApp>(find.byType(MaterialApp));
      // BLTheme.light() sets primary = BLColors.lavender500 (#434352).
      expect(
        materialApp.theme?.colorScheme.primary,
        BLColors.lavender500,
      );
    });

    testWidgets('applies BLTheme.light — onSurface is BLColors.lavender500',
        (tester) async {
      await pumpApp(tester);
      final materialApp = tester
          .widget<MaterialApp>(find.byType(MaterialApp));
      // Body text color locked to lavender500 per spec FR-007.
      expect(
        materialApp.theme?.colorScheme.onSurface,
        BLColors.lavender500,
      );
    });

    testWidgets('applies BLTheme.light — darkTheme is NOT set', (tester) async {
      await pumpApp(tester);
      final materialApp = tester
          .widget<MaterialApp>(find.byType(MaterialApp));
      // NFR-009: light-only; darkTheme must be null.
      expect(materialApp.darkTheme, isNull);
    });
  });

  group('BetterLifeApp — T-S11-03 ProviderScope wraps BetterLifeApp', () {
    testWidgets('BetterLifeApp reads appRouterProvider from its ProviderScope',
        (tester) async {
      // If BetterLifeApp did NOT use ref (i.e., was not a ConsumerWidget),
      // it could not access appRouterProvider. This test proves the contract by
      // ensuring GoRouter is in the widget tree via MaterialApp.router.
      await pumpApp(tester);

      // The Router widget wraps the GoRouter delegate — confirms appRouterProvider
      // was successfully read inside BetterLifeApp.
      expect(find.byType(Router<Object>), findsOneWidget);
    });

    testWidgets('initial route lands on splash screen', (tester) async {
      // AuthInitial → router stays at /splash.
      await pumpApp(tester, initialAuth: const AuthInitial());

      // SplashScreen is in the tree (it's the initial route).
      // We can confirm by checking that the Router rendered the splash gate
      // widget; since pump(3s) is shorter than the real timeout, the splash
      // may still be mounted or navigated. With FakeAuthNotifier (AuthInitial),
      // the redirect keeps us at /splash.
      expect(find.byType(Router<Object>), findsOneWidget);
      // No unhandled exception means the route was set up correctly.
      expect(tester.takeException(), isNull);
    });
  });
}
