import 'dart:async';
import 'jwt_claims_parser.dart';
import 'secure_token_storage.dart';
import 'token_record.dart';

enum AuthStatus { authenticated, unauthenticated }

/// In-memory synchronous token cache and session lifecycle coordinator.
class TokenManager {
  final ISecureTokenStorage _storage;

  TokenRecord? _cachedRecord;
  JwtClaims? _cachedClaims;

  final StreamController<AuthStatus> _statusController =
      StreamController<AuthStatus>.broadcast();

  TokenManager(this._storage);

  Stream<AuthStatus> get statusStream => _statusController.stream;

  String? get accessToken => _cachedRecord?.accessToken;
  String? get refreshToken => _cachedRecord?.refreshToken;
  TokenRecord? get tokenRecord => _cachedRecord;
  JwtClaims? get claims => _cachedClaims;
  bool get isAuthenticated =>
      _cachedRecord != null && _cachedRecord!.accessToken.isNotEmpty;
  bool get isSessionVolatile => _storage.isVolatileSession;

  /// Initializes the in-memory cache from secure persistent storage during startup.
  Future<void> initialize() async {
    try {
      _cachedRecord = await _storage.getTokenRecord();
      if (_cachedRecord != null && _cachedRecord!.accessToken.isNotEmpty) {
        _cachedClaims = JwtClaimsParser.tryParse(_cachedRecord!.accessToken);
        _statusController.add(AuthStatus.authenticated);
      } else {
        _cachedRecord = null;
        _cachedClaims = null;
        _statusController.add(AuthStatus.unauthenticated);
      }
    } catch (_) {
      _cachedRecord = null;
      _cachedClaims = null;
      _statusController.add(AuthStatus.unauthenticated);
    }
  }

  /// Updates credentials both in memory and in secure storage.
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final claims = JwtClaimsParser.tryParse(accessToken);
    final record = TokenRecord.create(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessLifetime: claims != null
          ? claims.expiresAt.difference(DateTime.now())
          : const Duration(minutes: 15),
    );

    _cachedRecord = record;
    _cachedClaims = claims;

    try {
      await _storage.saveTokenRecord(record);
    } finally {
      _statusController.add(AuthStatus.authenticated);
    }
  }

  /// Clears in-memory credentials and purges secure storage, emitting unauthenticated status.
  Future<void> invalidateSession() async {
    _cachedRecord = null;
    _cachedClaims = null;
    await _storage.clearTokenRecord();
    _statusController.add(AuthStatus.unauthenticated);
  }

  void dispose() {
    _statusController.close();
  }
}
