import 'package:better_life_app/features/dashboard/domain/entities/dashboard_stats.dart';

/// Repository contract for dashboard statistics.
///
/// All implementations live in the data layer. Pure Dart — no Flutter imports.
abstract class IDashboardRepository {
  /// Fetches the current dashboard statistics from the backend.
  ///
  /// Throws a [Failure] subtype on any error (network, server, etc.).
  Future<DashboardStats> getDashboard();
}