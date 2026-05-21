import 'package:flutter_test/flutter_test.dart';
import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/core/platform/timezone_resolver.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:better_life_app/features/auth/domain/usecases/register_use_case.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeTimezoneResolver implements TimezoneResolver {
  final String zone;
  _FakeTimezoneResolver(this.zone);

  @override
  Future<String> resolve() async => zone;
}

class _CapturingRepo implements IAuthRepository {
  String? capturedName;
  String? capturedEmail;
  String? capturedPassword;
  String? capturedTimeZone;

  final AuthToken _result;
  final Failure? _failure;

  _CapturingRepo({
    AuthToken result = const AuthToken(value: 'reg-token'),
    Failure? failure,
  })  : _result = result,
        _failure = failure;

  @override
  Future<AuthToken> login({
    required String email,
    required String password,
  }) async =>
      _result;

  @override
  Future<AuthToken> register({
    required String name,
    required String email,
    required String password,
    required String timeZone,
  }) async {
    capturedName = name;
    capturedEmail = email;
    capturedPassword = password;
    capturedTimeZone = timeZone;
    final f = _failure;
    if (f != null) throw f;
    return _result;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AuthToken?> currentToken() async => null;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RegisterUseCase', () {
    test('returns AuthToken on success', () async {
      final repo = _CapturingRepo();
      final useCase = RegisterUseCase(repo, _FakeTimezoneResolver('America/Bogota'));

      final token = await useCase(
        name: 'Ana',
        email: 'ana@test.com',
        password: 'Secure1!',
      );

      expect(token, const AuthToken(value: 'reg-token'));
    });

    test('resolves timezone and includes it in the repository call', () async {
      final repo = _CapturingRepo();
      final useCase = RegisterUseCase(repo, _FakeTimezoneResolver('America/Bogota'));

      await useCase(name: 'Ana', email: 'ana@test.com', password: 'Secure1!');

      expect(repo.capturedTimeZone, 'America/Bogota');
    });

    test('uses America/Lima fallback when timezone resolver provides fallback', () async {
      final repo = _CapturingRepo();
      // FlutterTimezoneResolver falls back internally — simulate via fake returning fallback.
      final useCase = RegisterUseCase(repo, _FakeTimezoneResolver('America/Lima'));

      await useCase(name: 'Ana', email: 'ana@test.com', password: 'Secure1!');

      expect(repo.capturedTimeZone, 'America/Lima');
    });

    test('delegates name, email, and password to repository', () async {
      final repo = _CapturingRepo();
      final useCase = RegisterUseCase(repo, _FakeTimezoneResolver('America/Lima'));

      await useCase(name: 'Bob', email: 'bob@test.com', password: 'Pass1234!');

      expect(repo.capturedName, 'Bob');
      expect(repo.capturedEmail, 'bob@test.com');
      expect(repo.capturedPassword, 'Pass1234!');
    });

    test('propagates ValidationFailure from repository', () async {
      const failure = ValidationFailure(
        title: 'Validation error',
        errors: {'Email': ['already exists']},
      );
      final repo = _CapturingRepo(failure: failure);
      final useCase = RegisterUseCase(repo, _FakeTimezoneResolver('America/Lima'));

      expect(
        () => useCase(name: 'Ana', email: 'ana@test.com', password: 'Secure1!'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('propagates NetworkFailure from repository', () async {
      const failure = NetworkFailure();
      final repo = _CapturingRepo(failure: failure);
      final useCase = RegisterUseCase(repo, _FakeTimezoneResolver('America/Lima'));

      expect(
        () => useCase(name: 'Ana', email: 'ana@test.com', password: 'Secure1!'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
