import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/habits/domain/entities/habit.dart';
import 'package:better_life_app/features/habits/presentation/state/habits_state.dart';

void main() {
  group('HabitsState sealed class', () {
    test('HabitsInitial is a subtype of HabitsState', () {
      const state = HabitsInitial();
      expect(state, isA<HabitsState>());
    });

    test('HabitsLoading is a subtype of HabitsState', () {
      const state = HabitsLoading();
      expect(state, isA<HabitsState>());
    });

    test('HabitsLoaded carries the list of habits', () {
      const habits = [
        Habit(
          id: '1',
          userId: 'u1',
          categoryId: 'c1',
          name: 'Run',
          frequencyType: 0,
          weekDays: 0,
          status: 0,
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
        ),
      ];
      const state = HabitsLoaded(habits);
      expect(state.habits, habits);
    });

    test('HabitsError carries a Failure', () {
      const failure = NetworkFailure();
      const state = HabitsError(failure);
      expect(state.failure, failure);
    });
  });
}
