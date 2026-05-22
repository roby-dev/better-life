/// Domain entity representing a habit category.
class Category {
  final String id;
  final String name;
  final String color; // hex string e.g. "#E26D5A"
  final String icon; // backend icon name e.g. "heart"

  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          color == other.color &&
          icon == other.icon;

  @override
  int get hashCode => Object.hash(id, name, color, icon);
}
