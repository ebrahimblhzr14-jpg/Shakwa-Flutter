import '../../domain/entities/complaint_category.dart';

/// Data model representing Category DTO from ASP.NET Core API.
class ComplaintCategoryModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  const ComplaintCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });

  factory ComplaintCategoryModel.fromJson(Map<String, dynamic> json) {
    return ComplaintCategoryModel(
      id: json['id'] ?? json['Id'] ?? 0,
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      description: (json['description'] ?? json['Description'])?.toString(),
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }

  ComplaintCategory toEntity() {
    return ComplaintCategory(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
    );
  }
}
