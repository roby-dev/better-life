/// Immutable domain entity holding dashboard statistics.
///
/// No Flutter imports — pure Dart entity.
class DashboardStats {
  final int totalHabits;
  final int completedToday;
  final int completedThisWeek;
  final int completedThisMonth;
  final int completionRate;

  const DashboardStats({
    required this.totalHabits,
    required this.completedToday,
    required this.completedThisWeek,
    required this.completedThisMonth,
    required this.completionRate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardStats &&
          runtimeType == other.runtimeType &&
          totalHabits == other.totalHabits &&
          completedToday == other.completedToday &&
          completedThisWeek == other.completedThisWeek &&
          completedThisMonth == other.completedThisMonth &&
          completionRate == other.completionRate;

  @override
  int get hashCode =>
      totalHabits.hashCode ^
      completedToday.hashCode ^
      completedThisWeek.hashCode ^
      completedThisMonth.hashCode ^
      completionRate.hashCode;

  @override
  String toString() =>
      'DashboardStats(totalHabits: $totalHabits, completedToday: $completedToday, '
      'completedThisWeek: $completedThisWeek, completedThisMonth: $completedThisMonth, '
      'completionRate: $completionRate)';
}