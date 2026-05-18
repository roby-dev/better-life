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
  Failure? _loginFailure;

  void failWith(Failure f) => _loginFailure = f;

  @override
  Future<AuthToken> login({required String email, required String password}) async {
    if (_loginFailure != null) throw _loginFailure!;
    return const AuthToken(value: 'tok-login');
  }

  @override
  Future<AuthToken> register({
    required String name,
    required String email,
    required String password,
    required String timeZone,
  }) async =>
      throw UnimplementedError();

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

// Wrap in MaterialApp + ProviderScope with overrides.
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
      home: LoginScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('LoginScreen — structure', () {
    testWidgets('renders heading text', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      expect(find.text('Bienvenido de vuelta'), findsOneWidget);
      expect(find.text('Continuemos donde lo dejaste.'), findsOneWidget);
    });

    testWidgets('does not render back button or mini logo (login is root)',
        (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
      expect(find.byKey(const Key('login_mini_logo')), findsNothing);
    });

    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('CONTRASEÑA'), findsOneWidget);
    });

    testWidgets('renders CTA button with correct label', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('renders forgot password link', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    });

    testWidgets('renders footer link text', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      expect(find.textContaining('¿No tienes cuenta?'), findsOneWidget);
      expect(find.text('Regístrate'), findsOneWidget);
    });
  });

  group('LoginScreen — CTA enable logic', () {
    testWidgets('CTA is disabled when form is empty', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('CTA is disabled when password has 5 characters', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'short',
      );
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('CTA is enabled with valid email and password >= 6', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'pass123',
      );
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });
  });

  group('LoginScreen — loading state', () {
    testWidgets('shows CircularProgressIndicator when AuthLoading', (tester) async {
      await tester.pumpWidget(
        _buildScreen(repo: _FakeRepo(), initialState: const AuthLoading()),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CTA is disabled when AuthLoading', (tester) async {
      await tester.pumpWidget(
        _buildScreen(repo: _FakeRepo(), initialState: const AuthLoading()),
      );
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('LoginScreen — error display', () {
    testWidgets('shows inline AuthFailure title in error region', (tester) async {
      const failure = AuthFailure(
        title: 'Credenciales inválidas',
        statusCode: 401,
      );
      await tester.pumpWidget(
        _buildScreen(
          repo: _FakeRepo(),
          initialState:
              const AuthError(failure, AuthUnauthenticated()),
        ),
      );
      await tester.pump();

      expect(find.text('Credenciales inválidas'), findsOneWidget);
    });

    testWidgets('shows ValidationFailure field error in email field', (tester) async {
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
  });

  group('LoginScreen — dead links', () {
    testWidgets('tapping forgot password shows SnackBar "Pronto disponible"', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      await tester.tap(find.text('¿Olvidaste tu contraseña?'));
      await tester.pump();

      expect(find.text('Pronto disponible'), findsOneWidget);
    });
  });

  group('LoginScreen — password toggle', () {
    testWidgets('eye icon toggles obscureText in password field', (tester) async {
      await tester.pumpWidget(_buildScreen(repo: _FakeRepo()));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'mySecret1!',
      );
      await tester.pump();

      // Tap the eye icon toggle
      await tester.tap(find.byKey(const Key('login_password_toggle')));
      await tester.pump();

      // After toggle: password should be revealed (obscureText = false)
      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('login_password_field')),
          matching: find.byType(TextField),
        ),
      );
      expect(textField.obscureText, isFalse);
    });
  });

  // ── Footer navigation tests (requires GoRouter) ───────────────────────────

  /// Builds a [MaterialApp.router] with a minimal GoRouter containing only
  /// the login and register routes, backed by Riverpod provider overrides.
  Widget buildScreenWithRouter({required _FakeRepo repo}) {
    final storage = InMemoryTokenStorage();
    final router = GoRouter(
      initialLocation: '/login',
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

  group('LoginScreen — footer navigation', () {
    testWidgets('tapping Regístrate navigates to SignUpScreen', (tester) async {
      await tester.pumpWidget(buildScreenWithRouter(repo: _FakeRepo()));
      await tester.pump();

      // Scroll down to expose the footer area.
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pump();

      await tester.tap(find.text('Regístrate'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // After navigation, SignUpScreen should be visible.
      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}
