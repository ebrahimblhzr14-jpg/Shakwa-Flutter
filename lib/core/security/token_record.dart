import 'dart:convert';
import '../errors/exceptions.dart';

/// Serialized token record storing access and refresh tokens together to prevent partial-pair inconsistency.
class TokenRecord {
  final String accessToken;
  final String refreshToken;
  final DateTime createdAt;
  final DateTime expiresAt;

  const TokenRecord({
    required this.accessToken,
    required this.refreshToken,
    required this.createdAt,
    required this.expiresAt,
  });

  /// Factory constructing record from current time and access token duration (15 minutes).
  factory TokenRecord.create({
    required String accessToken,
    required String refreshToken,
    Duration accessLifetime = const Duration(minutes: 15),
  }) {
    final now = DateTime.now();
    return TokenRecord(
      accessToken: accessToken,
      refreshToken: refreshToken,
      createdAt: now,
      expiresAt: now.add(accessLifetime),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'created_at': createdAt.toIso8601String(),
    'expires_at': expiresAt.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory TokenRecord.fromJson(Map<String, dynamic> json) {
    try {
      final access = json['access_token'] as String?;
      final refresh = json['refresh_token'] as String?;
      final createdStr = json['created_at'] as String?;
      final expiresStr = json['expires_at'] as String?;

      if (access == null ||
          access.isEmpty ||
          refresh == null ||
          refresh.isEmpty) {
        throw const CorruptedTokenRecordException(
          'Token strings are missing or empty in token record.',
        );
      }

      final createdAt = createdStr != null
          ? DateTime.parse(createdStr)
          : DateTime.now();
      final expiresAt = expiresStr != null
          ? DateTime.parse(expiresStr)
          : createdAt.add(const Duration(minutes: 15));

      return TokenRecord(
        accessToken: access,
        refreshToken: refresh,
        createdAt: createdAt,
        expiresAt: expiresAt,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw CorruptedTokenRecordException(
        'Failed to deserialize token record: $e',
      );
    }
  }

  factory TokenRecord.fromJsonString(String raw) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return TokenRecord.fromJson(decoded);
    } catch (e) {
      if (e is AppException) rethrow;
      throw CorruptedTokenRecordException(
        'Malformed JSON string in token record: $e',
      );
    }
  }

  TokenRecord copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return TokenRecord(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() =>
      'TokenRecord(expiresAt: $expiresAt, isExpired: $isExpired)';
}
