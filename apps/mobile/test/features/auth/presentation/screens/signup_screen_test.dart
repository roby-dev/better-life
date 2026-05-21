import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:better_life_app/app/router/route_names.dart';
import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/core/storage/storage_providers.dart';
import 'package:better_life_app/core/storage/token_storage.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/screens/login_screen.dart';
import 'package:better_life_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_notifier.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeRepo implements IAuthRepository {
  Failure? _registerFailure;

  void failWith(Failure f) => _registerFailure = f;

  @override
  Future<AuthToken> login({required String email, required String password}) async =>
      throw UnimplementedError();

  @override
  Future<AuthToken> register({
    required String name,
    required String email,
    required String password,
    required String timeZone,
  }) async {
    if (_registerFailure != null) throw _registerFailure!;
    return const AuthToken(value: 'tok-register');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AuthToken?> currentToken() async => null;
}

class _FakeAuthNotifier extends AuthNotifier {
  final AuthState _initial;
  _FakeAuthNotifier(this._initial);

  @override
  AuthState build() => _initial;

  @override
  Future<void> bootstrap() async {}
}

Widget _buildScreen({
  required _FakeRepo repo,
  AuthState initialState = const AuthUnauthenticated(),
}) {
  final storage = InMemoryTokenStorage();
  return ProviderScope(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
      authRepositoryProvider.overrideWithValue(repo),
      authNotifierProvider.overrideWith(
        () => _FakeAuthNotifier(initialState),
      ),
    ],
    child: const MaterialApp(
      home: SignUpScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SignUpScreen — structure', () {
    testWidgets('renders heading text', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      expect(find.text('Crea tu cuenta'), findsOneWidget);
      expect(
        find.text('Empieza tu camino hacia mejores hábitos.'),
        findsOneWidget,
      );
    });

    testWidgets('renders back button only (no mini logo)', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byKey(const Key('signup_mini_logo')), findsNothing);
    });

    testWidgets('renders name, email and password fields', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      expect(find.text('NOMBRE'), findsOneWidget);
      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('CONTRASEÑA'), findsOneWidget);
    });

    testWidgets('renders CTA button with correct label', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      expect(find.text('Crear cuenta'), findsOneWidget);
    });

    testWidgets('renders terms caption', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      expect(find.textContaining('Al continuar, aceptas nuestros'), findsOneWidget);
    });

    testWidgets('renders footer link text', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      expect(find.textContaining('¿Ya tienes cuenta?'), findsOneWidget);
      expect(find.text('Inicia sesión'), findsOneWidget);
    });
  });

  group('SignUpScreen — CTA enable logic', () {
    testWidgets('CTA is disabled when form is empty', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('CTA is disabled with weak password (score 1)', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('signup_name_field')),
        'Ana',
      );
      await tester.enterText(
        find.byKey(const Key('signup_email_field')),
        'ana@test.com',
      );
      // score=1: only length>=8
      await tester.enterText(
        find.byKey(const Key('signup_password_field')),
        'abcdefgh',
      );
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('CTA is enabled with acceptable password (score >= 2)', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('signup_name_field')),
        'Ana',
      );
      await tester.enterText(
        find.byKey(const Key('signup_email_field')),
        'ana@test.com',
      );
      // score=2: length>=8 + digit
      await tester.enterText(
        find.byKey(const Key('signup_password_field')),
        'abcdefgh1',
      );
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });
  });

  group('SignUpScreen — strength meter', () {
    testWidgets('BLStrengthMeter is hidden when password is empty', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      // No bars visible when password empty
      expect(find.byKey(const Key('bar_0')), findsNothing);
    });

    testWidgets('BLStrengthMeter visible when password has text', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('signup_password_field')),
        'abc',
      );
      await tester.pump();

      expect(find.byKey(const Key('bar_0')), findsOneWidget);
    });

    testWidgets('shows Débil label with score 1', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('signup_password_field')),
        'abcdefgh',
      );
      await tester.pump();

      // BLStrengthMeter renders strengthLabels[1] = 'Débil' without auto-uppercase.
      expect(find.text('Débil'), findsOneWidget);
    });

    testWidgets('shows Aceptable label with score 2', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('signup_password_field')),
        'abcdefgh1',
      );
      await tester.pump();

      expect(find.text('Aceptable'), findsOneWidget);
    });
  });

  group('SignUpScreen — loading state', () {
    testWidgets('shows CircularProgressIndicator when AuthLoading', (tester) async {
      await tester.pumpWidget(
        _buildScreen(repo: _FakeRepo(), initialState: const AuthLoading()),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('SignUpScreen — error display', () {
    testWidgets('shows ValidationFailure email error under email field', (tester) async {
      final failure = ValidationFailure(
        title: 'Validation error',
        errors: {
          'email': ['El correo ya está registrado'],
        },
      );
      await tester.pumpWidget(
        _buildScreen(
          repo: _FakeRepo(),
          initialState: AuthError(failure, const AuthUnauthenticated()),
        ),
      );
      await tester.pump();

      expect(find.text('El correo ya está registrado'), findsOneWidget);
    });

    testWidgets('shows AuthFailure (409) inline error', (tester) async {
      const failure = AuthFailure(
        title: 'Este correo ya está registrado',
        statusCode: 409,
      );
      await tester.pumpWidget(
        _buildScreen(
          repo: _FakeRepo(),
          initialState: const AuthError(failure, AuthUnauthenticated()),
        ),
      );
      await tester.pump();

      expect(find.text('Este correo ya está registrado'), findsOneWidget);
    });
  });

  group('SignUpScreen — dead links', () {
    testWidgets('tapping Términos shows SnackBar "Pronto disponible"', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      await tester.tap(find.text('Términos'));
      await tester.pump();

      expect(find.text('Pronto disponible'), findsOneWidget);
    });

    testWidgets('tapping Política de privacidad shows SnackBar', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      // Drag the screen to expose the terms section.
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pump();

      await tester.tap(
        find.text('Política de privacidad'),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(find.text('Pronto disponible'), findsOneWidget);
    });
  });

  group('SignUpScreen — password toggle', () {
    testWidgets('eye icon toggles obscureText in password field', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('signup_password_field')),
        'mySecret1!',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('signup_password_toggle')));
      await tester.pump();

      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('signup_password_field')),
          matching: find.byType(TextField),
        ),
      );
      expect(textField.obscureText, isFalse);
    });
  });

  // ── Footer navigation tests (requires GoRouter) ───────────────────────────

  /// Builds a [MaterialApp.router] with a minimal GoRouter containing only
  /// the register and login routes, backed by Riverpod provider overrides.
  Widget buildScreenWithRouter({required _FakeRepo repo}) {
    final storage = InMemoryTokenStorage();
    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: RouteNames.register,
          builder: (context, state) => const SignUpScreen(),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(repo),
        authNotifierProvider.overrideWith(
          () => _FakeAuthNotifier(const AuthUnauthenticated()),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('SignUpScreen — footer navigation', () {
    testWidgets('tapping Inicia sesión navigates to LoginScreen', (tester) async {
      await tester.pumpWidget(buildScreenWithRouter(repo: _FakeRepo()));
      await tester.pump();

      // Drag to expose the footer (it may be below the fold).
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pump();

      await tester.tap(find.text('Inicia sesión'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // After navigation, LoginScreen should be visible.
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SignUpScreen), findsNothing);
    });

    testWidgets('tapping back button navigates to LoginScreen', (tester) async {
      await tester.pumpWidget(buildScreenWithRouter(repo: _FakeRepo()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SignUpScreen), findsNothing);
    });
  });
}
