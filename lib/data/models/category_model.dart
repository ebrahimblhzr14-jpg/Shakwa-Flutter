class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String iconCode;
  final bool isActive;
  final int complaintsCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.iconCode = 'category',
    this.isActive = true,
    this.complaintsCount = 0,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconCode,
    bool? isActive,
    int? complaintsCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      isActive: isActive ?? this.isActive,
      complaintsCount: complaintsCount ?? this.complaintsCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconCode': iconCode,
      'isActive': isActive,
      'complaintsCount': complaintsCount,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconCode: json['iconCode'] as String? ?? 'category',
      isActive: json['isActive'] as bool? ?? true,
      complaintsCount: json['complaintsCount'] as int? ?? 0,
    );
  }
}
