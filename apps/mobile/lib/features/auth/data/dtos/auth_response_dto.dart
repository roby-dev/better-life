import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';

/// DTO for the response body of both login and register endpoints.
///
/// Shape: { "accessToken": "eyJ..." }
class AuthResponseDto {
  final String accessToken;

  const AuthResponseDto({required this.accessToken});

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      AuthResponseDto(accessToken: json['accessToken'] as String);

  /// Converts this DTO into the domain [AuthToken] entity.
  AuthToken toEntity() => AuthToken(value: accessToken);
}
