/// Domain entity representing a user's habit.
class Habit {
  final String id;
  final String userId;
  final String categoryId;
  final String name;
  final int frequencyType; // 0=Daily, 1=SpecificWeekDays, 2=Weekly
  final int weekDays; // bit flags
  final String? reminderTime; // "HH:mm:ss" or null
  final int status;
  final String createdAt;
  final String updatedAt;

  const Habit({
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          categoryId == other.categoryId &&
          name == other.name &&
          frequencyType == other.frequencyType &&
          weekDays == other.weekDays &&
          reminderTime == other.reminderTime &&
          status == other.status &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        categoryId,
        name,
        frequencyType,
        weekDays,
        reminderTime,
        status,
        createdAt,
        updatedAt,
      );
}
