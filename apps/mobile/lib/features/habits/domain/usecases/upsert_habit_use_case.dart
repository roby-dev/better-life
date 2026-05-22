import 'package:better_life_app/features/habits/domain/entities/habit.dart';
import 'package:better_life_app/features/habits/domain/repositories/i_habit_repository.dart';

/// Use case that creates or updates a habit (upsert semantics).
class UpsertHabitUseCase {
  final IHabitRepository _repository;

  const UpsertHabitUseCase(this._repository);

  Future<Habit> call(Habit habit) => _repository.upsertHabit(habit);
}
