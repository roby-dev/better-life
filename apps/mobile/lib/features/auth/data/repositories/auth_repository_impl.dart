import 'package:dio/dio.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/core/storage/token_storage.dart';
import 'package:better_life_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:better_life_app/features/auth/data/dtos/login_request_dto.dart';
import 'package:better_life_app/features/auth/data/dtos/register_request_dto.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';
import 'package:better_life_app/features/auth/domain/repositories/i_auth_repository.dart';

/// Concrete implementation of [IAuthRepository].
///
/// Bridges the domain layer to the Dio-backed data source and [TokenStorage].
///
/// DioException unwrapping contract (established in S2):
///   [ErrorInterceptor] stores a typed [Failure] in [DioException.error].
///   This repository extracts it via `e.error as Failure?` — if the error is
///   already a [Failure], rethrow it directly. Otherwise wrap as [UnknownFailure].
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remote;
  final TokenStorage _storage;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required TokenStorage storage,
  })  : _remote = remote,
        _storage = storage;

  /// Unwraps a [DioException] produced by the error interceptor.
  ///
  /// Returns the wrapped [Failure] if present, or an [UnknownFailure] otherwise.
  Failure _unwrap(DioException e) {
    final wrapped = e.error;
    if (wrapped is Failure) return wrapped;
    return UnknownFailure(e.message ?? 'Unknown error');
  }

  @override
  Future<AuthToken> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = LoginRequestDto(email: email, password: password);
      final response = await _remote.login(dto);
      final token = response.toEntity();
      await _storage.write(token.value);
      return token;
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  @override
  Future<AuthToken> register({
    required String name,
    required String email,
    required String password,
    required String timeZone,
  }) async {
    try {
      final dto = RegisterRequestDto(
        name: name,
        email: email,
        password: password,
        timeZone: timeZone,
      );
      final response = await _remote.register(dto);
      final token = response.toEntity();
      await _storage.write(token.value);
      return token;
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete();
  }

  @override
  Future<AuthToken?> currentToken() async {
    final raw = await _storage.read();
    if (raw == null) return null;
    return AuthToken(value: raw);
  }
}
