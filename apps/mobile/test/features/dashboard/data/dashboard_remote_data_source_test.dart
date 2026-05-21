import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:better_life_app/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late DioDashboardRemoteDataSource sut;

  const baseUrl = 'http://localhost';
  const dashboardPath = '/api/v1/dashboard';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    adapter = DioAdapter(dio: dio);
    sut = DioDashboardRemoteDataSource(dio);
  });

  group('DioDashboardRemoteDataSource.getDashboard', () {
    test('returns DashboardResponseDto on 200', () async {
      adapter.onGet(
        dashboardPath,
        (server) => server.reply(200, {
          'totalHabits': 5,
          'completedToday': 3,
          'completedThisWeek': 15,
          'completedThisMonth': 45,
          'completionRate': 60.0,
          'from': '2026-05-01',
          'to': '2026-05-21',
        }),
      );

      final result = await sut.getDashboard();

      expect(result.totalHabits, 5);
      expect(result.completedToday, 3);
      expect(result.completedThisWeek, 15);
      expect(result.completedThisMonth, 45);
      expect(result.completionRate, 60);
    });

    test('throws DioException on 401 (so ErrorInterceptor can wrap it)', () async {
      adapter.onGet(
        dashboardPath,
        (server) => server.reply(401, {'title': 'Unauthorized'}),
      );

      expect(
        () => sut.getDashboard(),
        throwsA(isA<DioException>()),
      );
    });

    test('throws DioException on 500', () async {
      adapter.onGet(
        dashboardPath,
        (server) => server.reply(500, {'title': 'Internal Server Error'}),
      );

      expect(
        () => sut.getDashboard(),
        throwsA(isA<DioException>()),
      );
    });
  });
}

