import 'package:dio/dio.dart';

import 'package:better_life_app/core/error/failure.dart';
import 'package:better_life_app/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:better_life_app/features/habits/data/dtos/upsert_habit_request_dto.dart';
import 'package:better_life_app/features/habits/domain/entities/category.dart';
import 'package:better_life_app/features/habits/domain/entities/habit.dart';
import 'package:better_life_app/features/habits/domain/repositories/i_habit_repository.dart';

/// Concrete implementation of [IHabitRepository].
///
/// Bridges the domain layer to the Dio-backed data source.
class HabitRepositoryImpl implements IHabitRepository {
  final HabitRemoteDataSource _remote;

  const HabitRepositoryImpl({required HabitRemoteDataSource remote})
      : _remote = remote;

  Failure _unwrap(DioException e) {
    final wrapped = e.error;
    if (wrapped is Failure) return wrapped;
    return UnknownFailure(e.message ?? 'Unknown error');
  }

  @override
  Future<List<Habit>> getHabits() async {
    try {
      final dtos = await _remote.getHabits();
      return dtos.map((d) => d.toEntity()).toList();
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  @override
  Future<Habit> upsertHabit(Habit habit) async {
    try {
      final dto = UpsertHabitRequestDto(
        id: habit.id,
        name: habit.name,
        categoryId: habit.categoryId,
        frequencyType: habit.frequencyType,
        weekDays: habit.weekDays,
        reminderTime: habit.reminderTime,
      );
      final result = await _remote.upsertHabit(dto);
      return result.toEntity();
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      await _remote.deleteHabit(id);
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final dtos = await _remote.getCategories();
      return dtos.map((d) => d.toEntity()).toList();
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }
}
