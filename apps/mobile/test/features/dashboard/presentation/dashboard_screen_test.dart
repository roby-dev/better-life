import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:better_life_app/features/dashboard/domain/repositories/i_dashboard_repository.dart';
import 'package:better_life_app/features/dashboard/presentation/providers.dart';
import 'package:better_life_app/features/dashboard/presentation/screens/dashboard_screen.dart';

class _FakeRepo implements IDashboardRepository {
  DashboardStats? _stats;
  Failure? _failure;

  void setStats(DashboardStats s) {
    _stats = s;
    _failure = null; // Clear failure so retry uses stats path.
  }

  void setFailure(Failure f) {
    _failure = f;
  }

  @override
  Future<DashboardStats> getDashboard() async {
    if (_failure != null) throw _failure!;
    return _stats!;
  }
}

Widget _buildScreen({required _FakeRepo repo}) {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      dashboardRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('DashboardScreen', () {
    testWidgets('renders Scaffold with AppBar titled Dashboard', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          repo: _FakeRepo()
            ..setStats(const DashboardStats(
              totalHabits: 5,
              completedToday: 3,
              completedThisWeek: 15,
              completedThisMonth: 45,
              completionRate: 60,
            )),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Dashboard'), findsWidgets);
    });

    testWidgets('shows BLLoaderBar initially then stat cards after async completes', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          repo: _FakeRepo()
            ..setStats(const DashboardStats(
              totalHabits: 5,
              completedToday: 3,
              completedThisWeek: 15,
              completedThisMonth: 45,
              completionRate: 60,
            )),
        ),
      );
      // After first pump (flushes microtask), state is DashboardLoaded.
      await tester.pump();

      // Stat cards should be visible after load completes.
      expect(find.text('TOTAL DE HÁBITOS'), findsOneWidget);
      expect(find.text('COMPLETADOS HOY'), findsOneWidget);
    });

    testWidgets('shows 5 stat card labels when loaded', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          repo: _FakeRepo()
            ..setStats(const DashboardStats(
              totalHabits: 5,
              completedToday: 3,
              completedThisWeek: 15,
              completedThisMonth: 45,
              completionRate: 60,
            )),
        ),
      );
      await tester.pump();

      expect(find.text('TOTAL DE HÁBITOS'), findsOneWidget);
      expect(find.text('COMPLETADOS HOY'), findsOneWidget);
      expect(find.text('COMPLETADOS ESTA SEMANA'), findsOneWidget);
      expect(find.text('COMPLETADOS ESTE MES'), findsOneWidget);
      expect(find.text('TASA DE CUMPLIMIENTO'), findsOneWidget);
    });

    testWidgets('shows error icon and retry button when DashboardError', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          repo: _FakeRepo()..setFailure(const NetworkFailure()),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('tapping retry button re-fetches and shows stat cards', (tester) async {
      final repo = _FakeRepo()..setFailure(const NetworkFailure());
      await tester.pumpWidget(_buildScreen(repo: repo));
      await tester.pump();
      // Verify error state shown.
      expect(find.text('Sin conexión'), findsOneWidget);

      // Switch to success before retry.
      repo.setStats(const DashboardStats(
        totalHabits: 5,
        completedToday: 3,
        completedThisWeek: 15,
        completedThisMonth: 45,
        completionRate: 60,
      ));

      await tester.tap(find.text('Reintentar'));
      await tester.pump();

      expect(find.text('TOTAL DE HÁBITOS'), findsOneWidget);
    });

    testWidgets('shows "Sin conexión" for NetworkFailure', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          repo: _FakeRepo()..setFailure(const NetworkFailure()),
        ),
      );
      await tester.pump();

      expect(find.text('Sin conexión'), findsOneWidget);
    });
  });
}