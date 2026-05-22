import 'package:better_life_app/features/habits/domain/entities/category.dart';
import 'package:better_life_app/features/habits/domain/entities/habit.dart';

/// Contract for habit data access.
///
/// Implementations bridge the domain layer to concrete data sources (Dio, local DB, etc.).
abstract class IHabitRepository {
  /// Fetches all active habits for the authenticated user.
  Future<List<Habit>> getHabits();

  /// Creates or updates a habit (upsert semantics).
  Future<Habit> upsertHabit(Habit habit);

  /// Soft-deletes a habit by its [id].
  Future<void> deleteHabit(String id);

  /// Fetches all categories for the authenticated user.
  Future<List<Category>> getCategories();
}
