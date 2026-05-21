import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:better_life_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:better_life_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';

/// Manages the authentication state machine.
///
/// Lifecycle:
/// - [build] returns [AuthInitial] and resolves dependencies.
/// - [bootstrap] MUST be called explicitly by [SplashScreen.initState].
///   It is not auto-invoked in [build] to keep the provider synchronous.
/// - [login] / [register] → [AuthLoading] → [AuthAuthenticated] | [AuthError].
/// - [logout] → [AuthUnauthenticated].
///
/// Invariant: [AuthError.previous] is NEVER an [AuthError] ([_flatten] enforces this).
class AuthNotifier extends Notifier<AuthState> {
  late final LoginUseCase _login;
  late final RegisterUseCase _register;
  late final IAuthRepository _repo;

  @override
  AuthState build() {
    _login = ref.read(loginUseCaseProvider);
    _register = ref.read(registerUseCaseProvider);
    _repo = ref.read(authRepositoryProvider);
    return const AuthInitial();
  }

  // ─────────────────────────────────────────────────── Bootstrap (Splash) ──

  /// Reads the stored token and transitions to [AuthAuthenticated] or
  /// [AuthUnauthenticated]. Called once by [SplashScreen.initState].
  ///
  /// On any exception, falls back to [AuthUnauthenticated] rather than
  /// leaving the app blocked on the splash screen.
  Future<void> bootstrap() async {
    try {
      final token = await _repo.currentToken();
      state = token == null
          ? const AuthUnauthenticated()
          : AuthAuthenticated(token);
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  /// Forces state to [AuthUnauthenticated]. Used only by the splash 5-second
  /// hard-timeout path when [bootstrap] hangs longer than expected.
  void markUnauthenticated() {
    if (state is AuthInitial) {
      state = const AuthUnauthenticated();
    }
  }

  // ─────────────────────────────────────────────────────────── Helpers ──

  /// Returns a non-[AuthError] state for use as [AuthError.previous].
  ///
  /// If current state is already an [AuthError], unwrap its [previous] to
  /// prevent nesting.
  AuthState _flatten(AuthState s) => s is AuthError ? s.previous : s;

  // ─────────────────────────────────────────────────────────── Actions ──

  /// Authenticates an existing user with [email] and [password].
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final prev = _flatten(state);
    state = const AuthLoading();
    try {
      final token = await _login(email: email, password: password);
      state = AuthAuthenticated(token);
    } on Failure catch (f) {
      state = AuthError(f, prev);
    } catch (e) {
      state = AuthError(UnknownFailure(e.toString()), prev);
    }
  }

  /// Registers a new user. Timezone is resolved by [RegisterUseCase].
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final prev = _flatten(state);
    state = const AuthLoading();
    try {
      final token = await _register(
        name: name,
        email: email,
        password: password,
      );
      state = AuthAuthenticated(token);
    } on Failure catch (f) {
      state = AuthError(f, prev);
    } catch (e) {
      state = AuthError(UnknownFailure(e.toString()), prev);
    }
  }

  /// Clears the stored token and emits [AuthUnauthenticated].
  Future<void> logout() async {
    await _repo.logout();
    state = const AuthUnauthenticated();
  }
}
