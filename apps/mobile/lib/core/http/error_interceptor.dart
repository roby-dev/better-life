import 'package:dio/dio.dart';

import '../error/failure.dart';
import '../error/problem_details_parser.dart';

/// Converts every [DioException] into a typed [Failure] subtype via
/// [ProblemDetailsParser] and rejects with a [DioException] whose
/// [DioException.error] field carries the [Failure] instance.
///
/// Callers (repositories) unwrap it via:
/// ```dart
/// on DioException catch (e) {
///   final failure = e.error as Failure? ?? UnknownFailure(e.message ?? '');
///   ...
/// }
/// ```
class ErrorInterceptor extends Interceptor {
  final ProblemDetailsParser _parser;

  const ErrorInterceptor(this._parser);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = _parser.parse(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: failure,
        message: failure.title,
        stackTrace: err.stackTrace,
      ),
    );
  }
}
