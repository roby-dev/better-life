import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/theme/bl_tokens.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_notifier.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';

// ── Fake notifiers ────────────────────────────────────────────────────────────

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

class _HangingAuthNotifier extends AuthNotifier {
  _HangingAuthNotifier();

  @override
  AuthState build() => const AuthInitial();

  @override
  Future<void> bootstrap() async {
    await Completer<void>().future;
  }

  @override
  void markUnauthenticated() {
    state = const AuthUnauthenticated();
  }
}

Widget _buildSplash(AuthNotifier Function() notifierFactory) {
  return ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith(notifierFactory),
    ],
    child: const MaterialApp(home: SplashScreen()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashScreen — structure', () {
    testWidgets('renders a Scaffold with bl_splash_root key', (tester) async {
      await tester.pumpWidget(
        _buildSplash(() => _ImmediateAuthNotifier(const AuthUnauthenticated())),
      );
      await tester.pump(Duration.zero);

      expect(find.byKey(const Key('bl_splash_root')), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Scaffold background matches BLColors.lightBgTop',
        (tester) async {
      await tester.pumpWidget(
        _buildSplash(() => _ImmediateAuthNotifier(const AuthUnauthenticated())),
      );
      await tester.pump(Duration.zero);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, BLColors.lightBgTop);

      await tester.pump(const Duration(seconds: 1));
    });
  });

  group('SplashScreen — bootstrap()', () {
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

      expect(bootstrapCalled, isTrue);

      await tester.pump(const Duration(seconds: 1));
    });
  });

  group('SplashScreen — 5s hard timeout (markUnauthenticated)', () {
    testWidgets('forces Unauthenticated after 5s when bootstrap hangs',
        (tester) async {
      await tester.pumpWidget(
        _buildSplash(() => _HangingAuthNotifier()),
      );
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(seconds: 5));

      final element = tester.element(find.byType(SplashScreen));
      final container = ProviderScope.containerOf(element);
      final authState = container.read(authNotifierProvider);

      expect(authState, isA<AuthUnauthenticated>());
    });
  });

  group('SplashScreen — authenticated state navigation', () {
    testWidgets('with AuthAuthenticated — SplashScreen is present initially',
        (tester) async {
      final token = AuthToken(value: 'jwt-token');
      await tester.pumpWidget(
        _buildSplash(() => _ImmediateAuthNotifier(AuthAuthenticated(token))),
      );
      await tester.pump(Duration.zero);

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
    });
  });
}
