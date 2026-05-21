import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/features/dashboard/data/dtos/dashboard_response_dto.dart';
import 'package:better_life_app/features/dashboard/domain/entities/dashboard_stats.dart';

void main() {
  group('DashboardResponseDto', () {
    group('fromJson', () {
      test('parses all fields from valid JSON', () {
        final json = {
          'totalHabits': 5,
          'completedToday': 3,
          'completedThisWeek': 15,
          'completedThisMonth': 45,
          'completionRate': 60.0,
          'from': '2026-05-01',
          'to': '2026-05-21',
        };

        final dto = DashboardResponseDto.fromJson(json);

        expect(dto.totalHabits, 5);
        expect(dto.completedToday, 3);
        expect(dto.completedThisWeek, 15);
        expect(dto.completedThisMonth, 45);
        expect(dto.completionRate, 60);
      });

      test('handles integer completionRate without decimal', () {
        final json = {
          'totalHabits': 5,
          'completedToday': 3,
          'completedThisWeek': 15,
          'completedThisMonth': 45,
          'completionRate': 100,
        };

        final dto = DashboardResponseDto.fromJson(json);
        expect(dto.completionRate, 100);
      });

      test('ignores from and to fields', () {
        final json = {
          'totalHabits': 5,
          'completedToday': 3,
          'completedThisWeek': 15,
          'completedThisMonth': 45,
          'completionRate': 60.0,
          'from': '2026-05-01',
          'to': '2026-05-21',
        };

        final dto = DashboardResponseDto.fromJson(json);
        expect(dto.totalHabits, 5);
      });
    });

    group('toEntity', () {
      test('converts DTO to DashboardStats entity', () {
        const dto = DashboardResponseDto(
          totalHabits: 5,
          completedToday: 3,
          completedThisWeek: 15,
          completedThisMonth: 45,
          completionRate: 60,
        );

        final entity = dto.toEntity();

        expect(entity, isA<DashboardStats>());
        expect(entity.totalHabits, 5);
        expect(entity.completedToday, 3);
        expect(entity.completedThisWeek, 15);
        expect(entity.completedThisMonth, 45);
        expect(entity.completionRate, 60);
      });

      test('toEntity produces equal entities for equal DTOs', () {
        const a = DashboardResponseDto(
          totalHabits: 5,
          completedToday: 3,
          completedThisWeek: 15,
          completedThisMonth: 45,
          completionRate: 60,
        );
        const b = DashboardResponseDto(
          totalHabits: 5,
          completedToday: 3,
          completedThisWeek: 15,
          completedThisMonth: 45,
          completionRate: 60,
        );

        expect(a.toEntity(), equals(b.toEntity()));
      });
    });
  });
}