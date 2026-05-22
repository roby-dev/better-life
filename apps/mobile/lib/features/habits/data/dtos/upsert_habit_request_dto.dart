/// Data transfer object for the upsert habit POST request body.
class UpsertHabitRequestDto {
  final String? id;
  final String name;
  final String categoryId;
  final int frequencyType;
  final int weekDays;
  final String? reminderTime;

  UpsertHabitRequestDto({
    this.id,
    required this.name,
    required this.categoryId,
    required this.frequencyType,
    required this.weekDays,
    this.reminderTime,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'categoryId': categoryId,
      'frequencyType': frequencyType,
      'weekDays': weekDays,
      'reminderTime': reminderTime,
    };
    if (id != null) {
      map['id'] = id!;
    }
    return map;
  }
}
