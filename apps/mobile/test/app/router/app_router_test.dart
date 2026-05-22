import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:better_life_app/app/router/app_router.dart';
import 'package:better_life_app/app/router/route_names.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_notifier.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';
import 'package:better_life_app/features/habits/presentation/providers.dart';
import 'package:better_life_app/features/habits/presentation/state/habits_notifier.dart';
import 'package:better_life_app/features/habits/presentation/state/habits_state.dart';

// ── Minimal fake notifier helpers ────────────────────────────────────────────

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._initial);
  final AuthState _initial;

  @override
  AuthState build() {
    // Skip real dependency resolution.
    return _initial;
  }

  @override
  Future<void> bootstrap() async {
    // no-op in tests
  }
}

class _FakeHabitsNotifier extends HabitsNotifier {
  @override
  HabitsState build() => const HabitsLoaded([]);

  @override
  Future<void> load() async {}
  @override
  Future<void> retry() async {}
  @override
  Future<void> delete(String id) async {}
}

// Helper: pump a MaterialApp.router backed by an overridden authNotifierProvider
// and return the router.
Future<GoRouter> _pumpRouter(
  WidgetTester tester,
  AuthState initial,
) async {
  late GoRouter router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(() => _FakeAuthNotifier(initial)),
            habitsNotifierProvider.overrideWith(() => _FakeHabitsNotifier()),
          ],
      child: Builder(
        builder: (context) {
          final container = ProviderScope.containerOf(context);
          router = container.read(appRouterProvider);
          return MaterialApp.router(
            routerConfig: router,
          );
        },
      ),
    ),
  );

  // Drain the deferred Future(() => _runGate) timer (zero-duration) so it does
  // not remain pending after the test ends.
  await tester.pump(Duration.zero);
  // Then drain the splash gate timers (2500ms floor).
  await tester.pump(const Duration(seconds: 3));
  return router;
}

void main() {
  group('AppRouter — redirect logic', () {
    // AuthInitial → stay at /splash (no redirect away from splash)
    testWidgets('AuthInitial at /splash — stays on splash', (tester) async {
      final router = await _pumpRouter(tester, const AuthInitial());
      expect(router.routerDelegate.currentConfiguration.uri.toString(),
          RoutePaths.splash);
    });

    // AuthUnauthenticated at /splash → redirect to /login
    testWidgets(
        'AuthUnauthenticated at /splash — redirects to /login after gate',
        (tester) async {
      // When SplashScreen is not wired, the redirect should push to login
      // for unauthenticated state when on splash.
      // We test redirect by directly reading the redirect outcome.
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider
              .overrideWith(() => _FakeAuthNotifier(const AuthUnauthenticated())),
          habitsNotifierProvider.overrideWith(() => _FakeHabitsNotifier()),
        ],
      );
      addTearDown(container.dispose);

      // The redirect function for AuthUnauthenticated at /splash → /login
      // We verify by pumping a router starting at /splash with that state.
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Builder(
            builder: (context) {
              final router = container.read(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );
      await tester.pump();
      // The router starts at /splash; redirect for AuthUnauthenticated from
      // splash goes to /login. Pump once for the redirect.
      await tester.pump();

      final router = container.read(appRouterProvider);
      final loc = router.routerDelegate.currentConfiguration.uri.toString();
      // Should have redirected to /login
      expect(loc, RoutePaths.login);
    });

    // AuthAuthenticated at /splash → redirects to /home/habits
    testWidgets('AuthAuthenticated at /splash — redirects to /home/habits',
        (tester) async {
      final token = AuthToken(value: 'tok');
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(
              () => _FakeAuthNotifier(AuthAuthenticated(token))),
          habitsNotifierProvider.overrideWith(() => _FakeHabitsNotifier()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Builder(
            builder: (context) {
              final router = container.read(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final router = container.read(appRouterProvider);
      final loc = router.routerDelegate.currentConfiguration.uri.toString();
      expect(loc, RoutePaths.habits);
    });

    // AuthAuthenticated at /login → redirects to /home/habits
    testWidgets('AuthAuthenticated navigating to /login — redirects to habits',
        (tester) async {
      final token = AuthToken(value: 'tok');
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(
              () => _FakeAuthNotifier(AuthAuthenticated(token))),
          habitsNotifierProvider.overrideWith(() => _FakeHabitsNotifier()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Builder(
            builder: (context) {
              final router = container.read(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final router = container.read(appRouterProvider);
      router.go(RoutePaths.login);
      await tester.pump();

      final loc = router.routerDelegate.currentConfiguration.uri.toString();
      expect(loc, RoutePaths.habits);
    });

    // AuthUnauthenticated at /home/habits → redirects to /login
    testWidgets(
        'AuthUnauthenticated at /home/habits — redirects to /login',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(
              () => _FakeAuthNotifier(const AuthUnauthenticated())),
          habitsNotifierProvider.overrideWith(() => _FakeHabitsNotifier()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Builder(
            builder: (context) {
              final router = container.read(appRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final router = container.read(appRouterProvider);
      router.go(RoutePaths.habits);
      await tester.pump();

      final loc = router.routerDelegate.currentConfiguration.uri.toString();
      expect(loc, RoutePaths.login);
    });

    // appRouterProvider returns a GoRouter instance
    test('appRouterProvider — returns GoRouter', () {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(
              () => _FakeAuthNotifier(const AuthInitial())),
          habitsNotifierProvider.overrideWith(() => _FakeHabitsNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      expect(router, isA<GoRouter>());
    });
  });
}
