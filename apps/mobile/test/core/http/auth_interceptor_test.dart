import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_life_app/core/http/auth_interceptor.dart';
import 'package:better_life_app/core/storage/token_storage.dart';

/// Tests [AuthInterceptor] by wiring it into a real [Dio] instance
/// with a [MockAdapter] so we can inspect outgoing request headers.
void main() {
  group('AuthInterceptor', () {
    late InMemoryTokenStorage storage;
    late Dio dio;

    setUp(() {
      storage = InMemoryTokenStorage();
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.interceptors.add(AuthInterceptor(storage));
      dio.httpClientAdapter = _CapturingAdapter();
    });

    test('injects Authorization header when token is present', () async {
      await storage.write('test.jwt.token');

      final adapter = dio.httpClientAdapter as _CapturingAdapter;
      try {
        await dio.get('/api/test');
      } catch (_) {
        // We only care about headers; the adapter throws after capture.
      }

      expect(adapter.lastOptions?.headers['Authorization'],
          'Bearer test.jwt.token');
    });

    test('does not inject Authorization header when token is null', () async {
      final adapter = dio.httpClientAdapter as _CapturingAdapter;
      try {
        await dio.get('/api/test');
      } catch (_) {}

      expect(adapter.lastOptions?.headers.containsKey('Authorization'), isFalse);
    });

    test('reads token fresh on every request (no caching)', () async {
      final adapter = dio.httpClientAdapter as _CapturingAdapter;

      // First request — no token
      try { await dio.get('/api/first'); } catch (_) {}
      expect(adapter.lastOptions?.headers.containsKey('Authorization'), isFalse);

      // Write token then second request
      await storage.write('fresh.token');
      try { await dio.get('/api/second'); } catch (_) {}
      expect(adapter.lastOptions?.headers['Authorization'], 'Bearer fresh.token');
    });
  });
}

/// Captures the last [RequestOptions] then throws so the test chain stops.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.unknown,
      message: 'CapturingAdapter: intentional stop',
    );
  }

  @override
  void close({bool force = false}) {}
}
