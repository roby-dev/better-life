import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/dashboard/domain/entities/dashboard_stats.dart';

/// Sealed state class for the dashboard screen.
///
/// State machine:
///   DashboardInitial → (initState load) → DashboardLoading
///   DashboardLoading → DashboardLoaded(stats) | DashboardError(failure)
sealed class DashboardState {
  const DashboardState();
}

/// Initial state before [DashboardNotifier.load] has been called.
final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// In-flight state while fetching dashboard statistics.
final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Dashboard statistics loaded successfully.
final class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  const DashboardLoaded(this.stats);
}

/// An error occurred while fetching dashboard statistics.
final class DashboardError extends DashboardState {
  final Failure failure;
  const DashboardError(this.failure);
}