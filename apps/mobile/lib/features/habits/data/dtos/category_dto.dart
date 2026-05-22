import 'package:better_life_app/features/habits/domain/entities/category.dart';

/// DTO for GET /api/v1/categories response.
class CategoryDto {
  final String id;
  final String name;
  final String color;
  final String icon;

  const CategoryDto({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) => CategoryDto(
        id: json['id'] as String,
        name: json['name'] as String,
        color: json['color'] as String? ?? '',
        icon: json['icon'] as String? ?? '',
      );

  Category toEntity() => Category(
        id: id,
        name: name,
        color: color,
        icon: icon,
      );
}
