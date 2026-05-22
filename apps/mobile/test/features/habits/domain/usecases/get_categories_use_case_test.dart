import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/habits/domain/entities/category.dart';
import 'package:better_life_app/features/habits/domain/repositories/i_habit_repository.dart';
import 'package:better_life_app/features/habits/domain/usecases/get_categories_use_case.dart';

class MockHabitRepository extends Mock implements IHabitRepository {}

void main() {
  late MockHabitRepository repo;
  late GetCategoriesUseCase sut;

  setUp(() {
    repo = MockHabitRepository();
    sut = GetCategoriesUseCase(repo);
  });

  test('returns list of Categories on success', () async {
    final categories = [
      const Category(
        id: '1',
        name: 'Salud',
        color: '#E26D5A',
        icon: 'heart',
      ),
    ];
    when(() => repo.getCategories()).thenAnswer((_) async => categories);

    final result = await sut();

    expect(result, categories);
    verify(() => repo.getCategories()).called(1);
  });

  test('propagates Failure from repository', () async {
    when(() => repo.getCategories()).thenThrow(const NetworkFailure());

    expect(
      () => sut(),
      throwsA(isA<NetworkFailure>()),
    );
  });
}
