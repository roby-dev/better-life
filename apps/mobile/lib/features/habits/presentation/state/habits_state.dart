import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/habits/domain/entities/habit.dart';

/// Sealed state class for the habits screen.
///
/// State machine:
///   HabitsInitial → (initState load) → HabitsLoading
///   HabitsLoading → HabitsLoaded(habits) | HabitsError(failure)
sealed class HabitsState {
  const HabitsState();
}

/// Initial state before [HabitsNotifier.load] has been called.
final class HabitsInitial extends HabitsState {
  const HabitsInitial();
}

/// In-flight state while fetching habits.
final class HabitsLoading extends HabitsState {
  const HabitsLoading();
}

/// Habits loaded successfully.
final class HabitsLoaded extends HabitsState {
  final List<Habit> habits;
  const HabitsLoaded(this.habits);
}

/// An error occurred while fetching habits.
final class HabitsError extends HabitsState {
  final Failure failure;
  const HabitsError(this.failure);
}
