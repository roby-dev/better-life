import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/features/dashboard/domain/entities/dashboard_stats.dart';

void main() {
  group('DashboardStats', () {
    test('stores all five fields', () {
      const stats = DashboardStats(
        totalHabits: 5,
        completedToday: 3,
        completedThisWeek: 15,
        completedThisMonth: 45,
        completionRate: 60,
      );

      expect(stats.totalHabits, 5);
      expect(stats.completedToday, 3);
      expect(stats.completedThisWeek, 15);
      expect(stats.completedThisMonth, 45);
      expect(stats.completionRate, 60);
    });

    test('two stats with same values are equal', () {
      const a = DashboardStats(
        totalHabits: 5,
        completedToday: 3,
        completedThisWeek: 15,
        completedThisMonth: 45,
        completionRate: 60,
      );
      const b = DashboardStats(
        totalHabits: 5,
        completedToday: 3,
        completedThisWeek: 15,
        completedThisMonth: 45,
        completionRate: 60,
      );

      expect(a, equals(b));
    });

    test('two stats with different values are not equal', () {
      const a = DashboardStats(
        totalHabits: 5,
        completedToday: 3,
        completedThisWeek: 15,
        completedThisMonth: 45,
        completionRate: 60,
      );
      const b = DashboardStats(
        totalHabits: 10,
        completedToday: 3,
        completedThisWeek: 15,
        completedThisMonth: 45,
        completionRate: 60,
      );

      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent with equality', () {
      const a = DashboardStats(
        totalHabits: 5,
        completedToday: 3,
        completedThisWeek: 15,
        completedThisMonth: 45,
        completionRate: 60,
      );
      const b = DashboardStats(
        totalHabits: 5,
        completedToday: 3,
        completedThisWeek: 15,
        completedThisMonth: 45,
        completionRate: 60,
      );

      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString contains all field values', () {
      const stats = DashboardStats(
        totalHabits: 5,
        completedToday: 3,
        completedThisWeek: 15,
        completedThisMonth: 45,
        completionRate: 60,
      );

      final str = stats.toString();
      expect(str, contains('totalHabits: 5'));
      expect(str, contains('completedToday: 3'));
      expect(str, contains('completedThisWeek: 15'));
      expect(str, contains('completedThisMonth: 45'));
      expect(str, contains('completionRate: 60'));
    });
  });
}