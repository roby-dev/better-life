import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_life_app/core/config/app_config.dart';
import 'package:better_life_app/core/error/problem_details_parser.dart';
import 'package:better_life_app/core/http/auth_interceptor.dart';
import 'package:better_life_app/core/http/dio_client.dart';
import 'package:better_life_app/core/http/error_interceptor.dart';
import 'package:better_life_app/core/storage/token_storage.dart';

void main() {
  group('DioClient.buildDio', () {
    late Dio dio;

    setUp(() {
      dio = buildDio(
        config: const AppConfig(apiBaseUrl: 'http://localhost:5000'),
        tokenStorage: InMemoryTokenStorage(),
        parser: const ProblemDetailsParser(),
      );
    });

    test('Dio instance is not null', () {
      expect(dio, isNotNull);
    });

    test('baseUrl is set from AppConfig', () {
      expect(dio.options.baseUrl, 'http://localhost:5000');
    });

    test('interceptors contain AuthInterceptor', () {
      final hasAuth = dio.interceptors.any((i) => i is AuthInterceptor);
      expect(hasAuth, isTrue);
    });

    test('interceptors contain ErrorInterceptor', () {
      final hasError = dio.interceptors.any((i) => i is ErrorInterceptor);
      expect(hasError, isTrue);
    });

    test('AuthInterceptor appears before ErrorInterceptor', () {
      final types = dio.interceptors.map((i) => i.runtimeType).toList();
      final authIdx  = types.indexOf(AuthInterceptor);
      final errorIdx = types.indexOf(ErrorInterceptor);
      expect(authIdx, lessThan(errorIdx));
    });

    test('connectTimeout is set', () {
      expect(dio.options.connectTimeout, isNotNull);
    });
  });
}
