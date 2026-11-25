import 'package:equatable/equatable.dart';
import '../../../../data/models/user_model.dart';

/// Domain Entity representing a System User.
class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? imageUrl;
  final int roleId;
  final String roleName;
  final bool isActive;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.imageUrl,
    required this.roleId,
    required this.roleName,
    required this.isActive,
    required this.createdAt,
  });

  bool get isEmployee => roleId == 2 || roleName.toLowerCase() == 'admin';
  bool get isSuperAdmin =>
      roleId == 3 || roleName.toLowerCase() == 'superadmin';
  bool get isCitizen => roleId == 1 || roleName.toLowerCase() == 'user';

  UserRole get role {
    if (isSuperAdmin) return UserRole.superAdmin;
    if (isEmployee) return UserRole.admin;
    return UserRole.user;
  }

  UserModel toLegacyModel() {
    return UserModel(
      id: id.toString(),
      fullName: name,
      email: email,
      phone: phone ?? '',
      role: role,
      avatarUrl: imageUrl,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    imageUrl,
    roleId,
    roleName,
    isActive,
    createdAt,
  ];
}
