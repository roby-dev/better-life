import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';

/// Authenticates an existing user.
///
/// Delegates directly to [IAuthRepository.login].
/// Throws a [Failure] subtype on any error (propagated from the repository).
class LoginUseCase {
  final IAuthRepository _repo;

  const LoginUseCase(this._repo);

  Future<AuthToken> call({
    required String email,
    required String password,
  }) =>
      _repo.login(email: email, password: password);
}
