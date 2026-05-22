import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/features/habits/domain/entities/week_day_utils.dart';

void main() {
  group('encodeWeekDays', () {
    test('returns 0 for empty list', () {
      expect(encodeWeekDays([]), 0);
    });

    test('returns correct bit flag for single day', () {
      expect(encodeWeekDays([1]), 1); // Monday
      expect(encodeWeekDays([2]), 2); // Tuesday
      expect(encodeWeekDays([7]), 64); // Sunday
    });

    test('returns correct sum for multiple days', () {
      expect(encodeWeekDays([1, 3, 5]), 21); // Mon + Wed + Fri
    });

    test('returns 127 for all days', () {
      expect(encodeWeekDays([1, 2, 3, 4, 5, 6, 7]), 127);
    });
  });

  group('decodeWeekDays', () {
    test('returns empty list for 0', () {
      expect(decodeWeekDays(0), []);
    });

    test('returns single day for single flag', () {
      expect(decodeWeekDays(1), [1]);
      expect(decodeWeekDays(2), [2]);
      expect(decodeWeekDays(64), [7]);
    });

    test('returns multiple days for combined flags', () {
      expect(decodeWeekDays(21), [1, 3, 5]);
    });

    test('returns all days for 127', () {
      expect(decodeWeekDays(127), [1, 2, 3, 4, 5, 6, 7]);
    });
  });

  group('encode/decode round-trip', () {
    test('round-trips 0', () {
      expect(decodeWeekDays(encodeWeekDays([])), []);
    });

    test('round-trips single day', () {
      expect(decodeWeekDays(encodeWeekDays([1])), [1]);
      expect(decodeWeekDays(encodeWeekDays([7])), [7]);
    });

    test('round-trips multiple days', () {
      expect(decodeWeekDays(encodeWeekDays([1, 3, 5])), [1, 3, 5]);
    });

    test('round-trips all days', () {
      expect(decodeWeekDays(encodeWeekDays([1, 2, 3, 4, 5, 6, 7])),
          [1, 2, 3, 4, 5, 6, 7]);
    });
  });

  group('timeOfDayToApi', () {
    test('returns null for null input', () {
      expect(timeOfDayToApi(null), isNull);
    });

    test('formats midnight', () {
      expect(timeOfDayToApi(const TimeOfDay(hour: 0, minute: 0)), '00:00:00');
    });

    test('formats 08:30', () {
      expect(timeOfDayToApi(const TimeOfDay(hour: 8, minute: 30)), '08:30:00');
    });

    test('formats 23:59', () {
      expect(timeOfDayToApi(const TimeOfDay(hour: 23, minute: 59)), '23:59:00');
    });
  });

  group('apiToTimeOfDay', () {
    test('returns null for null input', () {
      expect(apiToTimeOfDay(null), isNull);
    });

    test('parses midnight', () {
      final result = apiToTimeOfDay('00:00:00');
      expect(result, isNotNull);
      expect(result!.hour, 0);
      expect(result.minute, 0);
    });

    test('parses 08:30', () {
      final result = apiToTimeOfDay('08:30:00');
      expect(result, isNotNull);
      expect(result!.hour, 8);
      expect(result.minute, 30);
    });

    test('parses 23:59', () {
      final result = apiToTimeOfDay('23:59:00');
      expect(result, isNotNull);
      expect(result!.hour, 23);
      expect(result.minute, 59);
    });
  });
}
