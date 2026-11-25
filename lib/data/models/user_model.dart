enum UserRole {
  user,
  admin,
  superAdmin;

  String get displayNameArabic {
    switch (this) {
      case UserRole.user:
        return 'مواطن / مستخدم';
      case UserRole.admin:
        return 'مشرف معالجة (Admin)';
      case UserRole.superAdmin:
        return 'مسؤول عام (SuperAdmin)';
    }
  }

  String get shortNameArabic {
    switch (this) {
      case UserRole.user:
        return 'مستخدم';
      case UserRole.admin:
        return 'مشرف';
      case UserRole.superAdmin:
        return 'مسؤول عام';
    }
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final String? department;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.department,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    String? department,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department ?? this.department,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'department': department,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.user,
      ),
      department: json['department'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
