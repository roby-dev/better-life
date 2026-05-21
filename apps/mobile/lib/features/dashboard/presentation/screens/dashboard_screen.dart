import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/core/theme/bl_tokens.dart';
import 'package:better_life_app/core/widgets/bl_loader_bar.dart';
import 'package:better_life_app/core/widgets/bl_stat_card.dart';
import 'package:better_life_app/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:better_life_app/features/dashboard/presentation/providers.dart';
import 'package:better_life_app/features/dashboard/presentation/state/dashboard_state.dart';

/// Dashboard screen — shows habit-completion statistics.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule after build phase to avoid Riverpod "modify during build" error.
    Future.microtask(() {
      ref.read(dashboardNotifierProvider.notifier).load();
    });
  }

  void _retry() {
    ref.read(dashboardNotifierProvider.notifier).retry();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardNotifierProvider);

    return Scaffold(
      backgroundColor: BLColors.lightBgTop,
      appBar: AppBar(
        backgroundColor: BLColors.lightBgTop,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: BLColors.lightText,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Dashboard',
          style: BLType.h1.copyWith(
            color: BLColors.lightText,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: switch (state) {
          DashboardInitial() => const SizedBox.shrink(),
          DashboardLoading() => const Center(child: BLLoaderBar()),
          DashboardLoaded(:final stats) => _buildLoaded(stats),
          DashboardError(:final failure) => _buildError(failure),
        },
      ),
    );
  }

  Widget _buildLoaded(DashboardStats stats) {
    return ListView(
      padding: const EdgeInsets.all(BLSpacing.screenX),
      children: [
        BLStatCard(
          icon: Icons.check_circle_outline,
          label: 'Total de hábitos',
          value: '${stats.totalHabits}',
        ),
        const SizedBox(height: 16),
        BLStatCard(
          icon: Icons.today_outlined,
          label: 'Completados hoy',
          value: '${stats.completedToday}',
        ),
        const SizedBox(height: 16),
        BLStatCard(
          icon: Icons.date_range_outlined,
          label: 'Completados esta semana',
          value: '${stats.completedThisWeek}',
        ),
        const SizedBox(height: 16),
        BLStatCard(
          icon: Icons.calendar_month_outlined,
          label: 'Completados este mes',
          value: '${stats.completedThisMonth}',
        ),
        const SizedBox(height: 16),
        BLStatCard(
          icon: Icons.trending_up_rounded,
          label: 'Tasa de cumplimiento',
          value: '${stats.completionRate}%',
        ),
      ],
    );
  }

  Widget _buildError(Failure failure) {
    final title = failure is ServerFailure
        ? 'Error del servidor'
        : failure is NetworkFailure
            ? 'Sin conexión'
            : 'Algo salió mal';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BLSpacing.screenX),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: BLColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: BLType.h1.copyWith(
                color: BLColors.lightText,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _retry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}