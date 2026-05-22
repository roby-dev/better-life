import 'package:dio/dio.dart';

import 'package:better_life_app/features/habits/data/dtos/category_dto.dart';
import 'package:better_life_app/features/habits/data/dtos/habit_dto.dart';
import 'package:better_life_app/features/habits/data/dtos/upsert_habit_request_dto.dart';

/// Contract for the remote habit data source.
abstract class HabitRemoteDataSource {
  /// Fetches all habits. Returns a list of [HabitDto] on success.
  Future<List<HabitDto>> getHabits();

  /// Creates or updates a habit. Returns the resulting [HabitDto] on success.
  Future<HabitDto> upsertHabit(UpsertHabitRequestDto dto);

  /// Deletes a habit by its [id].
  Future<void> deleteHabit(String id);

  /// Fetches all categories for the current user.
  Future<List<CategoryDto>> getCategories();
}

/// Dio-backed implementation of [HabitRemoteDataSource].
class DioHabitRemoteDataSource implements HabitRemoteDataSource {
  static const _path = '/api/v1/habits';
  static const _categoriesPath = '/api/v1/categories';

  final Dio _dio;

  const DioHabitRemoteDataSource(this._dio);

  @override
  Future<List<HabitDto>> getHabits() async {
    final response = await _dio.get<List<dynamic>>(_path);
    final list = response.data!;
    return list
        .map((e) => HabitDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<HabitDto> upsertHabit(UpsertHabitRequestDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _path,
      data: dto.toJson(),
    );
    return HabitDto.fromJson(response.data!);
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _dio.delete<void>('$_path/$id');
  }

  @override
  Future<List<CategoryDto>> getCategories() async {
    final response = await _dio.get<List<dynamic>>(_categoriesPath);
    final list = response.data!;
    return list
        .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
