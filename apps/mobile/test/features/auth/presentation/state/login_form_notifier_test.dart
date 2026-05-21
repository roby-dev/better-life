import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/login_form_state.dart';

void main() {
  ProviderContainer makeContainer() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  group('LoginFormState — computed properties', () {
    test('initial state: canSubmit is false', () {
      expect(const LoginFormState().canSubmit, isFalse);
    });

    test('emailOk validates format', () {
      expect(const LoginFormState(email: 'bad').emailOk, isFalse);
      expect(const LoginFormState(email: 'a@b.com').emailOk, isTrue);
    });

    test('passwordOk requires length >= 6 (login rule, not strengthOf)', () {
      expect(const LoginFormState(password: 'abc12').passwordOk, isFalse);
      expect(const LoginFormState(password: 'abc123').passwordOk, isTrue);
    });

    test('canSubmit requires both fields valid', () {
      const state = LoginFormState(email: 'x@y.com', password: 'pass99');
      expect(state.canSubmit, isTrue);
    });

    test('canSubmit is false when password too short', () {
      const state = LoginFormState(email: 'x@y.com', password: 'pass1'); // 5 chars
      expect(state.canSubmit, isFalse);
    });
  });

  group('LoginFormNotifier', () {
    test('initial state is empty LoginFormState', () {
      final c = makeContainer();
      final state = c.read(loginFormProvider);
      expect(state.email, '');
      expect(state.password, '');
      expect(state.showPassword, isFalse);
    });

    test('setEmail updates email and marks email as touched', () {
      final c = makeContainer();
      c.read(loginFormProvider.notifier).setEmail('a@b.com');
      final state = c.read(loginFormProvider);
      expect(state.email, 'a@b.com');
      expect(state.touched.email, isTrue);
    });

    test('setPassword updates password and marks password as touched', () {
      final c = makeContainer();
      c.read(loginFormProvider.notifier).setPassword('secret1');
      final state = c.read(loginFormProvider);
      expect(state.password, 'secret1');
      expect(state.touched.password, isTrue);
    });

    test('togglePasswordVisibility flips showPassword', () {
      final c = makeContainer();
      expect(c.read(loginFormProvider).showPassword, isFalse);

      c.read(loginFormProvider.notifier).togglePasswordVisibility();
      expect(c.read(loginFormProvider).showPassword, isTrue);

      c.read(loginFormProvider.notifier).togglePasswordVisibility();
      expect(c.read(loginFormProvider).showPassword, isFalse);
    });

    test('setEmail does not affect password', () {
      final c = makeContainer();
      c.read(loginFormProvider.notifier).setPassword('mypass1');
      c.read(loginFormProvider.notifier).setEmail('x@y.com');
      expect(c.read(loginFormProvider).password, 'mypass1');
    });
  });
}
