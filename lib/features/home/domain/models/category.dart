class Category {
  final int id;
  final String name;
  final String? description;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final subList = json['sub_categories'] as List? ?? [];
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      subCategories: subList.map((s) => SubCategory.fromJson(s)).toList(),
    );
  }
}

class SubCategory {
  final int id;
  final int parentId;
  final String name;
  final String? description;

  SubCategory({
    required this.id,
    required this.parentId,
    required this.name,
    this.description,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] ?? 0,
      parentId: json['parent_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}
