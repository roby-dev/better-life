import 'package:better_life_app/features/habits/domain/entities/habit.dart';

/// Data transfer object for a habit response from the API.
class HabitDto {
  final String id;
  final String userId;
  final String categoryId;
  final String name;
  final int frequencyType;
  final int weekDays;
  final String? reminderTime;
  final int status;
  final String createdAt;
  final String updatedAt;

  HabitDto({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.name,
    required this.frequencyType,
    required this.weekDays,
    this.reminderTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HabitDto.fromJson(Map<String, dynamic> json) {
    return HabitDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      frequencyType: json['frequencyType'] as int,
      weekDays: (json['weekDays'] as int?) ?? 0,
      reminderTime: json['reminderTime'] as String?,
      status: json['status'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Habit toEntity() {
    return Habit(
      id: id,
      userId: userId,
      categoryId: categoryId,
      name: name,
      frequencyType: frequencyType,
      weekDays: weekDays,
      reminderTime: reminderTime,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
