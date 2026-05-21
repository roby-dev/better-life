import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:better_life_app/features/dashboard/domain/repositories/i_dashboard_repository.dart';
import 'package:better_life_app/features/dashboard/domain/usecases/get_dashboard_use_case.dart';

class MockIDashboardRepository extends Mock implements IDashboardRepository {}

void main() {
  late MockIDashboardRepository repo;
  late GetDashboardUseCase sut;

  const stats = DashboardStats(
    totalHabits: 5,
    completedToday: 3,
    completedThisWeek: 15,
    completedThisMonth: 45,
    completionRate: 60,
  );

  setUp(() {
    repo = MockIDashboardRepository();
    sut = GetDashboardUseCase(repo);
  });

  group('GetDashboardUseCase', () {
    test('returns DashboardStats on success', () async {
      when(() => repo.getDashboard()).thenAnswer((_) async => stats);

      final result = await sut.call();

      expect(result, stats);
    });

    test('delegates to repository — getDashboard() is called once', () async {
      when(() => repo.getDashboard()).thenAnswer((_) async => stats);

      await sut.call();

      verify(() => repo.getDashboard()).called(1);
    });

    test('propagates Failure subtypes from repository', () async {
      when(() => repo.getDashboard())
          .thenThrow(const NetworkFailure('No connection'));

      expect(
        () => sut.call(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}