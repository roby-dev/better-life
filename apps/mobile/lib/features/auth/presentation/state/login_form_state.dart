import 'package:better_life_app/features/auth/domain/validators.dart';

/// Immutable form state for the Login screen.
///
/// [passwordOk] uses `length >= 6` — the login rule from FR-013.
/// This is distinct from Sign Up which uses [strengthOf] >= 2.
class LoginFormState {
  final String email;
  final String password;
  final bool showPassword;

  /// Which fields have been interacted with (for conditional error display).
  final ({bool email, bool password}) touched;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.showPassword = false,
    this.touched = (email: false, password: false),
  });

  bool get emailOk => emailValidator(email) == null;

  /// Login requires a minimum of 6 characters (not a full strength score).
  bool get passwordOk => password.length >= 6;

  bool get canSubmit => emailOk && passwordOk;

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? showPassword,
    ({bool email, bool password})? touched,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      showPassword: showPassword ?? this.showPassword,
      touched: touched ?? this.touched,
    );
  }
}
