import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/signup_form_state.dart';

void main() {
  ProviderContainer makeContainer() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  group('SignUpFormState — computed properties', () {
    test('initial state: canSubmit is false', () {
      expect(const SignUpFormState().canSubmit, isFalse);
    });

    test('nameOk requires trimmed length >= 2', () {
      expect(const SignUpFormState(name: 'A').nameOk, isFalse);
      expect(const SignUpFormState(name: 'An').nameOk, isTrue);
      expect(const SignUpFormState(name: '  B  ').nameOk, isFalse); // trim → 1
      expect(const SignUpFormState(name: '  Bo ').nameOk, isTrue);  // trim → 2
    });

    test('emailOk validates email format', () {
      expect(const SignUpFormState(email: 'bad').emailOk, isFalse);
      expect(const SignUpFormState(email: 'a@b.com').emailOk, isTrue);
    });

    test('passwordOk uses strengthOf >= 2 (not length >= 8)', () {
      // "abcdefgh" → score 1 (length only) → NOT ok
      expect(const SignUpFormState(password: 'abcdefgh').passwordOk, isFalse);
      // "abcdefgh1" → score 2 (length + digit) → ok
      expect(const SignUpFormState(password: 'abcdefgh1').passwordOk, isTrue);
    });

    test('canSubmit requires all three fields valid', () {
      const state = SignUpFormState(
        name: 'Ana',
        email: 'ana@test.com',
        password: 'abcdefgh1',
      );
      expect(state.canSubmit, isTrue);
    });

    test('canSubmit is false when only name and email valid', () {
      const state = SignUpFormState(
        name: 'Ana',
        email: 'ana@test.com',
        password: 'abcdefgh', // score 1 only
      );
      expect(state.canSubmit, isFalse);
    });
  });

  group('SignUpFormNotifier', () {
    test('initial state is empty SignUpFormState', () {
      final c = makeContainer();
      final state = c.read(signUpFormProvider);
      expect(state.name, '');
      expect(state.email, '');
      expect(state.password, '');
      expect(state.showPassword, isFalse);
    });

    test('setName updates name and marks name as touched', () {
      final c = makeContainer();
      c.read(signUpFormProvider.notifier).setName('Ana');
      final state = c.read(signUpFormProvider);
      expect(state.name, 'Ana');
      expect(state.touched.name, isTrue);
    });

    test('setEmail updates email and marks email as touched', () {
      final c = makeContainer();
      c.read(signUpFormProvider.notifier).setEmail('a@b.com');
      final state = c.read(signUpFormProvider);
      expect(state.email, 'a@b.com');
      expect(state.touched.email, isTrue);
    });

    test('setPassword updates password and marks password as touched', () {
      final c = makeContainer();
      c.read(signUpFormProvider.notifier).setPassword('abc123!A');
      final state = c.read(signUpFormProvider);
      expect(state.password, 'abc123!A');
      expect(state.touched.password, isTrue);
    });

    test('togglePasswordVisibility flips showPassword', () {
      final c = makeContainer();
      expect(c.read(signUpFormProvider).showPassword, isFalse);

      c.read(signUpFormProvider.notifier).togglePasswordVisibility();
      expect(c.read(signUpFormProvider).showPassword, isTrue);

      c.read(signUpFormProvider.notifier).togglePasswordVisibility();
      expect(c.read(signUpFormProvider).showPassword, isFalse);
    });

    test('setName does not affect other fields', () {
      final c = makeContainer();
      c.read(signUpFormProvider.notifier).setEmail('x@y.com');
      c.read(signUpFormProvider.notifier).setName('Bob');
      final state = c.read(signUpFormProvider);
      expect(state.email, 'x@y.com');
      expect(state.name, 'Bob');
    });
  });
}
