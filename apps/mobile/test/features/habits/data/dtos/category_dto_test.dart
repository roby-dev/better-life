import 'package:flutter_test/flutter_test.dart';

import 'package:better_life_app/features/habits/data/dtos/category_dto.dart';
import 'package:better_life_app/features/habits/domain/entities/category.dart';

void main() {
  group('CategoryDto.fromJson', () {
    test('parses all fields from valid JSON', () {
      final json = {
        'id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'name': 'Salud',
        'color': '#E26D5A',
        'icon': 'heart',
      };

      final dto = CategoryDto.fromJson(json);

      expect(dto.id, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
      expect(dto.name, 'Salud');
      expect(dto.color, '#E26D5A');
      expect(dto.icon, 'heart');
    });

    test('defaults color to empty string when null', () {
      final json = {
        'id': '1',
        'name': 'Test',
        'color': null,
        'icon': 'tag',
      };

      final dto = CategoryDto.fromJson(json);
      expect(dto.color, '');
    });

    test('defaults icon to empty string when null', () {
      final json = {
        'id': '1',
        'name': 'Test',
        'color': '#000000',
        'icon': null,
      };

      final dto = CategoryDto.fromJson(json);
      expect(dto.icon, '');
    });
  });

  group('CategoryDto.toEntity', () {
    test('converts DTO to Category entity', () {
      final dto = CategoryDto(
        id: 'a1b2c3d4',
        name: 'Salud',
        color: '#E26D5A',
        icon: 'heart',
      );

      final entity = dto.toEntity();

      expect(entity, isA<Category>());
      expect(entity.id, 'a1b2c3d4');
      expect(entity.name, 'Salud');
      expect(entity.color, '#E26D5A');
      expect(entity.icon, 'heart');
    });

    test('toEntity produces equal entities for equal DTOs', () {
      final a = CategoryDto(
        id: 'a1',
        name: 'Salud',
        color: '#E26D5A',
        icon: 'heart',
      );
      final b = CategoryDto(
        id: 'a1',
        name: 'Salud',
        color: '#E26D5A',
        icon: 'heart',
      );

      expect(a.toEntity(), equals(b.toEntity()));
    });
  });
}
