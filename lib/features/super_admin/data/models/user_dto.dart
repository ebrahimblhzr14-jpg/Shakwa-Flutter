import '../../domain/entities/user_entity.dart';

/// DTO representing User from GET /api/Users/All and GET /api/Users/FindBy/{id}.
class UserDto {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? imageUrl;
  final int roleId;
  final String? roleName;
  final bool isActive;
  final DateTime createdAt;

  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.imageUrl,
    required this.roleId,
    this.roleName,
    required this.isActive,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'] ?? json['CreatedAt'];
    final parsedDate = rawDate != null
        ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
        : DateTime.now();

    return UserDto(
      id: json['id'] ?? json['Id'] ?? 0,
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      phone: (json['phone'] ?? json['Phone'])?.toString(),
      imageUrl: (json['imageUrl'] ?? json['ImageUrl'])?.toString(),
      roleId: json['roleId'] ?? json['RoleId'] ?? 1,
      roleName: (json['roleName'] ?? json['RoleName'])?.toString(),
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'roleId': roleId,
      'roleName': roleName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
      roleId: roleId,
      roleName:
          roleName ??
          (roleId == 2
              ? 'Admin'
              : roleId == 3
              ? 'SuperAdmin'
              : 'User'),
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}
