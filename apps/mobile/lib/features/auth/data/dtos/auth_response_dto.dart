import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';

/// DTO for the response body of both login and register endpoints.
///
/// Shape: { "token": "eyJ...", "expiresAtUtc": "...", "user": {...} }
class AuthResponseDto {
  final String token;

  const AuthResponseDto({required this.token});

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      AuthResponseDto(token: json['token'] as String);

  /// Converts this DTO into the domain [AuthToken] entity.
  AuthToken toEntity() => AuthToken(value: token);
}
