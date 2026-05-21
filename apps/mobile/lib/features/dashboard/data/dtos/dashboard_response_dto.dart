import 'package:better_life_app/features/dashboard/domain/entities/dashboard_stats.dart';

/// DTO for the response body of GET /api/v1/dashboard.
///
/// Shape: { "totalHabits": 5, "completedToday": 3, "completedThisWeek": 15,
///          "completedThisMonth": 45, "completionRate": 60.0, "from": "2026-05-01",
///          "to": "2026-05-21" }
class DashboardResponseDto {
  final int totalHabits;
  final int completedToday;
  final int completedThisWeek;
  final int completedThisMonth;
  final int completionRate;

  const DashboardResponseDto({
    required this.totalHabits,
    required this.completedToday,
    required this.completedThisWeek,
    required this.completedThisMonth,
    required this.completionRate,
  });

  factory DashboardResponseDto.fromJson(Map<String, dynamic> json) =>
      DashboardResponseDto(
        totalHabits: json['totalHabits'] as int,
        completedToday: json['completedToday'] as int,
        completedThisWeek: json['completedThisWeek'] as int,
        completedThisMonth: json['completedThisMonth'] as int,
        completionRate: (json['completionRate'] as num).toInt(),
      );

  /// Converts this DTO into the domain [DashboardStats] entity.
  DashboardStats toEntity() => DashboardStats(
        totalHabits: totalHabits,
        completedToday: completedToday,
        completedThisWeek: completedThisWeek,
        completedThisMonth: completedThisMonth,
        completionRate: completionRate,
      );
}