import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:better_life_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:better_life_app/features/auth/data/dtos/login_request_dto.dart';
import 'package:better_life_app/features/auth/data/dtos/register_request_dto.dart';
import 'package:better_life_app/core/error/failure.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late DioAuthRemoteDataSource sut;

  const baseUrl = 'http://localhost';
  const loginPath = '/api/v1/auth/login';
  const registerPath = '/api/v1/auth/register';
  const accessToken = 'eyJhbGciOiJIUzI1NiJ9.test';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    adapter = DioAdapter(dio: dio);
    sut = DioAuthRemoteDataSource(dio);
  });

  group('DioAuthRemoteDataSource.login', () {
    const dto = LoginRequestDto(email: 'user@test.com', password: 'secret1');

    test('returns AuthResponseDto on 200', () async {
      adapter.onPost(
        loginPath,
        (server) => server.reply(200, {'token': accessToken}),
        data: dto.toJson(),
      );

      final result = await sut.login(dto);
      expect(result.token, accessToken);
    });

    test('throws DioException on 401 (so ErrorInterceptor can wrap it)', () async {
      adapter.onPost(
        loginPath,
        (server) => server.reply(
          401,
          {'title': 'Credenciales inválidas'},
          headers: {'content-type': <String>['application/problem+json']},
        ),
        data: dto.toJson(),
      );

      // The datasource does NOT catch — it lets Dio (+ ErrorInterceptor) propagate.
      // In unit tests without the ErrorInterceptor, we get a raw DioException.
      expect(
        () => sut.login(dto),
        throwsA(isA<DioException>()),
      );
    });

    test('throws DioException on 500', () async {
      adapter.onPost(
        loginPath,
        (server) => server.reply(500, {'title': 'Internal Server Error'}),
        data: dto.toJson(),
      );

      expect(
        () => sut.login(dto),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('DioAuthRemoteDataSource.register', () {
    const dto = RegisterRequestDto(
      name: 'Ana',
      email: 'ana@test.com',
      password: 'Aa1!secret99',
      timeZone: 'America/Lima',
    );

    test('returns AuthResponseDto on 201', () async {
      adapter.onPost(
        registerPath,
        (server) => server.reply(201, {'token': accessToken}),
        data: dto.toJson(),
      );

      final result = await sut.register(dto);
      expect(result.token, accessToken);
    });

    test('throws DioException on 400 ValidationProblemDetails', () async {
      adapter.onPost(
        registerPath,
        (server) => server.reply(400, {
          'title': 'Validation error',
          'errors': {
            'Email': ['already exists'],
          },
        }),
        data: dto.toJson(),
      );

      expect(
        () => sut.register(dto),
        throwsA(isA<DioException>()),
      );
    });

    test('throws DioException on 409 conflict', () async {
      adapter.onPost(
        registerPath,
        (server) => server.reply(409, {'title': 'Email ya registrado'}),
        data: dto.toJson(),
      );

      expect(
        () => sut.register(dto),
        throwsA(isA<DioException>()),
      );
    });
  });
}

// Needed only to keep the import non-unused in the failure-test scenario
// where we assert on DioException (not Failure directly), since ErrorInterceptor
// is not wired in unit tests.
// ignore: unused_element
void _useFailure(Failure _) {}
