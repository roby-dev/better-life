import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';

/// Repository contract for authentication.
///
/// All implementations live in the data layer. Pure Dart — no Flutter imports.
abstract class IAuthRepository {
  /// Authenticates an existing user and returns an [AuthToken].
  ///
  /// Throws a [Failure] subtype on any error (network, auth, server, etc.).
  Future<AuthToken> login({
    required String email,
    required String password,
  });

  /// Registers a new user and returns an [AuthToken].
  ///
  /// [timeZone] is an IANA timezone string resolved by [TimezoneResolver].
  /// Throws a [Failure] subtype on error.
  Future<AuthToken> register({
    required String name,
    required String email,
    required String password,
    required String timeZone,
  });

  /// Deletes the stored token and signs the user out.
  Future<void> logout();

  /// Returns the currently stored [AuthToken], or `null` if none is present.
  ///
  /// Used by [AuthNotifier.bootstrap] on app launch.
  Future<AuthToken?> currentToken();
}
