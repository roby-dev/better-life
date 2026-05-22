import 'package:dio/dio.dart';

import '../dtos/auth_response_dto.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/register_request_dto.dart';

/// Contract for the remote auth data source.
abstract class AuthRemoteDataSource {
  /// Sends login credentials. Returns [AuthResponseDto] on success.
  /// Propagates [DioException] on failure — callers (repository) unwrap it.
  Future<AuthResponseDto> login(LoginRequestDto dto);

  /// Sends registration payload. Returns [AuthResponseDto] on 201.
  /// Propagates [DioException] on failure — callers (repository) unwrap it.
  Future<AuthResponseDto> register(RegisterRequestDto dto);
}

/// Dio-backed implementation of [AuthRemoteDataSource].
class DioAuthRemoteDataSource implements AuthRemoteDataSource {
  static const _loginPath = '/api/v1/auth/login';
  static const _registerPath = '/api/v1/auth/register';

  final Dio _dio;

  const DioAuthRemoteDataSource(this._dio);

  @override
  Future<AuthResponseDto> login(LoginRequestDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _loginPath,
      data: dto.toJson(),
    );
    return AuthResponseDto.fromJson(response.data!);
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _registerPath,
      data: dto.toJson(),
    );
    return AuthResponseDto.fromJson(response.data!);
  }
}
