import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:better_life_app/features/auth/presentation/state/login_form_state.dart';

/// Manages local form state for the Login screen.
///
/// Has no external dependencies — pure [Notifier] with no provider reads in [build].
class LoginFormNotifier extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormState();

  void setEmail(String value) {
    state = state.copyWith(
      email: value,
      touched: (email: true, password: state.touched.password),
    );
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      touched: (email: state.touched.email, password: true),
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(showPassword: !state.showPassword);
  }
}
