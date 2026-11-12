class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String icon;
  final int color;
  final String type;
  final bool isDefault;
  final String createdAt;

  const CategoryModel({
    required this.id, required this.userId, required this.name,
    this.description, required this.icon, required this.color,
    required this.type, required this.isDefault, required this.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
    id: map['id'] as String, userId: map['user_id'] as String,
    name: map['name'] as String, description: map['description'] as String?,
    icon: map['icon'] as String, color: map['color'] as int,
    type: map['type'] as String, isDefault: (map['is_default'] as int) == 1,
    createdAt: map['created_at'] as String,
  );
}
