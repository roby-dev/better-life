import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/features/habits/data/dtos/habit_dto.dart';
import 'package:better_life_app/features/habits/domain/entities/habit.dart';

void main() {
  group('HabitDto.fromJson', () {
    test('parses all fields from valid JSON', () {
      final json = {
        'id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'userId': 'u1u2u3u4-u5u6-u7u8-u9u0-uuuuuuuuuuuu',
        'categoryId': 'c1c2c3c4-c5c6-c7c8-c9c0-cccccccccccc',
        'name': 'Read 30 min',
        'frequencyType': 1,
        'weekDays': 21,
        'reminderTime': '08:30:00',
        'status': 0,
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-02T00:00:00Z',
      };

      final dto = HabitDto.fromJson(json);

      expect(dto.id, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
      expect(dto.name, 'Read 30 min');
      expect(dto.frequencyType, 1);
      expect(dto.weekDays, 21);
      expect(dto.reminderTime, '08:30:00');
      expect(dto.status, 0);
    });

    test('defaults weekDays to 0 when null', () {
      final json = {
        'id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'userId': 'u1',
        'categoryId': 'c1',
        'name': 'Run',
        'frequencyType': 0,
        'weekDays': null,
        'reminderTime': null,
        'status': 0,
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-01T00:00:00Z',
      };

      final dto = HabitDto.fromJson(json);
      expect(dto.weekDays, 0);
    });

    test('defaults reminderTime to null when absent', () {
      final json = {
        'id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'userId': 'u1',
        'categoryId': 'c1',
        'name': 'Run',
        'frequencyType': 0,
        'weekDays': 0,
        'status': 0,
        'createdAt': '2026-01-01T00:00:00Z',
        'updatedAt': '2026-01-01T00:00:00Z',
      };

      final dto = HabitDto.fromJson(json);
      expect(dto.reminderTime, isNull);
    });
  });

  group('HabitDto.toEntity', () {
    test('converts DTO to Habit entity', () {
      final dto = HabitDto(
        id: 'a1b2c3d4',
        userId: 'u1',
        categoryId: 'c1',
        name: 'Read',
        frequencyType: 1,
        weekDays: 21,
        reminderTime: '08:30:00',
        status: 0,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

      final entity = dto.toEntity();

      expect(entity, isA<Habit>());
      expect(entity.id, 'a1b2c3d4');
      expect(entity.name, 'Read');
      expect(entity.frequencyType, 1);
      expect(entity.weekDays, 21);
      expect(entity.reminderTime, '08:30:00');
    });

    test('toEntity produces equal entities for equal DTOs', () {
      final a = HabitDto(
        id: 'a1',
        userId: 'u1',
        categoryId: 'c1',
        name: 'Read',
        frequencyType: 0,
        weekDays: 0,
        status: 0,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );
      final b = HabitDto(
        id: 'a1',
        userId: 'u1',
        categoryId: 'c1',
        name: 'Read',
        frequencyType: 0,
        weekDays: 0,
        status: 0,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

      expect(a.toEntity(), equals(b.toEntity()));
    });
  });
}
