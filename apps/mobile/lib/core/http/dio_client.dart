import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../error/problem_details_parser.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

/// Builds and configures the application [Dio] instance.
///
/// Interceptor order matters:
/// 1. [AuthInterceptor] — injects `Authorization` header on every request.
/// 2. [ErrorInterceptor] — maps [DioException] to typed [Failure] subtypes.
Dio buildDio({
  required AppConfig config,
  required TokenStorage tokenStorage,
  required ProblemDetailsParser parser,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors
    ..add(AuthInterceptor(tokenStorage))
    ..add(ErrorInterceptor(parser));

  return dio;
}
