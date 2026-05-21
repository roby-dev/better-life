import 'package:better_life_app/features/auth/domain/validators.dart';

/// Immutable form state for the Sign Up screen.
///
/// Computed properties ([nameOk], [emailOk], [passwordOk], [canSubmit]) are
/// derived from the field values on each access — no caching needed.
///
/// [passwordOk] uses [strengthOf] >= 2, NOT a raw length check.
class SignUpFormState {
  final String name;
  final String email;
  final String password;
  final bool showPassword;

  /// Which fields have been interacted with (for conditional error display).
  final ({bool name, bool email, bool password}) touched;

  const SignUpFormState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.showPassword = false,
    this.touched = (name: false, email: false, password: false),
  });

  bool get nameOk => nameValidator(name) == null;
  bool get emailOk => emailValidator(email) == null;

  /// Password is acceptable when strength score >= 2.
  ///
  /// This matches the Sign Up CTA enable rule defined in FR-003 / FR-013.
  bool get passwordOk => strengthOf(password) >= 2;

  bool get canSubmit => nameOk && emailOk && passwordOk;

  SignUpFormState copyWith({
    String? name,
    String? email,
    String? password,
    bool? showPassword,
    ({bool name, bool email, bool password})? touched,
  }) {
    return SignUpFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      showPassword: showPassword ?? this.showPassword,
      touched: touched ?? this.touched,
    );
  }
}
