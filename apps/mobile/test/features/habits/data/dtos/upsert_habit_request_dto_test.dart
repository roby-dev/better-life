import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/features/habits/data/dtos/upsert_habit_request_dto.dart';

void main() {
  group('UpsertHabitRequestDto.toJson', () {
    test('create: produces JSON without id', () {
      final dto = UpsertHabitRequestDto(
        name: 'New Habit',
        categoryId: 'c1',
        frequencyType: 0,
        weekDays: 0,
        reminderTime: null,
      );

      final json = dto.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['name'], 'New Habit');
      expect(json['categoryId'], 'c1');
      expect(json['frequencyType'], 0);
      expect(json['weekDays'], 0);
      expect(json['reminderTime'], isNull);
    });

    test('update: produces JSON with id', () {
      final dto = UpsertHabitRequestDto(
        id: 'habit-1',
        name: 'Updated',
        categoryId: 'c2',
        frequencyType: 1,
        weekDays: 21,
        reminderTime: '08:30:00',
      );

      final json = dto.toJson();

      expect(json['id'], 'habit-1');
      expect(json['name'], 'Updated');
      expect(json['categoryId'], 'c2');
      expect(json['frequencyType'], 1);
      expect(json['weekDays'], 21);
      expect(json['reminderTime'], '08:30:00');
    });
  });
}
