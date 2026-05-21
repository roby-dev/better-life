import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';

void main() {
  const token = AuthToken(value: 'test-jwt');
  const failure = AuthFailure(title: 'Credenciales inválidas', statusCode: 401);

  group('AuthState sealed class', () {
    test('AuthInitial is a subtype of AuthState', () {
      const AuthState s = AuthInitial();
      expect(s, isA<AuthInitial>());
    });

    test('AuthLoading is a subtype of AuthState', () {
      const AuthState s = AuthLoading();
      expect(s, isA<AuthLoading>());
    });

    test('AuthAuthenticated carries the token', () {
      const s = AuthAuthenticated(token);
      expect(s.token, token);
    });

    test('AuthUnauthenticated is a subtype of AuthState', () {
      const AuthState s = AuthUnauthenticated();
      expect(s, isA<AuthUnauthenticated>());
    });

    test('AuthError carries failure and previous state', () {
      const prev = AuthUnauthenticated();
      const s = AuthError(failure, prev);
      expect(s.failure, failure);
      expect(s.previous, prev);
    });

    test('AuthError.previous must not be another AuthError (design invariant)', () {
      // Constructing a nested AuthError should be possible in Dart,
      // but _flatten() in the notifier prevents it at the notifier level.
      // Here we verify the type is correct and document the invariant.
      const prev = AuthUnauthenticated();
      const s = AuthError(failure, prev);
      expect(s.previous, isNot(isA<AuthError>()));
    });

    test('exhaustive switch on AuthState compiles and covers all variants', () {
      AuthState state = const AuthInitial();
      final result = switch (state) {
        AuthInitial() => 'initial',
        AuthLoading() => 'loading',
        AuthAuthenticated() => 'authenticated',
        AuthUnauthenticated() => 'unauthenticated',
        AuthError() => 'error',
      };
      expect(result, 'initial');
    });
  });
}
