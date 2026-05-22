import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:better_life_app/features/habits/data/dtos/category_dto.dart';
import 'package:better_life_app/features/habits/data/dtos/habit_dto.dart';
import 'package:better_life_app/features/habits/data/dtos/upsert_habit_request_dto.dart';
import 'package:better_life_app/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:better_life_app/features/habits/domain/entities/category.dart';
import 'package:better_life_app/features/habits/domain/entities/habit.dart';

class MockHabitRemoteDataSource extends Mock implements HabitRemoteDataSource {}

class FakeUpsertHabitRequestDto extends Fake implements UpsertHabitRequestDto {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUpsertHabitRequestDto());
  });

  late MockHabitRemoteDataSource remote;
  late HabitRepositoryImpl sut;

  final habit = Habit(
    id: 'h1',
    userId: 'u1',
    categoryId: 'c1',
    name: 'Run',
    frequencyType: 0,
    weekDays: 0,
    status: 0,
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
  );

  final dto = HabitDto(
    id: 'h1',
    userId: 'u1',
    categoryId: 'c1',
    name: 'Run',
    frequencyType: 0,
    weekDays: 0,
    status: 0,
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
  );

  setUp(() {
    remote = MockHabitRemoteDataSource();
    sut = HabitRepositoryImpl(remote: remote);
  });

  group('HabitRepositoryImpl.getHabits', () {
    test('success: delegates to datasource and returns list of Habits', () async {
      when(() => remote.getHabits()).thenAnswer((_) async => [dto]);

      final result = await sut.getHabits();

      expect(result.length, 1);
      expect(result.first.name, 'Run');
      verify(() => remote.getHabits()).called(1);
    });

    test('propagates NetworkFailure when datasource throws DioException with NetworkFailure',
        () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/v1/habits'),
        error: const NetworkFailure(),
      );
      when(() => remote.getHabits()).thenThrow(dioEx);

      expect(
        () => sut.getHabits(),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('propagates ServerFailure when datasource throws DioException with ServerFailure',
        () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/v1/habits'),
        error: const ServerFailure(title: 'Server error', statusCode: 500),
      );
      when(() => remote.getHabits()).thenThrow(dioEx);

      expect(
        () => sut.getHabits(),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('wraps bare DioException without Failure.error as UnknownFailure', () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/v1/habits'),
      );
      when(() => remote.getHabits()).thenThrow(dioEx);

      expect(
        () => sut.getHabits(),
        throwsA(isA<UnknownFailure>()),
      );
    });
  });

  group('HabitRepositoryImpl.upsertHabit', () {
    test('success: delegates to datasource and returns Habit', () async {
      when(() => remote.upsertHabit(any())).thenAnswer((_) async => dto);

      final result = await sut.upsertHabit(habit);

      expect(result.name, 'Run');
      verify(() => remote.upsertHabit(any())).called(1);
    });

    test('propagates Failure on DioException', () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/v1/habits'),
        error: const NetworkFailure(),
      );
      when(() => remote.upsertHabit(any())).thenThrow(dioEx);

      expect(
        () => sut.upsertHabit(habit),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('HabitRepositoryImpl.deleteHabit', () {
    test('success: delegates to datasource', () async {
      when(() => remote.deleteHabit('h1')).thenAnswer((_) async {});

      await sut.deleteHabit('h1');

      verify(() => remote.deleteHabit('h1')).called(1);
    });

    test('propagates Failure on DioException', () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/v1/habits/h1'),
        error: const ServerFailure(title: 'err', statusCode: 500),
      );
      when(() => remote.deleteHabit('h1')).thenThrow(dioEx);

      expect(
        () => sut.deleteHabit('h1'),
        throwsA(isA<ServerFailure>()),
      );
    });
  });

  group('HabitRepositoryImpl.getCategories', () {
    final categoryDto = CategoryDto(
      id: 'c1',
      name: 'Salud',
      color: '#E26D5A',
      icon: 'heart',
    );

    test('success: delegates to datasource and returns list of Categories', () async {
      when(() => remote.getCategories()).thenAnswer((_) async => [categoryDto]);

      final result = await sut.getCategories();

      expect(result.length, 1);
      expect(result.first, isA<Category>());
      expect(result.first.name, 'Salud');
      expect(result.first.color, '#E26D5A');
      expect(result.first.icon, 'heart');
      verify(() => remote.getCategories()).called(1);
    });

    test('propagates Failure on DioException', () async {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/api/v1/categories'),
        error: const NetworkFailure(),
      );
      when(() => remote.getCategories()).thenThrow(dioEx);

      expect(
        () => sut.getCategories(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
