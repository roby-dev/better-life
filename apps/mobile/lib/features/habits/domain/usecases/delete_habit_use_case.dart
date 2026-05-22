import 'package:better_life_app/features/habits/domain/repositories/i_habit_repository.dart';

/// Use case that deletes a habit by its id.
class DeleteHabitUseCase {
  final IHabitRepository _repository;

  const DeleteHabitUseCase(this._repository);

  Future<void> call(String id) => _repository.deleteHabit(id);
}
