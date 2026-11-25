import 'package:equatable/equatable.dart';
import '../../../../core/security/jwt_claims_parser.dart';

/// Represents an authenticated user session derived from secure token credentials and JWT claims.
/// Note: Decoded JWT claims represent client-side guidance for navigation and UI,
/// and are clearly distinguished from authoritative server-side permissions verified by the backend.
class AuthSession extends Equatable {
  final int userId;
  final String fullName;
  final String email;
  final UserRole role;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final bool isVolatileSession;

  const AuthSession({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.isVolatileSession = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    role,
    accessToken,
    refreshToken,
    expiresAt,
    isVolatileSession,
  ];
}
