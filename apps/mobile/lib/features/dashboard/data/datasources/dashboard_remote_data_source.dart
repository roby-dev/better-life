import 'package:dio/dio.dart';

import 'package:better_life_app/features/dashboard/data/dtos/dashboard_response_dto.dart';

/// Contract for the remote dashboard data source.
abstract class DashboardRemoteDataSource {
  /// Fetches dashboard stats. Returns [DashboardResponseDto] on success.
  /// Propagates [DioException] on failure — callers (repository) unwrap it.
  Future<DashboardResponseDto> getDashboard();
}

/// Dio-backed implementation of [DashboardRemoteDataSource].
class DioDashboardRemoteDataSource implements DashboardRemoteDataSource {
  static const _path = '/api/v1/dashboard';

  final Dio _dio;

  const DioDashboardRemoteDataSource(this._dio);

  @override
  Future<DashboardResponseDto> getDashboard() async {
    final response = await _dio.get<Map<String, dynamic>>(_path);
    return DashboardResponseDto.fromJson(response.data!);
  }
}