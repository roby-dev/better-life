import 'package:better_life_app/features/habits/domain/entities/habit.dart';
import 'package:better_life_app/features/habits/domain/repositories/i_habit_repository.dart';

/// Use case that fetches the list of habits.
class GetHabitsUseCase {
  final IHabitRepository _repository;

  const GetHabitsUseCase(this._repository);

  Future<List<Habit>> call() => _repository.getHabits();
}
