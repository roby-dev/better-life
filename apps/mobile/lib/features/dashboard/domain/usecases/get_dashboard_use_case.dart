import 'package:better_life_app/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:better_life_app/features/dashboard/domain/repositories/i_dashboard_repository.dart';

/// Use case that fetches dashboard statistics.
///
/// Delegates to [IDashboardRepository] — a pure domain layer abstraction.
class GetDashboardUseCase {
  final IDashboardRepository _repository;

  const GetDashboardUseCase(this._repository);

  /// Calls [_repository.getDashboard] and returns the result.
  Future<DashboardStats> call() => _repository.getDashboard();
}