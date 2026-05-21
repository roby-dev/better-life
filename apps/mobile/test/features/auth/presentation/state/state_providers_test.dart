import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/storage/storage_providers.dart';
import 'package:better_life_app/core/storage/token_storage.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_notifier.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';
import 'package:better_life_app/features/auth/presentation/state/login_form_notifier.dart';
import 'package:better_life_app/features/auth/presentation/state/login_form_state.dart';
import 'package:better_life_app/features/auth/presentation/state/signup_form_notifier.dart';
import 'package:better_life_app/features/auth/presentation/state/signup_form_state.dart';

// ---------------------------------------------------------------------------
// Minimal fake repo for provider resolution tests
// ---------------------------------------------------------------------------

class _StubRepo implements IAuthRepository {
  @override
  Future<AuthToken?> currentToken() async => null;

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

ProviderContainer _makeContainer() {
  final c = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(_StubRepo()),
      tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('State layer providers', () {
    test('authNotifierProvider resolves as AuthNotifier', () {
      final c = _makeContainer();
      expect(c.read(authNotifierProvider.notifier), isA<AuthNotifier>());
    });

    test('authNotifierProvider initial state is AuthInitial', () {
      final c = _makeContainer();
      expect(c.read(authNotifierProvider), isA<AuthInitial>());
    });

    test('signUpFormProvider resolves as SignUpFormNotifier', () {
      final c = _makeContainer();
      expect(c.read(signUpFormProvider.notifier), isA<SignUpFormNotifier>());
    });

    test('signUpFormProvider initial state is empty SignUpFormState', () {
      final c = _makeContainer();
      expect(c.read(signUpFormProvider), isA<SignUpFormState>());
      expect(c.read(signUpFormProvider).canSubmit, isFalse);
    });

    test('loginFormProvider resolves as LoginFormNotifier', () {
      final c = _makeContainer();
      expect(c.read(loginFormProvider.notifier), isA<LoginFormNotifier>());
    });

    test('loginFormProvider initial state is empty LoginFormState', () {
      final c = _makeContainer();
      expect(c.read(loginFormProvider), isA<LoginFormState>());
      expect(c.read(loginFormProvider).canSubmit, isFalse);
    });
  });
}
