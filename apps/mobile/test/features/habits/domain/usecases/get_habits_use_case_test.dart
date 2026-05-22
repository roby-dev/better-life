import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/habits/domain/entities/habit.dart';
import 'package:better_life_app/features/habits/domain/repositories/i_habit_repository.dart';
import 'package:better_life_app/features/habits/domain/usecases/get_habits_use_case.dart';

class MockHabitRepository extends Mock implements IHabitRepository {}

void main() {
  late MockHabitRepository repo;
  late GetHabitsUseCase sut;

  setUp(() {
    repo = MockHabitRepository();
    sut = GetHabitsUseCase(repo);
  });

  test('returns list of Habits on success', () async {
    final habits = [
      const Habit(
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
    when(() => repo.getHabits()).thenAnswer((_) async => habits);

    final result = await sut();

    expect(result, habits);
    verify(() => repo.getHabits()).called(1);
  });

  test('propagates Failure from repository', () async {
    when(() => repo.getHabits()).thenThrow(const NetworkFailure());

    expect(
      () => sut(),
      throwsA(isA<NetworkFailure>()),
    );
  });
}
