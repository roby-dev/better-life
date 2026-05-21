import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/dashboard/domain/usecases/get_dashboard_use_case.dart';
import 'package:better_life_app/features/dashboard/presentation/providers.dart';
import 'package:better_life_app/features/dashboard/presentation/state/dashboard_state.dart';

/// Manages the dashboard state machine.
///
/// Lifecycle:
/// - [build] returns [DashboardInitial] and resolves dependencies.
/// - [load] MUST be called explicitly by [DashboardScreen.initState].
class DashboardNotifier extends Notifier<DashboardState> {
  late final GetDashboardUseCase _getDashboard;

  @override
  DashboardState build() {
    _getDashboard = ref.read(getDashboardUseCaseProvider);
    return const DashboardInitial();
  }

  /// Fetches dashboard stats from the backend.
  ///
  /// Transitions: DashboardInitial/DashboardError → DashboardLoading
  ///   → DashboardLoaded(stats) | DashboardError(failure)
  Future<void> load() async {
    state = const DashboardLoading();
    try {
      final stats = await _getDashboard();
      state = DashboardLoaded(stats);
    } on Failure catch (f) {
      state = DashboardError(f);
    } catch (e) {
      state = DashboardError(UnknownFailure(e.toString()));
    }
  }

  /// Retries the dashboard fetch — useful for the retry button.
  Future<void> retry() => load();
}