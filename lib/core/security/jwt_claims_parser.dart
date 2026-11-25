import 'dart:convert';

/// Normalized user security roles.
enum UserRole {
  user,
  admin,
  superAdmin;

  static UserRole fromString(String? role) {
    switch (role?.trim().toLowerCase()) {
      case 'superadmin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      case 'citizen':
      case 'user':
        return UserRole.user;
      default:
        return UserRole.user;
    }
  }

  bool get isAdmin => this == UserRole.admin || this == UserRole.superAdmin;
  bool get isSuperAdmin => this == UserRole.superAdmin;
}

/// Decoded claims model extracted from JWT payload.
/// Note: Decoded claims are strictly for client UI guidance and navigation.
/// The ASP.NET Core backend is authoritative for identity and permissions.
class JwtClaims {
  final int userId;
  final String fullName;
  final String email;
  final UserRole role;
  final DateTime expiresAt;

  const JwtClaims({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Safe client-side JWT parser.
class JwtClaimsParser {
  static JwtClaims? tryParse(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final normalizedPayload = base64Url.normalize(parts[1]);
      final payloadBytes = base64Url.decode(normalizedPayload);
      final payloadString = utf8.decode(payloadBytes);
      final dynamic rawDecoded = jsonDecode(payloadString);

      if (rawDecoded is! Map<String, dynamic>) return null;
      final data = rawDecoded;

      // User ID extraction from standard nameid claim or XML schema URI
      final idRaw =
          data['nameid'] ??
          data['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
      if (idRaw == null) return null;

      final userId = int.tryParse(idRaw.toString());
      if (userId == null || userId <= 0) return null;

      // Full Name
      final nameRaw =
          data['unique_name'] ??
          data['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ??
          '';

      // Email
      final emailRaw =
          data['email'] ??
          data['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ??
          '';

      // Role
      final roleRaw =
          data['role'] ??
          data['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
      final role = UserRole.fromString(roleRaw?.toString());

      // Expiration (epoch seconds)
      DateTime expiresAt;
      final expVal = data['exp'];
      if (expVal is int) {
        expiresAt = DateTime.fromMillisecondsSinceEpoch(
          expVal * 1000,
          isUtc: true,
        ).toLocal();
      } else if (expVal is String && int.tryParse(expVal) != null) {
        expiresAt = DateTime.fromMillisecondsSinceEpoch(
          int.parse(expVal) * 1000,
          isUtc: true,
        ).toLocal();
      } else {
        expiresAt = DateTime.now().add(const Duration(minutes: 15));
      }

      return JwtClaims(
        userId: userId,
        fullName: nameRaw.toString(),
        email: emailRaw.toString(),
        role: role,
        expiresAt: expiresAt,
      );
    } catch (_) {
      return null;
    }
  }
}
