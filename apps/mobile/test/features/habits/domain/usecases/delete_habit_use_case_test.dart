import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/habits/domain/repositories/i_habit_repository.dart';
import 'package:better_life_app/features/habits/domain/usecases/delete_habit_use_case.dart';

class MockHabitRepository extends Mock implements IHabitRepository {}

void main() {
  late MockHabitRepository repo;
  late DeleteHabitUseCase sut;

  setUp(() {
    repo = MockHabitRepository();
    sut = DeleteHabitUseCase(repo);
  });

  test('completes on success', () async {
    when(() => repo.deleteHabit('1')).thenAnswer((_) async {});

    await sut('1');

    verify(() => repo.deleteHabit('1')).called(1);
  });

  test('propagates Failure from repository', () async {
    when(() => repo.deleteHabit('1')).thenThrow(const NetworkFailure());

    expect(
      () => sut('1'),
      throwsA(isA<NetworkFailure>()),
    );
  });
}
