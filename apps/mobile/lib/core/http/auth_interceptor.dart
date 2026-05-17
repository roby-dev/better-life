import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// Reads the JWT from [TokenStorage] on every request and injects it as
/// `Authorization: Bearer <token>`. No token is cached in memory so that
/// a freshly-deleted token is not re-used on subsequent requests.
class AuthInterceptor extends Interceptor {
  final TokenStorage _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
