import 'package:dio/dio.dart';

import 'failure.dart';

class ProblemDetailsParser {
  const ProblemDetailsParser();

  Failure parse(DioException e) {
    final response = e.response;

    // No HTTP response at all → network / connectivity issue
    if (response == null) {
      return const NetworkFailure();
    }

    final status = response.statusCode ?? 0;
    final body   = response.data;

    // Extract title safely
    String titleFrom(Map<String, dynamic> map) =>
        (map['title'] as String?) ?? 'Error';

    // 400 + errors map → ValidationProblemDetails
    if (status == 400 && body is Map<String, dynamic>) {
      final errors = body['errors'];
      if (errors is Map) {
        final typedErrors = errors.map<String, List<String>>(
          (k, v) => MapEntry(
            k.toString(),
            (v as List).map((m) => m.toString()).toList(),
          ),
        );
        return ValidationFailure(
          title: titleFrom(body),
          errors: typedErrors,
        );
      }
    }

    // 401 / 409 → AuthFailure
    if (status == 401 || status == 409) {
      final title = body is Map<String, dynamic>
          ? titleFrom(body)
          : 'Error de autenticación';
      return AuthFailure(title: title, statusCode: status);
    }

    // Everything else (4xx non-validation, 5xx, unknown) → ServerFailure
    final title = body is Map<String, dynamic>
        ? titleFrom(body)
        : 'Error del servidor';
    return ServerFailure(title: title, statusCode: status);
  }
}
