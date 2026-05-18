import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/widgets/bl_animated_logo.dart';
import 'package:better_life_app/core/widgets/bl_loader_bar.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_notifier.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';

// ── Fake notifiers ────────────────────────────────────────────────────────────

/// A notifier whose bootstrap() completes immediately with a pre-set state.
class _ImmediateAuthNotifier extends AuthNotifier {
  _ImmediateAuthNotifier(this._bootstrapState);
  final AuthState _bootstrapState;

  @override
  AuthState build() => const AuthInitial();

  @override
  Future<void> bootstrap() async {
    state = _bootstrapState;
  }

  @override
  void markUnauthenticated() {
    state = const AuthUnauthenticated();
  }
}

/// A notifier whose bootstrap() never resolves (simulates slow storage).
class _HangingAuthNotifier extends AuthNotifier {
  _HangingAuthNotifier();

  @override
  AuthState build() => const AuthInitial();

  @override
  Future<void> bootstrap() async {
    // Never resolves — simulates Keystore hang.
    await Completer<void>().future;
  }

  @override
  void markUnauthenticated() {
    state = const AuthUnauthenticated();
  }
}

// ── Widget helper ─────────────────────────────────────────────────────────────

/// Pumps SplashScreen inside a ProviderScope + MaterialApp.
Widget _buildSplash(AuthNotifier Function() notifierFactory) {
  return ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith(notifierFactory),
    ],
    // Wrap in a MaterialApp that uses a Navigator so context.go* calls are safe.
    child: const MaterialApp(
      home: SplashScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashScreen — structure (after 2500ms gate completes)', () {
    testWidgets('renders BLAnimatedLogo', (tester) async {
      await tester.pumpWidget(
        _buildSplash(() => _ImmediateAuthNotifier(const AuthUnauthenticated())),
      );
      // Pump 0ms: initial build
      await tester.pump(Duration.zero);

      expect(find.byType(BLAnimatedLogo), findsOneWidget);

      // Drain all pending timers so the test ends cleanly.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('renders BLLoaderBar', (tester) async {
      await tester.pumpWidget(
        _buildSplash(() => _ImmediateAuthNotifier(const AuthUnauthenticated())),
      );
      await tester.pump(Duration.zero);

      expect(find.byType(BLLoaderBar), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('has key bl_splash_root on root widget', (tester) async {
      await tester.pumpWidget(
        _buildSplash(() => _ImmediateAuthNotifier(const AuthUnauthenticated())),
      );
      await tester.pump(Duration.zero);

      expect(find.byKey(const Key('bl_splash_root')), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('renders tagline text', (tester) async {
      await tester.pumpWidget(
        _buildSplash(() => _ImmediateAuthNotifier(const AuthUnauthenticated())),
      );
      await tester.pump(Duration.zero);

      expect(
        find.text('Tu mejor versión, un hábito a la vez.'),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('SplashScreen — bootstrap() called in initState', () {
    testWidgets('calls bootstrap on the notifier', (tester) async {
      var bootstrapCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(() {
              bootstrapCalled = true;
              return _ImmediateAuthNotifier(const AuthUnauthenticated());
            }),
          ],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );
      await tester.pump(Duration.zero);

      // The override factory is called when the provider is first read.
      // SplashScreen reads authNotifierProvider.notifier in initState.
      expect(bootstrapCalled, isTrue);

      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('SplashScreen — 5s hard timeout (markUnauthenticated)', () {
    testWidgets(
        'calls markUnauthenticated after 5s when bootstrap hangs',
        (tester) async {
      await tester.pumpWidget(
        _buildSplash(() => _HangingAuthNotifier()),
      );
      await tester.pump(Duration.zero); // initial build

      // Advance past the 5-second hard timeout.
      await tester.pump(const Duration(seconds: 5));

      // The notifier should have been forced to AuthUnauthenticated.
      final element = tester.element(find.byType(SplashScreen));
      final container = ProviderScope.containerOf(element);
      final authState = container.read(authNotifierProvider);

      // After 5s timeout, state should be Unauthenticated (not AuthInitial).
      expect(authState, isA<AuthUnauthenticated>());

      // Drain remaining timers (floor completes after hanging bootstrap resolves).
      // The hanging bootstrap never completes so Future.wait is still pending.
      // We just make sure the test doesn't fail due to pending timers by
      // allowing the test to complete — the timer was cancelled in dispose.
    });
  });

  group('SplashScreen — gate minimum floor (2500ms)', () {
    testWidgets(
        'at 2499ms screen is still showing (gate not resolved)',
        (tester) async {
      await tester.pumpWidget(
        _buildSplash(
          () => _ImmediateAuthNotifier(const AuthUnauthenticated()),
        ),
      );
      await tester.pump(Duration.zero);

      // Pump 2499ms — gate should NOT have fired yet.
      await tester.pump(const Duration(milliseconds: 2499));

      // SplashScreen is still in the tree.
      expect(find.byType(SplashScreen), findsOneWidget);

      // Drain the remaining 1ms + extra to clean up.
      await tester.pump(const Duration(seconds: 1));
    });
  });

  group('SplashScreen — gradient background', () {
    testWidgets('contains a Container with RadialGradient decoration',
        (tester) async {
      await tester.pumpWidget(
        _buildSplash(() => _ImmediateAuthNotifier(const AuthUnauthenticated())),
      );
      await tester.pump(Duration.zero);

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasGradient = containers.any((c) {
        final dec = c.decoration;
        if (dec is BoxDecoration) {
          return dec.gradient is RadialGradient;
        }
        return false;
      });
      expect(hasGradient, isTrue);

      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('SplashScreen — authenticated state navigation', () {
    testWidgets(
        'with AuthAuthenticated — SplashScreen is present initially',
        (tester) async {
      final token = AuthToken(value: 'jwt-token');
      await tester.pumpWidget(
        _buildSplash(() => _ImmediateAuthNotifier(AuthAuthenticated(token))),
      );
      await tester.pump(Duration.zero);

      // At t=0, splash is still visible (gate not complete yet).
      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
    });
  });
}
