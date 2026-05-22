import 'package:flutter/material.dart';

/// Encodes a list of weekday indices (1=Mon … 7=Sun) into bit flags.
///
/// Flags: Mon=1, Tue=2, Wed=4, Thu=8, Fri=16, Sat=32, Sun=64
/// Example: `[1, 3, 5]` → `21` (Mon + Wed + Fri)
int encodeWeekDays(List<int> days) {
  var result = 0;
  for (final day in days) {
    if (day >= 1 && day <= 7) {
      result |= 1 << (day - 1);
    }
  }
  return result;
}

/// Decodes an integer bit flag into weekday indices (1=Mon … 7=Sun).
///
/// Flags: Mon=1, Tue=2, Wed=4, Thu=8, Fri=16, Sat=32, Sun=64
/// Example: `21` → `[1, 3, 5]` (Mon + Wed + Fri)
List<int> decodeWeekDays(int flags) {
  final days = <int>[];
  for (var i = 0; i < 7; i++) {
    if (flags & (1 << i) != 0) days.add(i + 1);
  }
  return days;
}

/// Converts a [TimeOfDay] to an API time string "HH:mm:ss".
String? timeOfDayToApi(TimeOfDay? t) {
  if (t == null) return null;
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
}

/// Parses an API time string "HH:mm:ss" into a [TimeOfDay].
TimeOfDay? apiToTimeOfDay(String? s) {
  if (s == null) return null;
  final parts = s.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}
