import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:better_life_app/app/router/route_names.dart';
import 'package:better_life_app/core/theme/bl_tokens.dart';
import 'package:better_life_app/features/habits/domain/entities/category.dart';
import 'package:better_life_app/features/habits/domain/entities/week_day_utils.dart';
import 'package:better_life_app/features/habits/presentation/providers.dart';
import 'package:better_life_app/features/habits/presentation/state/habits_state.dart';

/// Displays the list of habits with FAB, pull-to-refresh, and swipe-to-delete.
class HabitsListScreen extends ConsumerStatefulWidget {
  const HabitsListScreen({super.key});

  @override
  ConsumerState<HabitsListScreen> createState() => _HabitsListScreenState();
}

class _HabitsListScreenState extends ConsumerState<HabitsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(habitsNotifierProvider.notifier).load();
      }
    });
  }

  String _frequencyLabel(int frequencyType, int weekDays) {
    return switch (frequencyType) {
      0 => 'Diario',
      1 => decodeWeekDays(weekDays).map((d) => _dayLabel(d)).join(', '),
      2 => 'Semanal',
      _ => 'Desconocido',
    };
  }

  String _dayLabel(int day) {
    return switch (day) {
      1 => 'Lun',
      2 => 'Mar',
      3 => 'Mie',
      4 => 'Jue',
      5 => 'Vie',
      6 => 'Sab',
      7 => 'Dom',
      _ => '',
    };
  }

  String _categoryName(String categoryId, List<Category> categories) {
    try {
      return categories.firstWhere((c) => c.id == categoryId).name;
    } catch (_) {
      return 'Sin categoría';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(habitsNotifierProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: BLColors.lightBgTop,
      body: SafeArea(
        key: const Key('habits_tab'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: BLSpacing.screenX,
                right: BLSpacing.screenX,
                top: BLSpacing.screenTop,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mis Hábitos',
                    style: BLType.h1.copyWith(color: BLColors.lightText),
                  ),
                  IconButton(
                    onPressed: () => context.pushNamed(RouteNames.dashboard),
                    icon: const Icon(Icons.dashboard_outlined),
                    color: BLColors.lightIconIdle,
                    tooltip: 'Dashboard',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildBody(state, categories),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('habits_fab'),
        onPressed: () => context.pushNamed(RouteNames.habitForm),
        backgroundColor: BLColors.lavender500,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(HabitsState state, List<Category> categories) {
    return switch (state) {
      HabitsInitial() || HabitsLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
      HabitsError(:final failure) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                failure.title,
                style: BLType.body.copyWith(color: BLColors.danger),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ref.read(habitsNotifierProvider.notifier).retry(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      HabitsLoaded(:final habits) => habits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: BLColors.lavender300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes hábitos todavía',
                    style: BLType.body.copyWith(color: BLColors.lightTextMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca + para crear uno',
                    style: BLType.caption.copyWith(color: BLColors.lightTextMuted),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(habitsNotifierProvider.notifier).load(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: BLSpacing.screenX),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  final catName = _categoryName(habit.categoryId, categories);
                  return Dismissible(
                    key: Key('habit_${habit.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: BLColors.danger,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) => _confirmDelete(context, habit.name),
                    onDismissed: (_) => ref.read(habitsNotifierProvider.notifier).delete(habit.id),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          habit.name,
                          style: BLType.body.copyWith(
                            color: BLColors.lightText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              catName,
                              style: BLType.caption.copyWith(
                                color: BLColors.lightTextMuted,
                              ),
                            ),
                            Text(
                              _frequencyLabel(habit.frequencyType, habit.weekDays),
                              style: BLType.caption.copyWith(
                                color: BLColors.lightTextMuted,
                              ),
                            ),
                            if (habit.reminderTime != null)
                              Text(
                                'Recordatorio: ${habit.reminderTime}',
                                style: BLType.caption.copyWith(
                                  color: BLColors.lavender500,
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => context.pushNamed(
                            RouteNames.habitForm,
                            queryParameters: {'id': habit.id},
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    };
  }

  Future<bool> _confirmDelete(BuildContext context, String habitName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Eliminar "$habitName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
