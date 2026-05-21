import 'package:better_life_app/core/platform/timezone_resolver.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';

/// Registers a new user.
///
/// Resolves the device IANA timezone via [TimezoneResolver] before delegating
/// to [IAuthRepository.register]. The timezone is always included in the
/// server payload — fallback to `"America/Lima"` is handled by the resolver.
///
/// Throws a [Failure] subtype on any error (propagated from the repository).
class RegisterUseCase {
  final IAuthRepository _repo;
  final TimezoneResolver _tz;

  const RegisterUseCase(this._repo, this._tz);

  Future<AuthToken> call({
    required String name,
    required String email,
    required String password,
  }) async {
    final timeZone = await _tz.resolve();
    return _repo.register(
      name: name,
      email: email,
      password: password,
      timeZone: timeZone,
    );
  }
}
