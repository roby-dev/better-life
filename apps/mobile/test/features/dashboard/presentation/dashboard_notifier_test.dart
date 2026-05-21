import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:better_life_app/features/dashboard/domain/repositories/i_dashboard_repository.dart';
import 'package:better_life_app/features/dashboard/presentation/providers.dart';
import 'package:better_life_app/features/dashboard/presentation/state/dashboard_state.dart';

class _FakeRepo implements IDashboardRepository {
  DashboardStats? _stats;
  Failure? _failure;

  void setStats(DashboardStats s) => _stats = s;
  void setFailure(Failure f) => _failure = f;

  @override
  Future<DashboardStats> getDashboard() async {
    if (_failure != null) throw _failure!;
    return _stats!;
  }
}

ProviderContainer _makeContainer(_FakeRepo repo) {
  return ProviderContainer(
    overrides: [
      dashboardRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

void main() {
  group('DashboardNotifier — initial state', () {
    test('starts as DashboardInitial', () {
      final repo = _FakeRepo()..setStats(const DashboardStats(
        totalHabits: 5,
        completedToday: 3,
        completedThisWeek: 15,
        completedThisMonth: 45,
        completionRate: 60,
      ));
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      expect(container.read(dashboardNotifierProvider), isA<DashboardInitial>());
    });
  });

  group('DashboardNotifier — load()', () {
    test('transitions DashboardInitial → DashboardLoading → DashboardLoaded on success',
        () async {
      const stats = DashboardStats(
        totalHabits: 5,
        completedToday: 3,
        completedThisWeek: 15,
        completedThisMonth: 45,
        completionRate: 60,
      );
      final repo = _FakeRepo()..setStats(stats);
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      final states = <DashboardState>[];
      container.listen(dashboardNotifierProvider, (_, next) => states.add(next),
          fireImmediately: false);

      await container.read(dashboardNotifierProvider.notifier).load();

      expect(states[0], isA<DashboardLoading>());
      expect(states[1], isA<DashboardLoaded>());
      expect((states[1] as DashboardLoaded).stats, stats);
    });

    test('transitions DashboardInitial → DashboardLoading → DashboardError on NetworkFailure',
        () async {
      final repo = _FakeRepo()..setFailure(const NetworkFailure());
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(dashboardNotifierProvider.notifier).load();

      final state = container.read(dashboardNotifierProvider);
      expect(state, isA<DashboardError>());
      expect((state as DashboardError).failure, isA<NetworkFailure>());
    });

    test('transitions to DashboardError on ServerFailure', () async {
      final repo = _FakeRepo()
        ..setFailure(const ServerFailure(title: 'Server error', statusCode: 500));
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(dashboardNotifierProvider.notifier).load();

      final state = container.read(dashboardNotifierProvider);
      expect(state, isA<DashboardError>());
      expect((state as DashboardError).failure, isA<ServerFailure>());
    });

    test('wraps generic exception as UnknownFailure', () async {
      final repo = _FakeRepo()..setFailure(const UnknownFailure('oops'));
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(dashboardNotifierProvider.notifier).load();

      final state = container.read(dashboardNotifierProvider);
      expect(state, isA<DashboardError>());
      expect((state as DashboardError).failure, isA<UnknownFailure>());
    });
  });

  group('DashboardNotifier — retry()', () {
    test('retry re-fetches from the repository', () async {
      const stats = DashboardStats(
        totalHabits: 5,
        completedToday: 3,
        completedThisWeek: 15,
        completedThisMonth: 45,
        completionRate: 60,
      );
      final repo = _FakeRepo()..setStats(stats);
      final container = _makeContainer(repo);
      addTearDown(container.dispose);

      await container.read(dashboardNotifierProvider.notifier).retry();

      final state = container.read(dashboardNotifierProvider);
      expect(state, isA<DashboardLoaded>());
    });
  });
}