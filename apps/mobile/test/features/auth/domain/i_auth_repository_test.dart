import 'package:flutter_test/flutter_test.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';

/// Minimal in-memory fake that satisfies [IAuthRepository].
class _FakeAuthRepository implements IAuthRepository {
  static const _stored = AuthToken(value: 'fake-jwt');
  bool _hasToken = false;

  @override
  Future<AuthToken> login({
    required String email,
    required String password,
  }) async =>
      _stored;

  @override
  Future<AuthToken> register({
    required String name,
    required String email,
    required String password,
    required String timeZone,
  }) async =>
      _stored;

  @override
  Future<void> logout() async {
    _hasToken = false;
  }

  @override
  Future<AuthToken?> currentToken() async => _hasToken ? _stored : null;

  void seedToken() => _hasToken = true;
}

void main() {
  late _FakeAuthRepository repo;

  setUp(() => repo = _FakeAuthRepository());

  group('IAuthRepository contract', () {
    test('login returns an AuthToken', () async {
      final token = await repo.login(email: 'a@b.com', password: 'pw');
      expect(token, isA<AuthToken>());
    });

    test('register returns an AuthToken', () async {
      final token = await repo.register(
        name: 'Ana',
        email: 'a@b.com',
        password: 'pw',
        timeZone: 'America/Lima',
      );
      expect(token, isA<AuthToken>());
    });

    test('currentToken returns null when no token is stored', () async {
      expect(await repo.currentToken(), isNull);
    });

    test('currentToken returns a token after seeding', () async {
      repo.seedToken();
      expect(await repo.currentToken(), isNotNull);
    });

    test('logout clears the stored token', () async {
      repo.seedToken();
      await repo.logout();
      expect(await repo.currentToken(), isNull);
    });
  });
}
