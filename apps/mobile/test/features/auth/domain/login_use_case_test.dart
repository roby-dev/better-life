import 'package:flutter_test/flutter_test.dart';
import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:better_life_app/features/auth/domain/usecases/login_use_case.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _SuccessRepo implements IAuthRepository {
  static const _token = AuthToken(value: 'login-token');

  @override
  Future<AuthToken> login({
    required String email,
    required String password,
  }) async =>
      _token;

  @override
  Future<AuthToken> register({
    required String name,
    required String email,
    required String password,
    required String timeZone,
  }) async =>
      _token;

  @override
  Future<void> logout() async {}

  @override
  Future<AuthToken?> currentToken() async => null;
}

class _FailingRepo implements IAuthRepository {
  final Failure failure;
  _FailingRepo(this.failure);

  @override
  Future<AuthToken> login({
    required String email,
    required String password,
  }) async =>
      throw failure;

  @override
  Future<AuthToken> register({
    required String name,
    required String email,
    required String password,
    required String timeZone,
  }) async =>
      throw failure;

  @override
  Future<void> logout() async {}

  @override
  Future<AuthToken?> currentToken() async => null;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('LoginUseCase', () {
    test('returns AuthToken on success', () async {
      final useCase = LoginUseCase(_SuccessRepo());
      final token = await useCase(email: 'user@test.com', password: 'pass1234');
      expect(token, const AuthToken(value: 'login-token'));
    });

    test('delegates email and password to the repository', () async {
      String? capturedEmail;
      String? capturedPassword;

      final repo = _CapturingRepo(
        onLogin: (email, pw) {
          capturedEmail = email;
          capturedPassword = pw;
          return const AuthToken(value: 'tok');
        },
      );

      final useCase = LoginUseCase(repo);
      await useCase(email: 'ana@test.com', password: 'secret99');

      expect(capturedEmail, 'ana@test.com');
      expect(capturedPassword, 'secret99');
    });

    test('propagates AuthFailure from the repository', () async {
      const failure = AuthFailure(title: 'Credenciales inválidas', statusCode: 401);
      final useCase = LoginUseCase(_FailingRepo(failure));

      expect(
        () => useCase(email: 'a@b.com', password: 'bad'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('propagates NetworkFailure from the repository', () async {
      const failure = NetworkFailure();
      final useCase = LoginUseCase(_FailingRepo(failure));

      expect(
        () => useCase(email: 'a@b.com', password: 'pw'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Helper fake to capture call args
// ---------------------------------------------------------------------------

class _CapturingRepo implements IAuthRepository {
  final AuthToken Function(String email, String pw) onLogin;
  _CapturingRepo({required this.onLogin});

  @override
  Future<AuthToken> login({
    required String email,
    required String password,
  }) async =>
      onLogin(email, password);

  @override
  Future<AuthToken> register({
    required String name,
    required String email,
    required String password,
    required String timeZone,
  }) async =>
      const AuthToken(value: 'tok');

  @override
  Future<void> logout() async {}

  @override
  Future<AuthToken?> currentToken() async => null;
}
