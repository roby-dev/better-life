import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:better_life_app/features/dashboard/data/dtos/dashboard_response_dto.dart';
import 'package:better_life_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:better_life_app/features/dashboard/domain/entities/dashboard_stats.dart';

class MockDashboardRemoteDataSource extends Mock
    implements DashboardRemoteDataSource {}

void main() {
  late MockDashboardRemoteDataSource remote;
  late DashboardRepositoryImpl sut;

  const stats = DashboardStats(
    totalHabits: 5,
    completedToday: 3,
    completedThisWeek: 15,
    completedThisMonth: 45,
    completionRate: 60,
  );
  final dto = DashboardResponseDto(
    totalHabits: 5,
    completedToday: 3,
    completedThisWeek: 15,
    completedThisMonth: 45,
    completionRate: 60,
  );

  setUp(() {
    remote = MockDashboardRemoteDataSource();
    sut = DashboardRepositoryImpl(remote: remote);
  });

  group('DashboardRepositoryImpl.getDashboard', () {
    test('success: delegates to datasource and returns DashboardStats', () async {
      when(() => remote.getDashboard()).thenAnswer((_) async => dto);

      final result = await sut.getDashboard();

      expect(result, stats);
      verify(() => remote.getDashboard()).called(1);
    });

    test('propagates NetworkFailure when datasource throws DioException with NetworkFailure',
        () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/v1/dashboard'),
        error: const NetworkFailure(),
      );
      when(() => remote.getDashboard()).thenThrow(dioEx);

      expect(
        () => sut.getDashboard(),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('propagates ServerFailure when datasource throws DioException with ServerFailure',
        () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/v1/dashboard'),
        error: const ServerFailure(title: 'Server error', statusCode: 500),
      );
      when(() => remote.getDashboard()).thenThrow(dioEx);

      expect(
        () => sut.getDashboard(),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('wraps bare DioException without Failure.error as UnknownFailure', () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/v1/dashboard'),
        // error is null — no Failure set
      );
      when(() => remote.getDashboard()).thenThrow(dioEx);

      expect(
        () => sut.getDashboard(),
        throwsA(isA<UnknownFailure>()),
      );
    });
  });
}