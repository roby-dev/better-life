import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:better_life_app/features/auth/presentation/state/signup_form_state.dart';

/// Manages local form state for the Sign Up screen.
///
/// Has no external dependencies — pure [Notifier] with no provider reads in [build].
class SignUpFormNotifier extends Notifier<SignUpFormState> {
  @override
  SignUpFormState build() => const SignUpFormState();

  void setName(String value) {
    state = state.copyWith(
      name: value,
      touched: (
        name: true,
        email: state.touched.email,
        password: state.touched.password,
      ),
    );
  }

  void setEmail(String value) {
    state = state.copyWith(
      email: value,
      touched: (
        name: state.touched.name,
        email: true,
        password: state.touched.password,
      ),
    );
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      touched: (
        name: state.touched.name,
        email: state.touched.email,
        password: true,
      ),
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(showPassword: !state.showPassword);
  }
}
