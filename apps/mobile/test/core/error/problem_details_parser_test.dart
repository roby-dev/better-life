import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/core/error/problem_details_parser.dart';

DioException _makeException({
  int? statusCode,
  Map<String, dynamic>? body,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  final response = statusCode == null
      ? null
      : Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: statusCode,
          data: body,
        );
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    type: type,
    response: response,
  );
}

void main() {
  const parser = ProblemDetailsParser();

  group('ProblemDetailsParser.parse', () {
    test('no response → NetworkFailure', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      final result = parser.parse(e);
      expect(result, isA<NetworkFailure>());
    });

    test('400 + errors map → ValidationFailure', () {
      final e = _makeException(
        statusCode: 400,
        body: {
          'title': 'Validation failed',
          'errors': {
            'Email': ['Email already taken'],
          },
        },
      );
      final result = parser.parse(e);
      expect(result, isA<ValidationFailure>());
      final vf = result as ValidationFailure;
      expect(vf.errors['Email'], ['Email already taken']);
      expect(vf.title, 'Validation failed');
    });

    test('401 + title → AuthFailure with statusCode 401', () {
      final e = _makeException(
        statusCode: 401,
        body: {'title': 'Credenciales inválidas'},
      );
      final result = parser.parse(e);
      expect(result, isA<AuthFailure>());
      final af = result as AuthFailure;
      expect(af.title, 'Credenciales inválidas');
      expect(af.statusCode, 401);
    });

    test('409 + title → AuthFailure with statusCode 409', () {
      final e = _makeException(
        statusCode: 409,
        body: {'title': 'Este correo ya está registrado'},
      );
      final result = parser.parse(e);
      expect(result, isA<AuthFailure>());
      final af = result as AuthFailure;
      expect(af.title, 'Este correo ya está registrado');
      expect(af.statusCode, 409);
    });

    test('500 + title → ServerFailure', () {
      final e = _makeException(
        statusCode: 500,
        body: {'title': 'Internal Server Error'},
      );
      final result = parser.parse(e);
      expect(result, isA<ServerFailure>());
      final sf = result as ServerFailure;
      expect(sf.title, 'Internal Server Error');
      expect(sf.statusCode, 500);
    });

    test('400 without errors map → ServerFailure (unknown shape)', () {
      final e = _makeException(
        statusCode: 400,
        body: {'title': 'Bad Request'},
      );
      final result = parser.parse(e);
      // No errors map → treated as generic server error
      expect(result, isA<ServerFailure>());
    });

    test('null body on 500 → ServerFailure with fallback title', () {
      final e = _makeException(statusCode: 500, body: null);
      final result = parser.parse(e);
      expect(result, isA<ServerFailure>());
    });
  });
}
