import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:better_life_app/core/http/http_providers.dart';
import 'package:better_life_app/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:better_life_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:better_life_app/features/dashboard/domain/repositories/i_dashboard_repository.dart';
import 'package:better_life_app/features/dashboard/domain/usecases/get_dashboard_use_case.dart';
import 'package:better_life_app/features/dashboard/presentation/state/dashboard_notifier.dart';
import 'package:better_life_app/features/dashboard/presentation/state/dashboard_state.dart';

// ─────────────────────────────────────────────────── Data layer providers ──

/// Provides the Dio-backed [DashboardRemoteDataSource].
final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>(
  (ref) => DioDashboardRemoteDataSource(ref.watch(dioProvider)),
);

// ─────────────────────────────────────────── Domain / use-case providers ──

/// Provides the [IDashboardRepository] implementation.
final dashboardRepositoryProvider = Provider<IDashboardRepository>(
  (ref) => DashboardRepositoryImpl(
    remote: ref.watch(dashboardRemoteDataSourceProvider),
  ),
);

/// Provides [GetDashboardUseCase] backed by the dashboard repository.
final getDashboardUseCaseProvider = Provider<GetDashboardUseCase>(
  (ref) => GetDashboardUseCase(ref.watch(dashboardRepositoryProvider)),
);

// ─────────────────────────────────────────────────── State layer providers ──

/// Manages the dashboard state machine.
final dashboardNotifierProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);