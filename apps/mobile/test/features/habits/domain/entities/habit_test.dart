import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/features/habits/domain/entities/habit.dart';

void main() {
  group('Habit', () {
    const habit = Habit(
      id: 'a1b2c3d4',
      userId: 'u1u2u3u4',
      categoryId: 'c1c2c3c4',
      name: 'Read 30 min',
      frequencyType: 0,
      weekDays: 0,
      reminderTime: null,
      status: 0,
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-02T00:00:00Z',
    );

    test('stores all fields', () {
      expect(habit.id, 'a1b2c3d4');
      expect(habit.name, 'Read 30 min');
      expect(habit.frequencyType, 0);
      expect(habit.weekDays, 0);
      expect(habit.reminderTime, isNull);
    });

    test('two habits with same values are equal', () {
      const other = Habit(
        id: 'a1b2c3d4',
        userId: 'u1u2u3u4',
        categoryId: 'c1c2c3c4',
        name: 'Read 30 min',
        frequencyType: 0,
        weekDays: 0,
        reminderTime: null,
        status: 0,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-02T00:00:00Z',
      );
      expect(habit, equals(other));
    });

    test('two habits with different values are not equal', () {
      const other = Habit(
        id: 'a1b2c3d4',
        userId: 'u1u2u3u4',
        categoryId: 'c1c2c3c4',
        name: 'Different name',
        frequencyType: 0,
        weekDays: 0,
        reminderTime: null,
        status: 0,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-02T00:00:00Z',
      );
      expect(habit, isNot(equals(other)));
    });

    test('hashCode is consistent with equality', () {
      const other = Habit(
        id: 'a1b2c3d4',
        userId: 'u1u2u3u4',
        categoryId: 'c1c2c3c4',
        name: 'Read 30 min',
        frequencyType: 0,
        weekDays: 0,
        reminderTime: null,
        status: 0,
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-02T00:00:00Z',
      );
      expect(habit.hashCode, equals(other.hashCode));
    });
  });
}
