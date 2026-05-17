import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';

/// Sealed state class for authentication flow.
///
/// State machine:
///   AuthInitial → (bootstrap) → AuthAuthenticated | AuthUnauthenticated
///   AuthUnauthenticated → (login/register) → AuthLoading → AuthAuthenticated | AuthError
///   AuthAuthenticated → (logout) → AuthUnauthenticated
///   AuthError.previous is ALWAYS a non-Error state (_flatten invariant).
sealed class AuthState {
  const AuthState();
}

/// Initial state before [AuthNotifier.bootstrap] has been called.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// In-flight state during login, register, or bootstrap.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated with a valid [AuthToken].
final class AuthAuthenticated extends AuthState {
  final AuthToken token;
  const AuthAuthenticated(this.token);
}

/// User is not authenticated (no stored token or explicit logout).
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An error occurred during an auth operation.
///
/// [previous] holds the pre-error state (guaranteed non-[AuthError]
/// by [AuthNotifier._flatten]).
final class AuthError extends AuthState {
  final Failure failure;
  final AuthState previous;
  const AuthError(this.failure, this.previous);
}
