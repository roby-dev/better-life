import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/habits/domain/entities/habit.dart';
import 'package:better_life_app/features/habits/domain/repositories/i_habit_repository.dart';
import 'package:better_life_app/features/habits/domain/usecases/upsert_habit_use_case.dart';

class MockHabitRepository extends Mock implements IHabitRepository {}

void main() {
  late MockHabitRepository repo;
  late UpsertHabitUseCase sut;

  const habit = Habit(
    id: '1',
    userId: 'u1',
    categoryId: 'c1',
    name: 'Read',
    frequencyType: 0,
    weekDays: 0,
    status: 0,
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
  );

  setUp(() {
    repo = MockHabitRepository();
    sut = UpsertHabitUseCase(repo);
  });

  test('returns Habit on success', () async {
    when(() => repo.upsertHabit(habit)).thenAnswer((_) async => habit);

    final result = await sut(habit);

    expect(result, habit);
    verify(() => repo.upsertHabit(habit)).called(1);
  });

  test('propagates Failure from repository', () async {
    when(() => repo.upsertHabit(habit)).thenThrow(const ServerFailure(title: 'err', statusCode: 500));

    expect(
      () => sut(habit),
      throwsA(isA<ServerFailure>()),
    );
  });
}
