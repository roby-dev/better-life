import 'package:dio/dio.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:better_life_app/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:better_life_app/features/dashboard/domain/repositories/i_dashboard_repository.dart';

/// Concrete implementation of [IDashboardRepository].
///
/// Bridges the domain layer to the Dio-backed data source.
///
/// DioException unwrapping contract:
///   [ErrorInterceptor] stores a typed [Failure] in [DioException.error].
///   This repository extracts it via `e.error as Failure?` — if the error is
///   already a [Failure], rethrow it directly. Otherwise wrap as [UnknownFailure].
class DashboardRepositoryImpl implements IDashboardRepository {
  final DashboardRemoteDataSource _remote;

  const DashboardRepositoryImpl({required DashboardRemoteDataSource remote})
      : _remote = remote;

  /// Unwraps a [DioException] produced by the error interceptor.
  ///
  /// Returns the wrapped [Failure] if present, or an [UnknownFailure] otherwise.
  Failure _unwrap(DioException e) {
    final wrapped = e.error;
    if (wrapped is Failure) return wrapped;
    return UnknownFailure(e.message ?? 'Unknown error');
  }

  @override
  Future<DashboardStats> getDashboard() async {
    try {
      final dto = await _remote.getDashboard();
      return dto.toEntity();
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }
}