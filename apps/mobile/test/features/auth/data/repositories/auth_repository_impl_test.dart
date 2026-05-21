import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/core/storage/token_storage.dart';
import 'package:better_life_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:better_life_app/features/auth/data/dtos/auth_response_dto.dart';
import 'package:better_life_app/features/auth/data/dtos/login_request_dto.dart';
import 'package:better_life_app/features/auth/data/dtos/register_request_dto.dart';
import 'package:better_life_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:better_life_app/features/auth/domain/entities/auth_token.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource remote;
  late InMemoryTokenStorage storage;
  late AuthRepositoryImpl sut;

  const rawToken = 'eyJhbGciOiJIUzI1NiJ9.payload';
  const authToken = AuthToken(value: rawToken);
  final authResponseDto = AuthResponseDto(accessToken: rawToken);

  setUp(() {
    remote = MockAuthRemoteDataSource();
    storage = InMemoryTokenStorage();
    sut = AuthRepositoryImpl(remote: remote, storage: storage);
  });

  setUpAll(() {
    registerFallbackValue(
        const LoginRequestDto(email: '', password: ''));
    registerFallbackValue(
        const RegisterRequestDto(name: '', email: '', password: '', timeZone: ''));
  });

  // ────────────────────────────────────────────────────────── login ──

  group('AuthRepositoryImpl.login', () {
    test('success: delegates to datasource, persists token, returns AuthToken',
        () async {
      when(() => remote.login(any())).thenAnswer((_) async => authResponseDto);

      final result = await sut.login(email: 'u@e.com', password: 'pw123456');

      expect(result, authToken);
      // Token must be persisted in storage after login.
      expect(await storage.read(), rawToken);
    });

    test('login request dto contains correct email + password', () async {
      when(() => remote.login(any())).thenAnswer((_) async => authResponseDto);

      await sut.login(email: 'user@test.com', password: 'mypassword');

      final captured = verify(() => remote.login(captureAny())).captured;
      final dto = captured.first as LoginRequestDto;
      expect(dto.email, 'user@test.com');
      expect(dto.password, 'mypassword');
    });

    test('propagates AuthFailure when datasource throws DioException with AuthFailure',
        () async {
      const failure = AuthFailure(title: 'Credenciales inválidas', statusCode: 401);
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        error: failure,
      );
      when(() => remote.login(any())).thenThrow(dioEx);

      expect(
        () => sut.login(email: 'u@e.com', password: 'pw'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('propagates ValidationFailure when datasource throws DioException with ValidationFailure',
        () async {
      final failure = ValidationFailure(
        title: 'Validation error',
        errors: {
          'Email': ['already exists']
        },
      );
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        error: failure,
      );
      when(() => remote.login(any())).thenThrow(dioEx);

      expect(
        () => sut.login(email: 'u@e.com', password: 'pw'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('wraps bare DioException without Failure.error as UnknownFailure',
        () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        // error is null — no Failure set (e.g. connection error before interceptor runs)
      );
      when(() => remote.login(any())).thenThrow(dioEx);

      expect(
        () => sut.login(email: 'u@e.com', password: 'pw'),
        throwsA(isA<UnknownFailure>()),
      );
    });

    test('does not persist token on failure', () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        error: const AuthFailure(title: 'Bad', statusCode: 401),
      );
      when(() => remote.login(any())).thenThrow(dioEx);

      try {
        await sut.login(email: 'u@e.com', password: 'pw');
      } catch (_) {}

      expect(await storage.read(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────── register ──

  group('AuthRepositoryImpl.register', () {
    const name = 'Ana';
    const email = 'ana@test.com';
    const password = 'Aa1!secret99';
    const timeZone = 'America/Lima';

    test('success: delegates to datasource, persists token, returns AuthToken',
        () async {
      when(() => remote.register(any()))
          .thenAnswer((_) async => authResponseDto);

      final result = await sut.register(
          name: name, email: email, password: password, timeZone: timeZone);

      expect(result, authToken);
      expect(await storage.read(), rawToken);
    });

    test('register request dto contains all 4 fields', () async {
      when(() => remote.register(any()))
          .thenAnswer((_) async => authResponseDto);

      await sut.register(
          name: name, email: email, password: password, timeZone: timeZone);

      final captured = verify(() => remote.register(captureAny())).captured;
      final dto = captured.first as RegisterRequestDto;
      expect(dto.name, name);
      expect(dto.email, email);
      expect(dto.password, password);
      expect(dto.timeZone, timeZone);
    });

    test('propagates ValidationFailure on 400', () async {
      final failure = ValidationFailure(
        title: 'Validation error',
        errors: {'Email': ['already exists']},
      );
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/auth/register'),
        error: failure,
      );
      when(() => remote.register(any())).thenThrow(dioEx);

      expect(
        () => sut.register(
            name: name, email: email, password: password, timeZone: timeZone),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('propagates AuthFailure on 409', () async {
      const failure =
          AuthFailure(title: 'Email ya registrado', statusCode: 409);
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/auth/register'),
        error: failure,
      );
      when(() => remote.register(any())).thenThrow(dioEx);

      expect(
        () => sut.register(
            name: name, email: email, password: password, timeZone: timeZone),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  // ──────────────────────────────────────────────────────── logout ──

  group('AuthRepositoryImpl.logout', () {
    test('deletes stored token', () async {
      await storage.write(rawToken);
      await sut.logout();
      expect(await storage.read(), isNull);
    });

    test('is idempotent when no token stored', () async {
      // Should not throw
      await expectLater(sut.logout(), completes);
    });
  });

  // ─────────────────────────────────────────────────── currentToken ──

  group('AuthRepositoryImpl.currentToken', () {
    test('returns AuthToken when token exists in storage', () async {
      await storage.write(rawToken);
      final result = await sut.currentToken();
      expect(result, authToken);
    });

    test('returns null when storage is empty', () async {
      final result = await sut.currentToken();
      expect(result, isNull);
    });
  });
}
