import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/habits/domain/entities/habit.dart';
import 'package:better_life_app/features/habits/domain/usecases/delete_habit_use_case.dart';
import 'package:better_life_app/features/habits/domain/usecases/get_habits_use_case.dart';
import 'package:better_life_app/features/habits/domain/usecases/upsert_habit_use_case.dart';
import 'package:better_life_app/features/habits/presentation/providers.dart';
import 'package:better_life_app/features/habits/presentation/state/habits_state.dart';

/// Manages the habits state machine.
///
/// Lifecycle:
/// - [build] returns [HabitsInitial] and resolves dependencies.
/// - [load] MUST be called explicitly by [HabitsListScreen.initState].
class HabitsNotifier extends Notifier<HabitsState> {
  late final GetHabitsUseCase _getHabits;
  late final UpsertHabitUseCase _upsertHabit;
  late final DeleteHabitUseCase _deleteHabit;

  @override
  HabitsState build() {
    _getHabits = ref.read(getHabitsUseCaseProvider);
    _upsertHabit = ref.read(upsertHabitUseCaseProvider);
    _deleteHabit = ref.read(deleteHabitUseCaseProvider);
    return const HabitsInitial();
  }

  /// Fetches habits from the backend.
  ///
  /// Transitions: HabitsInitial/HabitsError → HabitsLoading
  ///   → HabitsLoaded(habits) | HabitsError(failure)
  Future<void> load() async {
    state = const HabitsLoading();
    try {
      final habits = await _getHabits();
      state = HabitsLoaded(habits);
    } on Failure catch (f) {
      state = HabitsError(f);
    } catch (e) {
      state = HabitsError(UnknownFailure(e.toString()));
    }
  }

  /// Retries the habits fetch — useful for the retry button.
  Future<void> retry() => load();

  /// Creates or updates a habit and re-fetches the list.
  Future<void> upsert(Habit habit) async {
    try {
      await _upsertHabit(habit);
      await load();
    } on Failure catch (f) {
      state = HabitsError(f);
    } catch (e) {
      state = HabitsError(UnknownFailure(e.toString()));
    }
  }

  /// Deletes a habit by its [id] and re-fetches the list.
  Future<void> delete(String id) async {
    try {
      await _deleteHabit(id);
      await load();
    } on Failure catch (f) {
      state = HabitsError(f);
    } catch (e) {
      state = HabitsError(UnknownFailure(e.toString()));
    }
  }
}
