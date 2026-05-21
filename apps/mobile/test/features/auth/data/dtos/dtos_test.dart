import 'package:flutter_test/flutter_test.dart';
import 'package:better_life_app/features/auth/data/dtos/login_request_dto.dart';
import 'package:better_life_app/features/auth/data/dtos/register_request_dto.dart';
import 'package:better_life_app/features/auth/data/dtos/auth_response_dto.dart';

void main() {
  group('LoginRequestDto', () {
    test('toJson produces correct map', () {
      const dto = LoginRequestDto(email: 'user@example.com', password: 'secret');
      final json = dto.toJson();
      expect(json['email'], 'user@example.com');
      expect(json['password'], 'secret');
      expect(json.length, 2);
    });

    test('equality by value', () {
      const a = LoginRequestDto(email: 'a@b.com', password: 'pw');
      const b = LoginRequestDto(email: 'a@b.com', password: 'pw');
      const c = LoginRequestDto(email: 'x@b.com', password: 'pw');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('RegisterRequestDto', () {
    test('toJson produces correct map with all 4 fields', () {
      const dto = RegisterRequestDto(
        name: 'Ana',
        email: 'ana@test.com',
        password: 'Aa1!secret99',
        timeZone: 'America/Lima',
      );
      final json = dto.toJson();
      expect(json['name'], 'Ana');
      expect(json['email'], 'ana@test.com');
      expect(json['password'], 'Aa1!secret99');
      expect(json['timeZone'], 'America/Lima');
      expect(json.length, 4);
    });

    test('equality by value', () {
      const a = RegisterRequestDto(
          name: 'Ana', email: 'a@b.com', password: 'pw', timeZone: 'UTC');
      const b = RegisterRequestDto(
          name: 'Ana', email: 'a@b.com', password: 'pw', timeZone: 'UTC');
      expect(a, equals(b));
    });
  });

  group('AuthResponseDto', () {
    test('fromJson parses accessToken', () {
      final dto = AuthResponseDto.fromJson({'accessToken': 'eyJhbGciOi...'});
      expect(dto.accessToken, 'eyJhbGciOi...');
    });

    test('toEntity converts to AuthToken', () {
      final dto = AuthResponseDto.fromJson({'accessToken': 'tok123'});
      final token = dto.toEntity();
      expect(token.value, 'tok123');
    });
  });
}
