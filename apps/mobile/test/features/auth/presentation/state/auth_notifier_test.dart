import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/core/storage/storage_providers.dart';
import 'package:better_life_app/core/storage/token_storage.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeRepo implements IAuthRepository {
  AuthToken? _stored;
  Failure? _loginFailure;
  Failure? _registerFailure;

  _FakeRepo({AuthToken? stored}) : _stored = stored;

  void setLoginFailure(Failure f) => _loginFailure = f;
  void setRegisterFailure(Failure f) => _registerFailure = f;

  @override
  Future<AuthToken> login({required String email, required String password}) async {
    if (_loginFailure != null) throw _loginFailure!;
    return const AuthToken(value: 'login-tok');
  }

  @override
  Future<AuthToken> register({
    required String name,
    required String email,
    required String password,
    required String timeZone,
  }) async {
    if (_registerFailure != null) throw _registerFailure!;
    return const AuthToken(value: 'register-tok');
  }

  @override
  Future<void> logout() async => _stored = null;

  @override
  Future<AuthToken?> currentToken() async => _stored;
}

/// Creates a [ProviderContainer] with the notifier under test.
/// [repo] is injected via [authRepositoryProvider] override.
ProviderContainer _makeContainer(_FakeRepo repo) {
  final storage = InMemoryTokenStorage();
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      // The notifier reads loginUseCaseProvider and registerUseCaseProvider
      // which themselves read authRepositoryProvider — so overriding the repo
      // is sufficient to inject the fake end-to-end.
      tokenStorageProvider.overrideWithValue(storage),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AuthNotifier — initial state', () {
    test('starts as AuthInitial', () {
      final repo = _FakeRepo();
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      expect(container.read(authNotifierProvider), isA<AuthInitial>());
    });
  });

  group('AuthNotifier — bootstrap()', () {
    test('emits Authenticated when a token is stored', () async {
      final repo = _FakeRepo(stored: const AuthToken(value: 'stored-tok'));
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.notifier).bootstrap();
      expect(container.read(authNotifierProvider), isA<AuthAuthenticated>());
    });

    test('emits Unauthenticated when no token is stored', () async {
      final repo = _FakeRepo();
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.notifier).bootstrap();
      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
    });

    test('emits Unauthenticated on storage exception', () async {
      final repo = _ThrowingCurrentTokenRepo();
      final storage = InMemoryTokenStorage();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
          tokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.notifier).bootstrap();
      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
    });
  });

  group('AuthNotifier — login()', () {
    test('transitions Initial → Loading → Authenticated on success', () async {
      final repo = _FakeRepo();
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      final states = <AuthState>[];
      container.listen(authNotifierProvider, (_, next) => states.add(next),
          fireImmediately: false);

      await container
          .read(authNotifierProvider.notifier)
          .login(email: 'a@b.com', password: 'pass123');

      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthAuthenticated>());
    });

    test('emits AuthError on AuthFailure', () async {
      final repo = _FakeRepo();
      repo.setLoginFailure(
          const AuthFailure(title: 'Credenciales inválidas', statusCode: 401));
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container
          .read(authNotifierProvider.notifier)
          .login(email: 'a@b.com', password: 'wrong');
      final state = container.read(authNotifierProvider);

      expect(state, isA<AuthError>());
      expect((state as AuthError).failure, isA<AuthFailure>());
    });

    test('AuthError.previous is never an AuthError (_flatten invariant)', () async {
      final repo = _FakeRepo();
      repo.setLoginFailure(
          const AuthFailure(title: 'err', statusCode: 401));
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      // Fail twice — second error's previous must be Unauthenticated, not AuthError.
      await container
          .read(authNotifierProvider.notifier)
          .login(email: 'a@b.com', password: 'w');
      await container
          .read(authNotifierProvider.notifier)
          .login(email: 'a@b.com', password: 'w');

      final state = container.read(authNotifierProvider);
      expect(state, isA<AuthError>());
      expect((state as AuthError).previous, isNot(isA<AuthError>()));
    });

    test('emits AuthError wrapping UnknownFailure on generic exception', () async {
      final repo = _ThrowingGenericRepo();
      final storage = InMemoryTokenStorage();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
          tokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(authNotifierProvider.notifier)
          .login(email: 'a@b.com', password: 'pw');

      final state = container.read(authNotifierProvider);
      expect(state, isA<AuthError>());
      expect((state as AuthError).failure, isA<UnknownFailure>());
    });
  });

  group('AuthNotifier — register()', () {
    test('transitions to Authenticated on success', () async {
      final repo = _FakeRepo();
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.notifier).register(
            name: 'Ana',
            email: 'ana@test.com',
            password: 'passAbc1!',
          );
      expect(container.read(authNotifierProvider), isA<AuthAuthenticated>());
    });

    test('emits AuthError on ValidationFailure', () async {
      final repo = _FakeRepo();
      repo.setRegisterFailure(ValidationFailure(
        title: 'Validation error',
        errors: {
          'Email': ['already exists']
        },
      ));
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.notifier).register(
            name: 'Ana',
            email: 'taken@test.com',
            password: 'passAbc1!',
          );

      final state = container.read(authNotifierProvider);
      expect(state, isA<AuthError>());
      expect((state as AuthError).failure, isA<ValidationFailure>());
    });
  });

  group('AuthNotifier — logout()', () {
    test('transitions Authenticated → Unauthenticated', () async {
      final repo = _FakeRepo(stored: const AuthToken(value: 'tok'));
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.notifier).bootstrap();
      expect(container.read(authNotifierProvider), isA<AuthAuthenticated>());

      await container.read(authNotifierProvider.notifier).logout();
      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
    });
  });
}

// ---------------------------------------------------------------------------
// Helper fakes
// ---------------------------------------------------------------------------

class _ThrowingCurrentTokenRepo implements IAuthRepository {
  @override
  Future<AuthToken?> currentToken() async => throw Exception('storage error');

  @override
  Future<AuthToken> login({required String email, required String password}) async =>
      throw UnimplementedError();

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
}

class _ThrowingGenericRepo implements IAuthRepository {
  @override
  Future<AuthToken?> currentToken() async => null;

  @override
  Future<AuthToken> login({required String email, required String password}) async =>
      throw Exception('network down');

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
}
