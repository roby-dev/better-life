import 'package:better_life_app/features/habits/domain/entities/category.dart';
import 'package:better_life_app/features/habits/domain/repositories/i_habit_repository.dart';

/// Use case that fetches the list of categories.
class GetCategoriesUseCase {
  final IHabitRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<List<Category>> call() => _repository.getCategories();
}
