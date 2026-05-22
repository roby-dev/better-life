import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/features/habits/domain/entities/category.dart';

void main() {
  group('Category', () {
    const category = Category(
      id: 'a1b2c3d4',
      name: 'Salud',
      color: '#E26D5A',
      icon: 'heart',
    );

    test('stores all fields', () {
      expect(category.id, 'a1b2c3d4');
      expect(category.name, 'Salud');
      expect(category.color, '#E26D5A');
      expect(category.icon, 'heart');
    });

    test('two categories with same values are equal', () {
      const other = Category(
        id: 'a1b2c3d4',
        name: 'Salud',
        color: '#E26D5A',
        icon: 'heart',
      );
      expect(category, equals(other));
    });

    test('two categories with different values are not equal', () {
      const other = Category(
        id: 'a1b2c3d4',
        name: 'Productividad',
        color: '#E26D5A',
        icon: 'heart',
      );
      expect(category, isNot(equals(other)));
    });

    test('hashCode is consistent with equality', () {
      const other = Category(
        id: 'a1b2c3d4',
        name: 'Salud',
        color: '#E26D5A',
        icon: 'heart',
      );
      expect(category.hashCode, equals(other.hashCode));
    });
  });
}
