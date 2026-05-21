import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/core/error/problem_details_parser.dart';
import 'package:better_life_app/core/http/error_interceptor.dart';

/// [ErrorInterceptor] stores the parsed [Failure] in [DioException.error].
/// Tests assert the [DioException.error] field carries the expected [Failure].
void main() {
  const parser = ProblemDetailsParser();
  late Dio dio;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.interceptors.add(ErrorInterceptor(parser));
  });

  /// Helper: assert [DioException.error] is [T] and return it.
  Future<T> catchFailure<T extends Failure>(Future<dynamic> future) async {
    try {
      await future;
      fail('Expected DioException but call succeeded');
    } on DioException catch (e) {
      expect(e.error, isA<T>(),
          reason: 'Expected DioException.error to be $T but was ${e.error}');
      return e.error as T;
    }
  }

  group('ErrorInterceptor', () {
    test('wraps connection error into NetworkFailure', () async {
      dio.httpClientAdapter = _ThrowingAdapter(
        type: DioExceptionType.connectionError,
      );

      final f = await catchFailure<NetworkFailure>(dio.get('/test'));
      expect(f, isA<NetworkFailure>());
    });

    test('wraps 401 into AuthFailure', () async {
      dio.httpClientAdapter = _ThrowingAdapter(
        type: DioExceptionType.badResponse,
        statusCode: 401,
        body: {'title': 'Unauthorized'},
      );

      final f = await catchFailure<AuthFailure>(dio.get('/test'));
      expect(f.statusCode, 401);
      expect(f.title, 'Unauthorized');
    });

    test('wraps 400 + errors into ValidationFailure', () async {
      dio.httpClientAdapter = _ThrowingAdapter(
        type: DioExceptionType.badResponse,
        statusCode: 400,
        body: {
          'title': 'Validation failed',
          'errors': {
            'Email': ['taken'],
          },
        },
      );

      final f = await catchFailure<ValidationFailure>(dio.get('/test'));
      expect(f.errors['Email'], ['taken']);
    });

    test('wraps 500 into ServerFailure', () async {
      dio.httpClientAdapter = _ThrowingAdapter(
        type: DioExceptionType.badResponse,
        statusCode: 500,
        body: {'title': 'Internal Server Error'},
      );

      final f = await catchFailure<ServerFailure>(dio.get('/test'));
      expect(f.statusCode, 500);
      expect(f.title, 'Internal Server Error');
    });
  });
}

class _ThrowingAdapter implements HttpClientAdapter {
  final DioExceptionType type;
  final int? statusCode;
  final Map<String, dynamic>? body;

  _ThrowingAdapter({
    this.type = DioExceptionType.connectionError,
    this.statusCode,
    this.body,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = statusCode == null
        ? null
        : Response(
            requestOptions: options,
            statusCode: statusCode,
            data: body,
          );
    throw DioException(
      requestOptions: options,
      type: type,
      response: response,
    );
  }

  @override
  void close({bool force = false}) {}
}
